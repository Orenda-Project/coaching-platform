import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";
import { Progress } from "@/components/ui/progress";
import { toast } from "sonner";
import { ArrowLeft, ArrowRight, Send, GraduationCap, FileText, Headphones, Video, BookOpen } from "lucide-react";
import { Tables } from "@/integrations/supabase/types";

type Training = Tables<"trainings">;
type Question = Tables<"questions">;
type Option = Tables<"options">;

interface QuestionWithOptions extends Question {
  options: Option[];
}

export default function TrainingModule() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();
  const [training, setTraining] = useState<Training | null>(null);
  const [phase, setPhase] = useState<"content" | "quiz">("content");
  const [questions, setQuestions] = useState<QuestionWithOptions[]>([]);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    loadTraining();
  }, [id]);

  const loadTraining = async () => {
    if (!id) return;
    const { data } = await supabase.from("trainings").select("*").eq("id", id).single();
    setTraining(data);
    setLoading(false);
  };

  const loadQuiz = async () => {
    if (!id) return;
    const { data: assessments } = await supabase
      .from("assessments")
      .select("id")
      .eq("type", "training")
      .eq("training_id", id);

    if (!assessments?.length) {
      toast.info("No quiz available for this module. Module marked as complete.");
      // Auto-pass if no quiz
      await saveProgress(100, true);
      navigate("/dashboard");
      return;
    }

    const { data: questionsData } = await supabase
      .from("questions")
      .select("*")
      .eq("assessment_id", assessments[0].id)
      .order("order_number");

    if (!questionsData?.length) {
      await saveProgress(100, true);
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
  };

  const saveProgress = async (score: number, passed: boolean) => {
    if (!user || !id) return;
    
    // Upsert progress
    const { data: existing } = await supabase
      .from("training_progress")
      .select("id, score")
      .eq("user_id", user.id)
      .eq("training_id", id)
      .maybeSingle();

    if (existing) {
      // Keep highest score
      const bestScore = Math.max(score, existing.score || 0);
      const isPassed = passed || bestScore >= 80;
      await supabase.from("training_progress").update({
        score: bestScore,
        passed: isPassed,
        completed_at: isPassed ? new Date().toISOString() : null,
      }).eq("id", existing.id);
    } else {
      await supabase.from("training_progress").insert({
        user_id: user.id,
        training_id: id,
        score,
        passed,
        completed_at: passed ? new Date().toISOString() : null,
      });
    }
  };

  const handleQuizSubmit = async () => {
    if (Object.keys(answers).length < questions.length) {
      toast.error("Please answer all questions");
      return;
    }

    setSubmitting(true);

    let correctCount = 0;
    for (const q of questions) {
      const selectedOptionId = answers[q.id];
      const correctOption = q.options.find((o) => o.is_correct);
      if (correctOption && correctOption.id === selectedOptionId) {
        correctCount++;
      }
    }

    const scorePercent = (correctCount / questions.length) * 100;
    const passed = scorePercent >= 80;

    await saveProgress(scorePercent, passed);

    if (passed) {
      toast.success(`Passed! You scored ${Math.round(scorePercent)}%`);
      navigate("/dashboard");
    } else {
      toast.error(`You scored ${Math.round(scorePercent)}%. You need ≥80% to pass. Try again!`);
      setAnswers({});
      setCurrentIndex(0);
      setSubmitting(false);
    }
  };

  if (loading || !training) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b border-border bg-card">
        <div className="container flex items-center justify-between h-16 px-4">
          <div className="flex items-center gap-2">
            <div className="w-9 h-9 rounded-lg bg-primary flex items-center justify-center">
              <GraduationCap className="w-5 h-5 text-primary-foreground" />
            </div>
            <span className="font-display font-bold text-lg text-foreground">CoachCert</span>
          </div>
          <Button variant="ghost" size="sm" onClick={() => navigate("/dashboard")}>
            <ArrowLeft className="w-4 h-4 mr-1" /> Dashboard
          </Button>
        </div>
      </header>

      <main className="container px-4 py-8 max-w-2xl">
        {phase === "content" ? (
          <div className="animate-fade-in">
            <h1 className="text-2xl font-display font-bold text-foreground mb-2">{training.title}</h1>
            <p className="text-muted-foreground mb-6">{training.description}</p>

            {/* Content format selection */}
            <Card className="glass-card mb-6">
              <CardHeader>
                <CardTitle className="text-lg font-display">Select Learning Format</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-3 gap-3">
                  <button className="flex flex-col items-center gap-2 p-4 rounded-lg border-2 border-border hover:border-primary hover:bg-accent/50 transition-all">
                    <FileText className="w-8 h-8 text-primary" />
                    <span className="text-sm font-medium text-foreground">Slides</span>
                  </button>
                  <button className="flex flex-col items-center gap-2 p-4 rounded-lg border-2 border-border hover:border-primary hover:bg-accent/50 transition-all">
                    <Headphones className="w-8 h-8 text-primary" />
                    <span className="text-sm font-medium text-foreground">Audio</span>
                  </button>
                  <button className="flex flex-col items-center gap-2 p-4 rounded-lg border-2 border-border hover:border-primary hover:bg-accent/50 transition-all">
                    <Video className="w-8 h-8 text-primary" />
                    <span className="text-sm font-medium text-foreground">Video</span>
                  </button>
                </div>
              </CardContent>
            </Card>

            {/* Simulated content area */}
            <Card className="glass-card mb-6">
              <CardContent className="p-8 text-center">
                <BookOpen className="w-16 h-16 text-muted-foreground mx-auto mb-4" />
                <h3 className="text-lg font-display font-semibold text-foreground mb-2">Module Content</h3>
                <p className="text-muted-foreground mb-4">
                  Review the learning materials for "{training.title}" using your preferred format above.
                </p>
                <p className="text-sm text-muted-foreground">
                  Content will be loaded from your uploaded training materials.
                </p>
              </CardContent>
            </Card>

            <div className="flex justify-end">
              <Button onClick={loadQuiz} size="lg">
                Attempt Quiz <ArrowRight className="w-4 h-4 ml-1" />
              </Button>
            </div>
          </div>
        ) : (
          <div className="animate-fade-in">
            <h1 className="text-2xl font-display font-bold text-foreground mb-2">{training.title} — Quiz</h1>
            <div className="flex items-center gap-3 mb-6">
              <Progress value={((currentIndex + 1) / questions.length) * 100} className="flex-1 h-2" />
              <span className="text-sm text-muted-foreground">{currentIndex + 1}/{questions.length}</span>
            </div>

            <Card className="glass-card">
              <CardHeader>
                <CardTitle className="font-display text-lg">
                  Q{currentIndex + 1}. {questions[currentIndex].question_text}
                </CardTitle>
              </CardHeader>
              <CardContent>
                <RadioGroup
                  value={answers[questions[currentIndex].id] || ""}
                  onValueChange={(value) => setAnswers({ ...answers, [questions[currentIndex].id]: value })}
                  className="space-y-3"
                >
                  {questions[currentIndex].options.map((option) => (
                    <div key={option.id} className="flex items-center space-x-3 p-3 rounded-lg border border-border hover:bg-accent/50 transition-colors">
                      <RadioGroupItem value={option.id} id={option.id} />
                      <Label htmlFor={option.id} className="flex-1 cursor-pointer text-foreground">
                        {option.option_text}
                      </Label>
                    </div>
                  ))}
                </RadioGroup>
              </CardContent>
            </Card>

            <div className="flex justify-between mt-6">
              <Button variant="outline" onClick={() => setCurrentIndex(Math.max(0, currentIndex - 1))} disabled={currentIndex === 0}>
                <ArrowLeft className="w-4 h-4 mr-1" /> Previous
              </Button>
              {currentIndex < questions.length - 1 ? (
                <Button onClick={() => setCurrentIndex(currentIndex + 1)} disabled={!answers[questions[currentIndex].id]}>
                  Next <ArrowRight className="w-4 h-4 ml-1" />
                </Button>
              ) : (
                <Button onClick={handleQuizSubmit} disabled={submitting || Object.keys(answers).length < questions.length}>
                  {submitting ? "Submitting..." : "Submit"} <Send className="w-4 h-4 ml-1" />
                </Button>
              )}
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
