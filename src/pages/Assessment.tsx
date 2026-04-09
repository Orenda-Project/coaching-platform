import { useEffect, useRef, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";
import { Progress } from "@/components/ui/progress";
import { toast } from "sonner";
import { ArrowLeft, ArrowRight, Send, GraduationCap, AlertTriangle } from "lucide-react";
import { Tables } from "@/integrations/supabase/types";

type Question = Tables<"questions">;
type Option = Tables<"options">;

interface QuestionWithOptions extends Question {
  options: Option[];
}

// ─── Persona thresholds ───────────────────────────────────────────────────────
function assignPersona(pct: number): string | null {
  if (pct >= 75) return "A";
  if (pct >= 70) return "B";
  if (pct >= 65) return "C";
  if (pct >= 60) return "D";
  return null; // below 60 — fail
}

const BASELINE_PASS_THRESHOLD = 60;
const ENDLINE_PASS_THRESHOLD = 70;

export default function Assessment() {
  const { type } = useParams<{ type: string }>();
  const navigate = useNavigate();
  const { user, profile, refreshProfile } = useAuth();
  const [questions, setQuestions] = useState<QuestionWithOptions[]>([]);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [endlineBlocked, setEndlineBlocked] = useState(false);
  const submittedRef = useRef(false);

  const isBaseline = type === "baseline";
  const isEndline = type === "endline";
  const passThreshold = isBaseline ? BASELINE_PASS_THRESHOLD : ENDLINE_PASS_THRESHOLD;

  useEffect(() => {
    if (!profile) return;
    if (submittedRef.current) return; // don't redirect after submission

    if (isBaseline && profile.baseline_completed) {
      navigate("/dashboard");
      return;
    }

    if (isEndline) {
      checkEndlineEligibility();
      return;
    }

    loadQuestions();
  }, [type, profile]);

  const checkEndlineEligibility = async () => {
    if (!user || !profile) return;

    // Fetch all modules to find assigned ones (Option A: mandatory + weak_modules)
    const { data: allModules } = await supabase.from("modules").select("id, title, is_mandatory");
    const weakModules = profile.weak_modules || [];
    const assignedModuleIds = new Set(
      (allModules || [])
        .filter((m) => m.is_mandatory || weakModules.includes(m.title))
        .map((m) => m.id)
    );

    const { data: allTrainings } = await supabase.from("trainings").select("id, module_id");
    const assignedTrainings = (allTrainings || []).filter(
      (t) => t.module_id && assignedModuleIds.has(t.module_id)
    );
    const trainingIds = (assignedTrainings || []).map((t) => t.id);

    if (trainingIds.length === 0) {
      loadQuestions();
      return;
    }

    const { data: progressData } = await supabase
      .from("training_progress")
      .select("training_id, passed")
      .eq("user_id", user.id)
      .in("training_id", trainingIds);

    const passedIds = new Set(
      (progressData || []).filter((p) => p.passed).map((p) => p.training_id)
    );
    const allPassed = trainingIds.every((id) => passedIds.has(id));

    if (!allPassed) {
      setEndlineBlocked(true);
      setLoading(false);
      return;
    }

    loadQuestions();
  };

  const loadQuestions = async () => {
    const assessmentType = isBaseline ? "baseline" : "endline";
    const { data: assessments } = await supabase
      .from("assessments")
      .select("id")
      .eq("type", assessmentType)
      .limit(1);

    if (!assessments?.length) {
      toast.error("Assessment not found. Please contact your administrator.");
      navigate("/dashboard");
      return;
    }

    const { data: questionsData } = await supabase
      .from("questions")
      .select("*")
      .eq("assessment_id", assessments[0].id)
      .order("order_number");

    if (!questionsData?.length) {
      toast.error("No questions found for this assessment.");
      navigate("/dashboard");
      return;
    }

    const questionIds = questionsData.map((q) => q.id);
    const { data: optionsData } = await supabase
      .from("options")
      .select("*")
      .in("question_id", questionIds);

    const questionsWithOptions: QuestionWithOptions[] = questionsData.map((q) => ({
      ...q,
      options: (optionsData || []).filter((o) => o.question_id === q.id),
    }));

    setQuestions(questionsWithOptions);
    setLoading(false);
  };

  const handleSubmit = async () => {
    if (!user || !profile) return;

    const totalQuestions = questions.length;
    if (totalQuestions === 0) return;

    let correctCount = 0;
    for (const q of questions) {
      const selectedOptionId = answers[q.id];
      if (!selectedOptionId) continue;
      const selectedOption = q.options.find((o) => o.id === selectedOptionId);
      if (selectedOption?.is_correct) correctCount++;
    }

    const pct = Math.round((correctCount / totalQuestions) * 100);

    // Calculate per-module scores (questions grouped by order_number bands: 1-6=M2, 7-12=M3, etc.)
    const moduleBands: Record<string, { start: number; end: number }> = {
      "Module 2": { start: 1, end: 6 },
      "Module 3": { start: 7, end: 12 },
      "Module 4": { start: 13, end: 18 },
      "Module 5": { start: 19, end: 24 },
      "Module 6": { start: 25, end: 30 },
    };
    const weakModules: string[] = [];
    for (const [mod, { start, end }] of Object.entries(moduleBands)) {
      const modQuestions = questions.filter((q) => q.order_number >= start && q.order_number <= end);
      const modCorrect = modQuestions.filter((q) => {
        const sel = q.options.find((o) => o.id === answers[q.id]);
        return sel?.is_correct;
      }).length;
      const modPct = modQuestions.length > 0 ? (modCorrect / modQuestions.length) * 100 : 0;
      if (modPct < 70) weakModules.push(mod);
    }
    setSubmitting(true);

    try {
      if (isBaseline) {
        const newAttemptCount = (profile.baseline_attempt_count ?? 0) + 1;

        if (pct < BASELINE_PASS_THRESHOLD) {
          await supabase
            .from("profiles")
            .update({ baseline_attempt_count: newAttemptCount })
            .eq("id", user.id);
          await refreshProfile();
          toast.error(
            `You scored ${pct}%. You need at least ${BASELINE_PASS_THRESHOLD}% to proceed. Please try again.`
          );
          setAnswers({});
          setCurrentIndex(0);
          setSubmitting(false);
          return;
        }

        const persona = assignPersona(pct);
        await supabase
          .from("profiles")
          .update({
            persona,
            baseline_score: pct,
            baseline_completed: true,
            baseline_attempt_count: newAttemptCount,
            weak_modules: weakModules,
          })
          .eq("id", user.id);

        submittedRef.current = true;
        await refreshProfile();
        navigate("/dashboard");
      } else {
        // Endline
        const newAttemptCount = (profile.endline_attempt_count ?? 0) + 1;

        if (pct < ENDLINE_PASS_THRESHOLD) {
          await supabase
            .from("profiles")
            .update({ endline_attempt_count: newAttemptCount })
            .eq("id", user.id);
          await refreshProfile();
          toast.error(
            `You scored ${pct}%. You need at least ${ENDLINE_PASS_THRESHOLD}% to earn your certificate. Please try again.`
          );
          setAnswers({});
          setCurrentIndex(0);
          setSubmitting(false);
          return;
        }

        // Pass — upsert certificate to handle retakes
        const certificateId = `CC-${Date.now()}-${Math.random().toString(36).substring(2, 6).toUpperCase()}`;
        const now = new Date().toISOString();

        const { error: certError } = await supabase
          .from("certificates")
          .upsert(
            {
              user_id: user.id,
              certificate_id: certificateId,
              persona: profile.persona,
              issued_at: now,
            } as any,
            { onConflict: "user_id" }
          );

        if (certError) {
          toast.error("Failed to issue certificate. Please try again.");
          setSubmitting(false);
          return;
        }

        await supabase
          .from("profiles")
          .update({
            endline_score: pct,
            endline_completed: true,
            endline_attempt_count: newAttemptCount,
          })
          .eq("id", user.id);

        await refreshProfile();
        toast.success(`Congratulations! You scored ${pct}% and earned your certificate!`);
        navigate("/certificate");
      }
    } catch {
      toast.error("An error occurred. Please try again.");
      setSubmitting(false);
    }
  };

  // ─── Endline blocked ───────────────────────────────────────────────────────
  if (!loading && endlineBlocked) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 flex items-center justify-center p-4">
        <Card className="max-w-md w-full border-orange-500/30 bg-slate-800/60">
          <CardHeader className="text-center">
            <AlertTriangle className="w-12 h-12 text-orange-400 mx-auto mb-2" />
            <CardTitle className="text-white">Complete All Modules First</CardTitle>
          </CardHeader>
          <CardContent className="text-center space-y-4">
            <p className="text-slate-300">
              You must pass all assigned training modules before attempting the endline assessment.
            </p>
            <p className="text-slate-400 text-sm">
              Return to your dashboard to complete any remaining modules.
            </p>
            <Button onClick={() => navigate("/dashboard")} className="w-full bg-teal-600 hover:bg-teal-700">
              Go to Dashboard
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 flex items-center justify-center">
        <div className="text-white text-lg animate-pulse">Loading assessment…</div>
      </div>
    );
  }

  const currentQuestion = questions[currentIndex];
  const totalAnswered = Object.keys(answers).length;
  const progressPct = questions.length > 0 ? (totalAnswered / questions.length) * 100 : 0;
  const canSubmit = totalAnswered === questions.length;

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 flex items-center justify-center p-4">
      <div className="w-full max-w-2xl space-y-4">
        {/* Header */}
        <div className="flex items-center gap-3 text-white">
          <GraduationCap className="w-6 h-6 text-teal-400" />
          <div>
            <h1 className="font-bold text-lg">
              {isBaseline ? "Baseline Assessment" : "Endline Assessment"}
            </h1>
            <p className="text-slate-400 text-sm">
              Pass threshold: {passThreshold}% &nbsp;|&nbsp; Question {currentIndex + 1} of {questions.length}
            </p>
          </div>
        </div>

        {/* Progress */}
        <Progress value={progressPct} className="h-2" />

        {/* Question */}
        {currentQuestion && (
          <Card className="bg-slate-800/60 border-slate-700">
            <CardHeader>
              <CardTitle className="text-white text-base leading-relaxed">
                {currentIndex + 1}. {currentQuestion.question_text}
              </CardTitle>
            </CardHeader>
            <CardContent>
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
                    className="flex items-center space-x-3 p-3 rounded-lg border border-slate-700 hover:border-teal-500 cursor-pointer transition-colors"
                  >
                    <RadioGroupItem value={option.id} id={option.id} />
                    <Label htmlFor={option.id} className="text-slate-200 cursor-pointer flex-1">
                      {option.option_text}
                    </Label>
                  </div>
                ))}
              </RadioGroup>
            </CardContent>
          </Card>
        )}

        {/* Navigation */}
        <div className="flex justify-between gap-3">
          <Button
            variant="outline"
            onClick={() => setCurrentIndex((i) => Math.max(0, i - 1))}
            disabled={currentIndex === 0}
            className="flex-1"
          >
            <ArrowLeft className="w-4 h-4 mr-1" /> Previous
          </Button>

          {canSubmit ? (
            <Button
              onClick={handleSubmit}
              disabled={submitting}
              className="flex-1 bg-teal-600 hover:bg-teal-700"
            >
              {submitting ? "Submitting…" : <><Send className="w-4 h-4 mr-1" /> Submit</>}
            </Button>
          ) : (
            <Button
              onClick={() => {
                // Jump to first unanswered question
                const firstUnanswered = questions.findIndex((q) => !answers[q.id]);
                if (firstUnanswered !== -1) setCurrentIndex(firstUnanswered);
                else setCurrentIndex((i) => Math.min(questions.length - 1, i + 1));
              }}
              className="flex-1 bg-teal-600 hover:bg-teal-700"
            >
              Next <ArrowRight className="w-4 h-4 ml-1" />
            </Button>
          )}
        </div>

        <p className="text-center text-slate-400 text-sm">
          {totalAnswered} of {questions.length} answered
          {!canSubmit && (
            <span className="text-orange-400 ml-2">
              — {questions.length - totalAnswered} question{questions.length - totalAnswered !== 1 ? "s" : ""} remaining
            </span>
          )}
        </p>
      </div>
    </div>
  );
}
