import { useEffect, useState, useRef } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { useAnalytics } from "@/hooks/useAnalytics";
import ScenarioCard from "@/components/scenario/ScenarioCard";
import FeedbackCard from "@/components/scenario/FeedbackCard";
import RevealSlides, { Slide } from "@/components/scenario/RevealSlides";
import ExpandableDepth from "@/components/scenario/ExpandableDepth";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { GraduationCap, ArrowLeft, CheckCircle2, XCircle, Lock } from "lucide-react";
import { toast } from "sonner";
import { canAccessPracticeSection, getPracticeLockMessage } from "@/domain/trainingRules";

type Phase =
  | "loading"
  | "scenario"
  | "feedback"
  | "reveal"
  | "depth"
  | "summary"
  | "locked";

interface ScenarioOption {
  id: string;
  scenario_id: string;
  option_letter: string;
  option_text: string;
  is_correct: boolean;
  rationale: string;
  principle_tag: string | null;
}

interface Scenario {
  id: string;
  unit_id: string;
  order_number: number;
  situation: string;
  question: string;
  difficulty: string;
  feedback_slides: Slide[] | null;
  reveal_content: string | null;
  deep_content: string | null;
  is_active: boolean;
  options: ScenarioOption[];
}

interface ScenarioFlowProps {
  /**
   * Whether the user has completed viewing all training content (slides/video).
   * Default: false (practice section locked).
   * Parent must pass this synchronously to avoid flashing the lock state.
   * If this is derived from async data, parent should show a loading state
   * instead of rendering ScenarioFlow.
   */
  contentCompleted?: boolean;
}

export default function ScenarioFlow({ contentCompleted = false }: ScenarioFlowProps) {
  const { trainingId } = useParams<{ trainingId: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();
  const { track } = useAnalytics();

  // State
  const [phase, setPhase] = useState<Phase>("loading");
  const [scenarios, setScenarios] = useState<Scenario[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedOption, setSelectedOption] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [unitTitle, setUnitTitle] = useState("");
  const [responses, setResponses] = useState<
    Map<string, { isCorrect: boolean; timeSpent: number }>
  >(new Map());
  const [trainingTitle, setTrainingTitle] = useState("");

  const startTimeRef = useRef<number>(0);

  // Load scenarios
  useEffect(() => {
    if (!trainingId || !user) return;

    const loadScenarios = async () => {
      try {
        // Check if practice section is locked
        if (!canAccessPracticeSection(contentCompleted)) {
          setPhase("locked");
          return;
        }

        // Fetch scenarios
        const { data: scenarioData, error: scenarioError } = await supabase
          .from("scenarios")
          .select("*")
          .eq("unit_id", trainingId)
          .eq("is_active", true)
          .order("order_number");

        if (scenarioError) throw scenarioError;

        if (!scenarioData || scenarioData.length === 0) {
          toast.info("No scenarios available for this unit yet.");
          setPhase("loading");
          return;
        }

        // Fetch options for all scenarios
        const scenarioIds = (scenarioData as Array<{ id: string }>).map((s) => s.id);
        const { data: optionsData, error: optionsError } = await supabase
          .from("scenario_options")
          .select("*")
          .in("scenario_id", scenarioIds);

        if (optionsError) throw optionsError;

        // Merge options into scenarios
        const scenariosWithOptions = (scenarioData as Array<Record<string, unknown>>).map((scenario) => ({
          ...scenario,
          feedback_slides: scenario.feedback_slides || [],
          options: optionsData?.filter(
            (opt) => (opt as Record<string, unknown>).scenario_id === scenario.id
          ) || [],
        }));

        setScenarios(scenariosWithOptions as unknown as Scenario[]);
        startTimeRef.current = Date.now();
        setPhase("scenario");

        // Fetch unit/training title for header
        const { data: trainingData } = await supabase
          .from("trainings")
          .select("title")
          .eq("id", trainingId)
          .single();

        if (trainingData) {
          setTrainingTitle(trainingData.title);
          setUnitTitle(trainingData.title);
        }

        // Track initial view
        track({
          event_type: "scenario_viewed",
          unit_id: trainingId,
          scenario_id: scenarioData[0]?.id,
        });
      } catch (error) {
        console.error("Error loading scenarios:", error);
        toast.error("Failed to load scenarios. Please try again.");
        setPhase("loading");
      }
    };

    loadScenarios();
  }, [trainingId, user, track, contentCompleted]);

  if (phase === "loading" || scenarios.length === 0) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <Card className="w-96">
          <CardContent className="pt-6 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4" />
            <p className="text-muted-foreground">Loading scenarios...</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  const currentScenario = scenarios[currentIndex];
  const correctOption = currentScenario.options.find((opt) => opt.is_correct);
  const selectedOptionObj = currentScenario.options.find(
    (opt) => opt.option_letter === selectedOption
  );
  const isCorrect = selectedOption === correctOption?.option_letter;
  const totalScenarios = scenarios.length;
  const completedScenarios = responses.size;
  const correctCount = Array.from(responses.values()).filter(
    (r) => r.isCorrect
  ).length;

  // Handle scenario submission
  const handleSubmitScenario = async () => {
    if (!selectedOption || !user) return;

    setIsSubmitting(true);
    try {
      const timeSpent = Math.round((Date.now() - startTimeRef.current) / 1000);

      // Save response. `as never` bypasses the typed Insert overload — see
      // .claude/agents/pr-reviewer.md Rule 10 (cast permitted with comment).
      const { error } = await supabase.from("scenario_responses").insert({
        user_id: user.id,
        scenario_id: currentScenario.id,
        chosen_option: selectedOption,
        is_correct: isCorrect,
        time_spent_seconds: timeSpent,
        attempt_number: 1,
      } as never);

      if (error) throw error;

      // Track the decision
      track({
        event_type: "decision_submitted",
        scenario_id: currentScenario.id,
        unit_id: trainingId,
        metadata: {
          is_correct: isCorrect,
          time_spent: timeSpent,
        },
      });

      // Store response
      setResponses((prev) =>
        new Map(prev).set(currentScenario.id, {
          isCorrect,
          timeSpent,
        })
      );

      // Move to feedback
      setPhase("feedback");
    } catch (error) {
      console.error("Error submitting response:", error);
      toast.error("Failed to save response. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  // Handle feedback → reveal/depth/next
  const handleContinueFromFeedback = () => {
    const hasRevealSlides =
      currentScenario.feedback_slides &&
      currentScenario.feedback_slides.length > 0;

    if (hasRevealSlides) {
      setPhase("reveal");
      track({
        event_type: "feedback_viewed",
        scenario_id: currentScenario.id,
        unit_id: trainingId,
      });
    } else if (currentScenario.deep_content) {
      setPhase("depth");
    } else {
      handleAdvanceScenario();
    }
  };

  // Handle reveal → depth/next
  const handleRevealDone = () => {
    if (currentScenario.deep_content) {
      setPhase("depth");
    } else {
      handleAdvanceScenario();
    }
  };

  // Advance to next scenario or summary
  const handleAdvanceScenario = () => {
    const nextIndex = currentIndex + 1;
    if (nextIndex < totalScenarios) {
      setCurrentIndex(nextIndex);
      setSelectedOption(null);
      setPhase("scenario");
      startTimeRef.current = Date.now();

      // Track view of next scenario
      track({
        event_type: "scenario_viewed",
        unit_id: trainingId,
        scenario_id: scenarios[nextIndex].id,
      });
    } else {
      setPhase("summary");
    }
  };

  // Render Header
  const renderHeader = () => (
    <div className="sticky top-0 z-10 bg-background border-b shadow-sm">
      <div className="max-w-4xl mx-auto px-4 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <GraduationCap className="h-6 w-6 text-primary" />
          <div>
            <h1 className="font-bold text-lg text-foreground">{unitTitle}</h1>
            {trainingTitle && (
              <p className="text-xs text-muted-foreground">{trainingTitle}</p>
            )}
          </div>
        </div>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => navigate("/dashboard")}
        >
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back
        </Button>
      </div>
      {phase !== "summary" && (
        <div className="px-4 pb-3 text-xs text-muted-foreground">
          Practice {currentIndex + 1} of {totalScenarios}
        </div>
      )}
    </div>
  );

  // Render Content
  const renderContent = () => {
    const containerClass = "max-w-2xl mx-auto px-4 py-8";

    switch (phase) {
      case "scenario":
        return (
          <div className={containerClass}>
            <ScenarioCard
              situation={currentScenario.situation}
              question={currentScenario.question}
              options={currentScenario.options.sort((a, b) =>
                a.option_letter.localeCompare(b.option_letter)
              )}
              selectedLetter={selectedOption}
              onSelect={setSelectedOption}
              onSubmit={handleSubmitScenario}
              locked={false}
              isSubmitting={isSubmitting}
            />
          </div>
        );

      case "feedback":
        return (
          <div className={containerClass}>
            <FeedbackCard
              isCorrect={isCorrect}
              chosenOptionText={selectedOptionObj?.option_text || ""}
              correctOptionText={correctOption?.option_text || ""}
              rationale={correctOption?.rationale || ""}
              principleTag={correctOption?.principle_tag}
              onContinue={handleContinueFromFeedback}
              isLast={currentIndex === totalScenarios - 1}
            />
          </div>
        );

      case "reveal":
        return (
          <div className={containerClass}>
            <RevealSlides
              slides={(currentScenario.feedback_slides || []) as Slide[]}
              onDone={handleRevealDone}
            />
          </div>
        );

      case "depth":
        return (
          <div className={containerClass}>
            <ExpandableDepth
              content={currentScenario.deep_content || ""}
              scenarioId={currentScenario.id}
              unitId={trainingId || ""}
            />
            <div className="mt-6">
              <Button
                onClick={handleAdvanceScenario}
                className="w-full"
                size="lg"
              >
                {currentIndex === totalScenarios - 1
                  ? "See Summary"
                  : "Next Scenario"}
              </Button>
            </div>
          </div>
        );

      case "summary":
        return (
          <div className={containerClass}>
            <Card>
              <CardHeader>
                <CardTitle className="text-center text-2xl">
                  You completed all scenarios!
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* Summary Stats */}
                <div className="grid grid-cols-2 gap-4">
                  <div className="text-center p-4 bg-muted rounded-lg">
                    <div className="text-2xl font-bold text-blue-600">
                      {completedScenarios}
                    </div>
                    <div className="text-xs text-muted-foreground">
                      Completed
                    </div>
                  </div>
                  <div className="text-center p-4 bg-muted rounded-lg">
                    <div className="text-2xl font-bold text-green-600">
                      {correctCount}
                    </div>
                    <div className="text-xs text-muted-foreground">Correct</div>
                  </div>
                </div>

                {/* Performance Percentage */}
                <div className="text-center">
                  <div className="text-4xl font-bold text-foreground">
                    {Math.round((correctCount / completedScenarios) * 100)}%
                  </div>
                  <p className="text-sm text-muted-foreground">
                    Performance Rate
                  </p>
                </div>

                {/* Practice Breakdown */}
                <div className="border-t pt-4">
                  <h3 className="font-semibold mb-3 text-sm">
                    Practice Breakdown
                  </h3>
                  <div className="space-y-2 max-h-64 overflow-y-auto">
                    {scenarios.map((scenario, idx) => {
                      const response = responses.get(scenario.id);
                      return (
                        <div
                          key={scenario.id}
                          className="flex items-center gap-2 text-sm p-2 bg-secondary/5 rounded"
                        >
                          {response?.isCorrect ? (
                            <CheckCircle2 className="h-4 w-4 text-green-600" />
                          ) : (
                            <XCircle className="h-4 w-4 text-red-600" />
                          )}
                          <span className="flex-1">
                            Practice {idx + 1}: {scenario.situation.substring(0, 50)}
                            ...
                          </span>
                          <span className="text-xs text-muted-foreground">
                            {response?.timeSpent || 0}s
                          </span>
                        </div>
                      );
                    })}
                  </div>
                </div>

                {/* Actions */}
                <div className="flex gap-3 pt-4 border-t">
                  <Button
                    variant="outline"
                    className="flex-1"
                    onClick={() => navigate("/dashboard")}
                  >
                    Back to Dashboard
                  </Button>
                  <Button
                    className="flex-1"
                    onClick={() => {
                      setCurrentIndex(0);
                      setSelectedOption(null);
                      setResponses(new Map());
                      setPhase("scenario");
                      startTimeRef.current = Date.now();
                    }}
                  >
                    Redo Scenarios
                  </Button>
                </div>
              </CardContent>
            </Card>
          </div>
        );

      case "locked":
        return (
          <div className={containerClass}>
            <Card className="border-yellow-500/30 bg-yellow-500/5">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-xl text-yellow-700">
                  <Lock className="h-5 w-5" />
                  Practice Section Locked
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="p-4 bg-yellow-50 rounded-lg border border-yellow-200">
                  <p className="text-yellow-900 font-medium mb-2">
                    {getPracticeLockMessage()}
                  </p>
                  <p className="text-sm text-yellow-800">
                    Complete all training slides and videos first to unlock the practice scenarios.
                  </p>
                </div>
                <Button
                  onClick={() => navigate("/dashboard")}
                  variant="outline"
                  className="w-full"
                >
                  <ArrowLeft className="h-4 w-4 mr-2" />
                  Back to Dashboard
                </Button>
              </CardContent>
            </Card>
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {renderHeader()}
      {renderContent()}
    </div>
  );
}
