import { useEffect, useRef, useState, useCallback } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";
import {
  ArrowLeft, ArrowRight, Send, GraduationCap,
  AlertTriangle, CheckCircle2
} from "lucide-react";
import TrainingContentViewer from "@/components/training/TrainingContentViewer";
import { Tables } from "@/integrations/supabase/types";
//test

type Training = Tables<"trainings">;
type Question = Tables<"questions">;
type Option = Tables<"options">;

interface QuestionWithOptions extends Question {
  options: Option[];
}
const QUIZ_PASS_THRESHOLD = 80;
const MAX_ATTEMPTS = 3;

export default function TrainingModule() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();
  const [training, setTraining] = useState<Training | null>(null);
  const [questions, setQuestions] = useState<QuestionWithOptions[]>([]);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [contentCompleted, setContentCompleted] = useState(false);
  const [attemptCount, setAttemptCount] = useState(0);
  const [tabSwitchCount, setTabSwitchCount] = useState(0);
  const [phase, setPhase] = useState<"content" | "quiz">("content");
  const quizContainerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    loadTraining();
  }, [id]); // eslint-disable-line react-hooks/exhaustive-deps

  // Auto-save when content is completed
  useEffect(() => {
    if (contentCompleted && user && id) {
      saveProgress(100, true, attemptCount + 1);
    }
  }, [contentCompleted]); // eslint-disable-line react-hooks/exhaustive-deps

  // ─── Anti-cheat: tab visibility detection ─────────────────────────────────
  useEffect(() => {
    if (phase !== "quiz") return;

    const handleVisibilityChange = () => {
      if (document.hidden) {
        const newCount = tabSwitchCount + 1;
        setTabSwitchCount(newCount);
        toast.warning(`Warning: Tab switching detected (${newCount}). This is recorded.`);
        if (newCount >= 3) {
          toast.error("Multiple tab switches detected. Your attempt has been flagged for review.");
          flagForReview();
        }
      }
    };

    document.addEventListener("visibilitychange", handleVisibilityChange);
    return () => document.removeEventListener("visibilitychange", handleVisibilityChange);
  }, [phase, tabSwitchCount]); // eslint-disable-line react-hooks/exhaustive-deps

  const flagForReview = useCallback(async () => {
    if (!user || !id) return;
    await supabase
      .from("training_progress")
      .update({ flagged_for_review: true, tab_switch_count: tabSwitchCount })
      .eq("user_id", user.id)
      .eq("training_id", id);
  }, [user, id, tabSwitchCount]);

  const loadTraining = async () => {
    if (!id) return;
    const { data: trainingData } = await supabase
      .from("trainings")
      .select("*")
      .eq("id", id)
      .single();

    setTraining(trainingData);

    // Load existing attempt count
    if (user) {
      const { data: existing } = await supabase
        .from("training_progress")
        .select("*")
        .eq("user_id", user.id)
        .eq("training_id", id)
        .maybeSingle();

      if (existing) {
        setAttemptCount((existing as { attempt_count?: number }).attempt_count ?? 1);
        if (existing.passed) setContentCompleted(true);
      }
    }

    setLoading(false);
  };

  const loadQuiz = async () => {
    if (!id) return;

    if (attemptCount >= MAX_ATTEMPTS) {
      toast.error(`Maximum attempts (${MAX_ATTEMPTS}) reached for this module.`);
      navigate("/dashboard");
      return;
    }

    const { data: assessments } = await supabase
      .from("assessments")
      .select("id")
      .eq("type", "module_quiz")
      .eq("training_id", id);

    if (!assessments?.length) {
      toast.info("No quiz for this module. Marking complete.");
      await saveProgress(100, true, attemptCount + 1);
      navigate("/dashboard");
      return;
    }

    const { data: questionsData } = await supabase
      .from("questions")
      .select("*")
      .eq("assessment_id", assessments[0].id)
      .order("order_number");

    if (!questionsData?.length) {
      await saveProgress(100, true, attemptCount + 1);
      navigate("/dashboard");
      return;
    }

    const questionIds = questionsData.map((q) => q.id);
    const { data: optionsData } = await supabase
      .from("options")
      .select("*")
      .in("question_id", questionIds);

    setQuestions(
      questionsData.map((q) => ({
        ...q,
        options: (optionsData || []).filter((o) => o.question_id === q.id),
      }))
    );

    setPhase("quiz");
    setTabSwitchCount(0);
  };

  const saveProgress = async (score: number, passed: boolean, attempt: number) => {
    if (!user || !id) return;

    const now = new Date().toISOString();
    const { data: existing } = await supabase
      .from("training_progress")
      .select("id, score, passed")
      .eq("user_id", user.id)
      .eq("training_id", id)
      .maybeSingle();

    if (existing) {
      const bestScore = Math.max(score, existing.score ?? 0);
      const isPassed = passed || (existing.passed ?? false);
      await supabase
        .from("training_progress")
        .update({
          score: bestScore,
          passed: isPassed,
          attempt_count: attempt,
          completed_at: isPassed ? now : null,
          content_completed: true,
        })
        .eq("id", existing.id);
    } else {
      await supabase.from("training_progress").insert({
        user_id: user.id,
        training_id: id,
        score,
        passed,
        attempt_count: attempt,
        content_completed: true,
        completed_at: passed ? now : null,
      });
    }
  };

  const handleQuizSubmit = async () => {
    if (Object.keys(answers).length < questions.length) {
      toast.error("Please answer all questions before submitting.");
      return;
    }

    setSubmitting(true);
    const newAttempt = attemptCount + 1;

    let correctCount = 0;
    for (const q of questions) {
      const selectedId = answers[q.id];
      const correct = q.options.find((o) => o.is_correct);
      if (correct && correct.id === selectedId) correctCount++;
    }

    const scorePct = Math.round((correctCount / questions.length) * 100);
    const passed = scorePct >= QUIZ_PASS_THRESHOLD;

    await saveProgress(scorePct, passed, newAttempt);
    setAttemptCount(newAttempt);

    if (passed) {
      toast.success(`Passed! You scored ${scorePct}%. Module complete.`);
      navigate("/dashboard");
    } else {
      const remaining = MAX_ATTEMPTS - newAttempt;
      if (remaining <= 0) {
        toast.error(`You scored ${scorePct}%. No attempts remaining. Contact your administrator.`);
        navigate("/dashboard");
      } else {
        toast.error(
          `You scored ${scorePct}%. You need ≥${QUIZ_PASS_THRESHOLD}% to pass. ${remaining} attempt${remaining === 1 ? "" : "s"} remaining.`
        );
        setAnswers({});
        setCurrentIndex(0);
        setSubmitting(false);
      }
    }
  };

  if (loading || !training) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  const attemptsRemaining = MAX_ATTEMPTS - attemptCount;
  const currentQuestion = questions[currentIndex];
  const totalAnswered = Object.keys(answers).length;

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-background sticky top-0 z-10">
        <div className="container flex items-center justify-between h-14 px-4 gap-2">
          <div className="flex items-center gap-2 min-w-0">
            <GraduationCap className="w-5 h-5 text-primary shrink-0" />
            <span className="font-bold text-foreground truncate text-sm sm:text-base">{training.title}</span>
            {phase === "quiz" && (
              <Badge variant="outline" className="shrink-0 text-xs text-warning border-warning">
                {attemptCount + 1}/{MAX_ATTEMPTS}
              </Badge>
            )}
          </div>
          <Button variant="ghost" size="sm" onClick={() => navigate("/dashboard")} className="shrink-0">
            <ArrowLeft className="w-4 h-4 sm:mr-1" />
            <span className="hidden sm:inline">Dashboard</span>
          </Button>
        </div>
      </header>

      <main className="container px-4 py-8 max-w-2xl" ref={quizContainerRef}>
        {phase === "content" ? (
          <div>
            <h1 className="text-2xl font-bold text-foreground mb-1">{training.title}</h1>
            <p className="text-muted-foreground mb-6">{training.description}</p>

            <TrainingContentViewer
              trainingId={id!}
              trainingTitle={training.title}
              onContentCompleted={setContentCompleted}
            />

            {contentCompleted && (
              <div className="mt-6 flex items-center justify-between">
                <div className="flex items-center gap-2 text-success text-sm">
                  <CheckCircle2 className="w-4 h-4" />
                  Unit completed
                </div>
                <Button
                  onClick={() => navigate("/dashboard")}
                >
                  Finish Training <ArrowRight className="w-4 h-4 ml-1" />
                </Button>
              </div>
            )}
          </div>
        ) : (
          <div>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-4">
              <h1 className="text-lg sm:text-xl font-bold text-foreground">{training.title} — Quiz</h1>
              {tabSwitchCount > 0 && (
                <div className="flex items-center gap-1 text-warning text-sm shrink-0">
                  <AlertTriangle className="w-4 h-4" />
                  {tabSwitchCount} tab switch{tabSwitchCount > 1 ? "es" : ""} detected
                </div>
              )}
            </div>

            <div className="flex items-center gap-3 mb-6">
              <Progress
                value={((currentIndex + 1) / questions.length) * 100}
                className="flex-1 h-2"
              />
              <span className="text-sm text-muted-foreground whitespace-nowrap">
                {currentIndex + 1} / {questions.length}
              </span>
            </div>

            {currentQuestion && (
              <Card className="bg-card border-border">
                <CardHeader>
                  <CardTitle className="text-foreground text-base leading-relaxed">
                    Q{currentIndex + 1}. {currentQuestion.question_text}
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  {currentQuestion.question_type === 'open' && (
                    <div className="space-y-2">
                      <textarea
                        value={answers[currentQuestion.id] || ""}
                        onChange={(e) =>
                          setAnswers((prev) => ({ ...prev, [currentQuestion.id]: e.target.value }))
                        }
                        placeholder="Enter your response here..."
                        className="w-full min-h-[120px] p-3 border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground"
                      />
                      <p className="text-xs text-muted-foreground italic">(does not count toward your score)</p>
                    </div>
                  )}
                  {currentQuestion.question_type === 'mcq' && (
                    <RadioGroup
                      value={answers[currentQuestion.id] || ""}
                      onValueChange={(val) =>
                        setAnswers((prev) => ({ ...prev, [currentQuestion.id]: val }))
                      }
                    className="space-y-3"
                  >
                      {currentQuestion.options.map((option) => (
                        <div
                          key={option.id}
                          className="flex items-center space-x-3 p-3 rounded-lg border border-input hover:border-primary cursor-pointer transition-colors"
                        >
                          <RadioGroupItem value={option.id} id={option.id} />
                          <Label
                            htmlFor={option.id}
                            className="text-foreground cursor-pointer flex-1"
                          >
                            {option.option_text}
                          </Label>
                        </div>
                      ))}
                    </RadioGroup>
                  )}
                </CardContent>
              </Card>
            )}

            <div className="flex justify-between mt-6 gap-3">
              <Button
                variant="outline"
                onClick={() => setCurrentIndex((i) => Math.max(0, i - 1))}
                disabled={currentIndex === 0}
                className="flex-1"
              >
                <ArrowLeft className="w-4 h-4 mr-1" /> Previous
              </Button>

              {currentIndex < questions.length - 1 ? (
                <Button
                  onClick={() => {
                    const current = questions[currentIndex];
                    const ans = answers[current.id];
                    if (!ans || ans.trim().length === 0) {
                      toast.error("Please answer this question before moving on.");
                      return;
                    }
                    setCurrentIndex((i) => i + 1);
                  }}
                  className="flex-1 bg-primary hover:bg-primary/90"
                >
                  Next <ArrowRight className="w-4 h-4 ml-1" />
                </Button>
              ) : (
                <Button
                  onClick={handleQuizSubmit}
                  disabled={submitting || totalAnswered < questions.length}
                  className="flex-1 bg-primary hover:bg-primary/90"
                >
                  {submitting ? "Submitting…" : <><Send className="w-4 h-4 mr-1" /> Submit</>}
                </Button>
              )}
            </div>

            <div className="mt-3 flex justify-between text-sm text-muted-foreground">
              <span>{totalAnswered} of {questions.length} answered</span>
              <span>{attemptsRemaining} attempt{attemptsRemaining === 1 ? "" : "s"} remaining after this</span>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
