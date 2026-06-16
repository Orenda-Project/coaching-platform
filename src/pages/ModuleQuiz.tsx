import { useEffect, useRef, useState, useCallback } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";
import { ArrowLeft, ArrowRight, Send, GraduationCap, AlertTriangle, CheckCircle2, XCircle } from "lucide-react";

const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:8000";

interface Option {
  id: string;
  option_text?: string;
  text?: string;
  is_correct: boolean;
  letter?: string;
  question_id?: string;
}

interface Question {
  id: string;
  question_text: string;
  question_type: string;
  order_number?: number;
  assessment_id?: string;
}

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
  }, [moduleId]); // eslint-disable-line react-hooks/exhaustive-deps

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

    try {
      // Get module title
      const modulesRes = await fetch(`${apiUrl}/api/training/modules`);
      if (modulesRes.ok) {
        const modulesData = await modulesRes.json();
        const mod = (modulesData.modules || []).find((m: { id: string; title: string }) => m.id === moduleId);
        setModuleTitle(mod?.title ?? "Module Quiz");
      }

      // Load existing attempt record
      const attemptRes = await fetch(`${apiUrl}/api/training/module-quiz-attempt/${user.id}/${moduleId}`);
      if (attemptRes.ok) {
        const existing = await attemptRes.json();
        const currentAttempts = existing?.attempt_count ?? 0;
        setAttemptCount(currentAttempts);

        if (currentAttempts >= MAX_ATTEMPTS) {
          toast.error(`Maximum attempts (${MAX_ATTEMPTS}) reached for this quiz.`);
          navigate("/dashboard");
          return;
        }
      }

      // Load questions via module quiz endpoint
      const questionsRes = await fetch(`${apiUrl}/api/quiz/module/${moduleId}/questions`);
      if (!questionsRes.ok) {
        toast.info("No quiz questions found for this module.");
        navigate("/dashboard");
        return;
      }

      const questionsData = await questionsRes.json();
      const mcqQuestions = questionsData.mcq || [];
      const scenarioQuestions = questionsData.scenarios || [];

      if (mcqQuestions.length === 0 && scenarioQuestions.length === 0) {
        toast.info("No questions found.");
        navigate("/dashboard");
        return;
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

      // Map to QuestionWithOptions and shuffle options
      const mapQuestion = (q: Record<string, unknown>, qType: string): QuestionWithOptions => ({
        id: q.id as string,
        question_text: q.question_text as string,
        question_type: qType,
        order_number: (q.order_number as number) || 0,
        options: shuffle(((q.options as Array<Record<string, unknown>>) || []).map((o) => ({
          id: o.id as string,
          option_text: (o.text || o.option_text) as string,
          is_correct: o.is_correct as boolean,
          letter: o.letter as string | undefined,
        }))),
      });

      const allMCQ = mcqQuestions.map((q: Record<string, unknown>) => mapQuestion(q, "mcq"));
      const allScenarios = scenarioQuestions.map((q: Record<string, unknown>) => mapQuestion(q, "scenario"));

      // Pick 16 MCQs and 4 scenarios (or fewer if not enough)
      const TOTAL_MCQ = 16;
      const TOTAL_SCENARIO = 4;
      const selectedMCQ = shuffle(allMCQ).slice(0, TOTAL_MCQ);
      const selectedScenarios = shuffle(allScenarios).slice(0, TOTAL_SCENARIO);

      const finalQuestions = shuffle([...selectedMCQ, ...selectedScenarios]);
      setQuestions(finalQuestions);
      setLoading(false);
    } catch (err) {
      console.error("Failed to load module quiz:", err);
      toast.error("Failed to load quiz. Please try again.");
      navigate("/dashboard");
    }
  };

  const saveAttempt = async (score: number, passed: boolean) => {
    if (!user || !moduleId) return;

    try {
      await fetch(`${apiUrl}/api/training/module-quiz-attempt`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          user_id: user.id,
          module_id: moduleId,
          score,
          passed,
        }),
      });
      setAttemptCount((prev) => prev + 1);
    } catch (err) {
      console.error("Failed to save quiz attempt:", err);
    }
  };

  const handleSubmit = async () => {
    if (Object.keys(answers).length < questions.length) {
      toast.error("Please answer all questions before submitting.");
      return;
    }

    setSubmitting(true);

    // Score MCQs and scenarios the same way (both are multiple-choice with one correct option)
    const scorableQuestions = questions.filter(
      (q) => q.question_type === "mcq" || q.question_type === "scenario",
    );
    let correctCount = 0;
    for (const q of scorableQuestions) {
      const correct = q.options.find((o) => o.is_correct);
      if (correct && correct.id === answers[q.id]) correctCount++;
    }

    const scorePct = scorableQuestions.length > 0
      ? Math.round((correctCount / scorableQuestions.length) * 100)
      : 100;
    const passed = scorePct >= QUIZ_PASS_THRESHOLD;

    await saveAttempt(scorePct, passed);
    setResult({ score: scorePct, passed, correct: correctCount, total: scorableQuestions.length });
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
                Back to Training
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
                  {currentQuestion.question_type === "open"
                    ? "Open-ended"
                    : currentQuestion.question_type === "scenario"
                      ? "Scenario"
                      : "MCQ"}
                </Badge>
              </div>
              <CardTitle className="text-foreground text-base leading-relaxed">
                Q{currentIndex + 1}.{currentQuestion.question_type === "scenario" ? "" : ` ${currentQuestion.question_text}`}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {currentQuestion.question_type === "scenario" && (
                <div className="bg-muted/50 border border-border rounded-lg p-4 text-sm text-foreground italic whitespace-pre-wrap">
                  {currentQuestion.question_text}
                </div>
              )}
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
                        {option.option_text || option.text}
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
              className="flex-1"
            >
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
