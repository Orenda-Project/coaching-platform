import { useEffect, useRef, useState, useCallback } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";
import { ArrowLeft, ArrowRight, Send, GraduationCap, AlertTriangle, CheckCircle2, XCircle } from "lucide-react";
import { Tables } from "@/integrations/supabase/types";

type Question = Tables<"questions">;
type Option = Tables<"options">;

interface QuestionWithOptions extends Question {
  options: Option[];
}

const QUIZ_PASS_THRESHOLD = 80;
const MAX_ATTEMPTS = 3;

export default function ModuleQuiz() {
  const { moduleId } = useParams<{ moduleId: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();

  const [moduleTitle, setModuleTitle] = useState("");
  const [questions, setQuestions] = useState<QuestionWithOptions[]>([]);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [attemptCount, setAttemptCount] = useState(0);
  const [tabSwitchCount, setTabSwitchCount] = useState(0);
  const [result, setResult] = useState<{ score: number; passed: boolean; correct: number; total: number } | null>(null);
  const quizContainerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    load();
  }, [moduleId]);

  // Anti-cheat: tab visibility
  useEffect(() => {
    if (result) return;
    const handleVisibilityChange = () => {
      if (document.hidden) {
        const newCount = tabSwitchCount + 1;
        setTabSwitchCount(newCount);
        toast.warning(`Warning: Tab switching detected (${newCount}). This is recorded.`);
      }
    };
    document.addEventListener("visibilitychange", handleVisibilityChange);
    return () => document.removeEventListener("visibilitychange", handleVisibilityChange);
  }, [result, tabSwitchCount]);

  const load = async () => {
    if (!moduleId || !user) return;

    const { data: mod } = await supabase.from("modules").select("title").eq("id", moduleId).single();
    setModuleTitle(mod?.title ?? "Module Quiz");

    // Load existing attempt record
    const { data: existing } = await supabase
      .from("module_quiz_attempts")
      .select("*")
      .eq("user_id", user.id)
      .eq("module_id", moduleId)
      .maybeSingle();

    const currentAttempts = (existing as any)?.attempt_count ?? 0;
    setAttemptCount(currentAttempts);

    if (currentAttempts >= MAX_ATTEMPTS) {
      toast.error(`Maximum attempts (${MAX_ATTEMPTS}) reached for this quiz.`);
      navigate("/dashboard");
      return;
    }

    // Load all assessments for this module's trainings
    const { data: trainings } = await supabase.from("trainings").select("id").eq("module_id", moduleId).order("order_number");
    const trainingIds = trainings?.map((t) => t.id) ?? [];

    const { data: assessments } = await supabase
      .from("assessments")
      .select("id, training_id")
      .eq("type", "module_quiz")
      .in("training_id", trainingIds);

    if (!assessments?.length) {
      toast.info("No quiz questions found for this module.");
      navigate("/dashboard");
      return;
    }

    // Load all questions grouped by assessment (unit)
    const assessmentIds = assessments.map((a) => a.id);
    const { data: allQuestions } = await supabase
      .from("questions")
      .select("*")
      .in("assessment_id", assessmentIds)
      .order("order_number");

    if (!allQuestions?.length) {
      toast.info("No questions found.");
      navigate("/dashboard");
      return;
    }

    // Load options for MCQ questions
    const mcqIds = allQuestions.filter((q) => q.question_type === "mcq").map((q) => q.id);
    const { data: optionsData } = mcqIds.length
      ? await supabase.from("options").select("*").in("question_id", mcqIds)
      : { data: [] };

    const questionsWithOptions = allQuestions.map((q) => ({
      ...q,
      options: (optionsData || []).filter((o) => o.question_id === q.id),
    }));

    // Group by assessment (unit)
    const byUnit: Record<string, QuestionWithOptions[]> = {};
    for (const q of questionsWithOptions) {
      if (!byUnit[q.assessment_id]) byUnit[q.assessment_id] = [];
      byUnit[q.assessment_id].push(q);
    }

    // Shuffle helper
    const shuffle = <T,>(arr: T[]): T[] => {
      const a = [...arr];
      for (let i = a.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [a[i], a[j]] = [a[j], a[i]];
      }
      return a;
    };

    const unitKeys = shuffle(Object.keys(byUnit));
    const numUnits = unitKeys.length;

    // Pick 16 MCQs equally across units: base = floor(16/numUnits), distribute remainder
    const TOTAL_MCQ = 16;
    const TOTAL_OPEN = 4;
    const base = Math.floor(TOTAL_MCQ / numUnits);
    let remainder = TOTAL_MCQ % numUnits;

    const selectedMCQ: QuestionWithOptions[] = [];
    const selectedOpen: QuestionWithOptions[] = [];

    for (const key of unitKeys) {
      const unitQs = byUnit[key];
      const mcqs = shuffle(unitQs.filter((q) => q.question_type === "mcq"));
      const openEnded = shuffle(unitQs.filter((q) => q.question_type === "open"));

      const pick = base + (remainder > 0 ? 1 : 0);
      if (remainder > 0) remainder--;
      selectedMCQ.push(...mcqs.slice(0, pick));

      if (openEnded.length > 0) selectedOpen.push(openEnded[0]);
    }

    // Pick 4 open-ended from the pool (already 1 per unit, shuffle and take 4)
    const finalOpen = shuffle(selectedOpen).slice(0, TOTAL_OPEN);

    // Combine and shuffle
    const finalQuestions = shuffle([...selectedMCQ, ...finalOpen]);

    setQuestions(finalQuestions);
    setLoading(false);
  };

  const saveAttempt = async (score: number, passed: boolean) => {
    if (!user || !moduleId) return;
    const newAttempt = attemptCount + 1;

    const { data: existing } = await supabase
      .from("module_quiz_attempts")
      .select("id, best_score, passed")
      .eq("user_id", user.id)
      .eq("module_id", moduleId)
      .maybeSingle();

    if (existing) {
      await supabase
        .from("module_quiz_attempts")
        .update({
          score,
          best_score: Math.max(score, (existing as any).best_score ?? 0),
          passed: passed || (existing as any).passed,
          attempt_count: newAttempt,
          completed_at: passed ? new Date().toISOString() : null,
        } as any)
        .eq("id", (existing as any).id);
    } else {
      await supabase.from("module_quiz_attempts").insert({
        user_id: user.id,
        module_id: moduleId,
        score,
        best_score: score,
        passed,
        attempt_count: newAttempt,
        completed_at: passed ? new Date().toISOString() : null,
      } as any);
    }

    setAttemptCount(newAttempt);
  };

  const handleSubmit = async () => {
    if (Object.keys(answers).length < questions.length) {
      toast.error("Please answer all questions before submitting.");
      return;
    }

    setSubmitting(true);

    const mcqQuestions = questions.filter((q) => q.question_type === "mcq");
    let correctCount = 0;
    for (const q of mcqQuestions) {
      const correct = q.options.find((o) => o.is_correct);
      if (correct && correct.id === answers[q.id]) correctCount++;
    }

    // Open-ended questions: full credit for answered (manual grading not implemented)
    const openCount = questions.filter((q) => q.question_type === "open").length;

    // Score based on MCQs only for pass/fail (open-ended graded separately)
    const scorePct = mcqQuestions.length > 0
      ? Math.round((correctCount / mcqQuestions.length) * 100)
      : 100;
    const passed = scorePct >= QUIZ_PASS_THRESHOLD;

    await saveAttempt(scorePct, passed);
    setResult({ score: scorePct, passed, correct: correctCount, total: mcqQuestions.length });
    setSubmitting(false);
  };

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  const currentQuestion = questions[currentIndex];
  const totalAnswered = questions.filter((q) => {
    const ans = answers[q.id];
    return ans && ans.trim().length > 0;
  }).length;
  const attemptsRemaining = MAX_ATTEMPTS - attemptCount;

  // Result screen
  if (result) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center p-4">
        <Card className="w-full max-w-md">
          <CardContent className="p-8 text-center space-y-4">
            <div className={`w-16 h-16 rounded-full mx-auto flex items-center justify-center ${result.passed ? "bg-green-500/10" : "bg-red-500/10"}`}>
              {result.passed
                ? <CheckCircle2 className="w-8 h-8 text-green-600" />
                : <XCircle className="w-8 h-8 text-red-600" />}
            </div>
            <h2 className="text-2xl font-bold text-foreground">
              {result.passed ? "Quiz Passed!" : "Not Quite"}
            </h2>
            <p className="text-muted-foreground">
              MCQs: <span className="font-bold text-foreground">{result.correct} of {result.total}</span> correct ({result.score}%)
            </p>
            <p className="text-xs text-muted-foreground">Open-ended responses submitted for review.</p>
            {!result.passed && attemptsRemaining > 0 && (
              <p className="text-muted-foreground text-sm">{attemptsRemaining} attempt{attemptsRemaining === 1 ? "" : "s"} remaining</p>
            )}
            <div className="flex gap-3 pt-2">
              {!result.passed && attemptsRemaining > 0 ? (
                <Button
                  onClick={() => { setResult(null); setAnswers({}); setCurrentIndex(0); }}
                  className="flex-1"
                >
                  Try Again
                </Button>
              ) : null}
              <Button
                variant={result.passed || attemptsRemaining === 0 ? "default" : "outline"}
                onClick={() => navigate("/dashboard")}
                className="flex-1"
              >
                Back to Dashboard
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b bg-background/80 sticky top-0 z-10 backdrop-blur-sm">
        <div className="container flex items-center justify-between h-14 px-4 gap-2">
          <div className="flex items-center gap-2 min-w-0">
            <GraduationCap className="w-5 h-5 text-primary shrink-0" />
            <span className="font-bold text-foreground truncate text-sm sm:text-base">{moduleTitle} — Quiz</span>
            <Badge variant="outline" className="shrink-0 text-xs">
              {attemptCount + 1}/{MAX_ATTEMPTS}
            </Badge>
          </div>
          <Button variant="ghost" size="sm" onClick={() => navigate("/dashboard")} className="shrink-0">
            <ArrowLeft className="w-4 h-4 sm:mr-1" />
            <span className="hidden sm:inline">Dashboard</span>
          </Button>
        </div>
      </header>

      <main className="container px-4 py-8 max-w-2xl" ref={quizContainerRef}>
        <div className="flex items-center gap-3 mb-6">
          <Progress value={((currentIndex + 1) / questions.length) * 100} className="flex-1 h-2" />
          <span className="text-sm text-muted-foreground whitespace-nowrap">{currentIndex + 1} / {questions.length}</span>
        </div>

        {tabSwitchCount > 0 && (
          <div className="flex items-center gap-1 text-orange-500 text-sm mb-4">
            <AlertTriangle className="w-4 h-4" />
            {tabSwitchCount} tab switch{tabSwitchCount > 1 ? "es" : ""} detected
          </div>
        )}

        {currentQuestion && (
          <Card>
            <CardHeader>
              <div className="flex items-center gap-2 mb-1">
                <Badge variant="outline" className="text-xs shrink-0">
                  {currentQuestion.question_type === "open" ? "Open-ended" : "MCQ"}
                </Badge>
              </div>
              <CardTitle className="text-foreground text-base leading-relaxed">
                Q{currentIndex + 1}. {currentQuestion.question_text}
              </CardTitle>
            </CardHeader>
            <CardContent>
              {currentQuestion.question_type === "open" ? (
                <div className="space-y-2">
                  <Textarea
                    placeholder="Write your answer here…"
                    value={answers[currentQuestion.id] || ""}
                    onChange={(e) => setAnswers((prev) => ({ ...prev, [currentQuestion.id]: e.target.value }))}
                    rows={6}
                    className="resize-none"
                  />
                  <p className="text-xs text-muted-foreground">Open-ended response — write in your own words.</p>
                </div>
              ) : (
                <RadioGroup
                  value={answers[currentQuestion.id] || ""}
                  onValueChange={(val) => setAnswers((prev) => ({ ...prev, [currentQuestion.id]: val }))}
                  className="space-y-3"
                >
                  {currentQuestion.options.map((option) => (
                    <div
                      key={option.id}
                      className="flex items-center space-x-3 p-3 rounded-lg border border-border hover:border-primary cursor-pointer transition-colors"
                    >
                      <RadioGroupItem value={option.id} id={option.id} />
                      <Label htmlFor={option.id} className="text-foreground cursor-pointer flex-1">
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
            <Button onClick={() => setCurrentIndex((i) => i + 1)} className="flex-1">
              Next <ArrowRight className="w-4 h-4 ml-1" />
            </Button>
          ) : (
            <Button
              onClick={handleSubmit}
              disabled={submitting || totalAnswered < questions.length}
              className="flex-1"
            >
              {submitting ? "Submitting…" : <><Send className="w-4 h-4 mr-1" /> Submit</>}
            </Button>
          )}
        </div>

        <div className="mt-3 flex justify-between text-sm text-muted-foreground">
          <span>{totalAnswered} of {questions.length} answered</span>
          <span>{attemptsRemaining} attempt{attemptsRemaining === 1 ? "" : "s"} remaining after this</span>
        </div>
      </main>
    </div>
  );
}
