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
import { ArrowLeft, ArrowRight, Send, GraduationCap } from "lucide-react";
import { Tables } from "@/integrations/supabase/types";

type Question = Tables<"questions">;
type Option = Tables<"options">;

interface QuestionWithOptions extends Question {
  options: Option[];
}

export default function Assessment() {
  const { type } = useParams<{ type: string }>();
  const navigate = useNavigate();
  const { user, profile, refreshProfile } = useAuth();
  const [questions, setQuestions] = useState<QuestionWithOptions[]>([]);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  const isBaseline = type === "baseline";
  const passThreshold = isBaseline ? 60 : 70;

  useEffect(() => {
    if (isBaseline && profile?.baseline_completed) {
      toast.info("Baseline already completed");
      navigate("/dashboard");
      return;
    }
    loadQuestions();
  }, [type]);

  const loadQuestions = async () => {
    const assessmentType = isBaseline ? "baseline" : "endline";
    const { data: assessments } = await supabase
      .from("assessments")
      .select("id")
      .eq("type", assessmentType)
      .limit(1);

    if (!assessments?.length) {
      toast.error("Assessment not found");
      navigate("/dashboard");
      return;
    }

    const { data: questionsData } = await supabase
      .from("questions")
      .select("*")
      .eq("assessment_id", assessments[0].id)
      .order("order_number");

    if (!questionsData?.length) {
      toast.error("No questions found");
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
    if (Object.keys(answers).length < questions.length) {
      toast.error("Please answer all questions");
      return;
    }

    setSubmitting(true);

    // Calculate score
    let correctCount = 0;
    for (const q of questions) {
      const selectedOptionId = answers[q.id];
      const correctOption = q.options.find((o) => o.is_correct);
      if (correctOption && correctOption.id === selectedOptionId) {
        correctCount++;
      }
    }

    const scorePercent = (correctCount / questions.length) * 100;

    if (isBaseline) {
      if (scorePercent < passThreshold) {
        toast.error(`You scored ${Math.round(scorePercent)}%. You need at least ${passThreshold}% to pass. Please try again.`);
        setAnswers({});
        setCurrentIndex(0);
        setSubmitting(false);
        return;
      }

      // Assign persona
      let persona = "D";
      if (scorePercent >= 75) persona = "A";
      else if (scorePercent >= 70) persona = "B";
      else if (scorePercent >= 65) persona = "C";

      await supabase.from("profiles").update({
        baseline_completed: true,
        baseline_score: scorePercent,
        persona,
      }).eq("id", user!.id);

      await refreshProfile();
      toast.success(`Baseline completed! You scored ${Math.round(scorePercent)}% — assigned Persona ${persona}`);
      navigate("/dashboard");
    } else {
      // Endline
      if (scorePercent < passThreshold) {
        toast.error(`You scored ${Math.round(scorePercent)}%. You need at least ${passThreshold}% to pass. Please try again.`);
        setAnswers({});
        setCurrentIndex(0);
        setSubmitting(false);
        return;
      }

      await supabase.from("profiles").update({
        endline_completed: true,
        endline_score: scorePercent,
      }).eq("id", user!.id);

      // Create certificate
      const certId = `CC-${Date.now()}-${Math.random().toString(36).substr(2, 6).toUpperCase()}`;
      await supabase.from("certificates").insert({
        user_id: user!.id,
        certificate_id: certId,
        persona: profile!.persona!,
      });

      await refreshProfile();
      toast.success("Endline passed! Your certificate is ready.");
      navigate("/certificate");
    }
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
  const progressValue = ((currentIndex + 1) / questions.length) * 100;

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
            <ArrowLeft className="w-4 h-4 mr-1" /> Back
          </Button>
        </div>
      </header>

      <main className="container px-4 py-8 max-w-2xl">
        <div className="mb-6 animate-fade-in">
          <h1 className="text-2xl font-display font-bold text-foreground mb-2">
            {isBaseline ? "Baseline Assessment" : "Endline Assessment"}
          </h1>
          <div className="flex items-center gap-3 mb-2">
            <Progress value={progressValue} className="flex-1 h-2" />
            <span className="text-sm text-muted-foreground shrink-0">
              {currentIndex + 1}/{questions.length}
            </span>
          </div>
        </div>

        <Card className="glass-card animate-fade-in">
          <CardHeader>
            <CardTitle className="font-display text-lg">
              Q{currentIndex + 1}. {currentQuestion.question_text}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <RadioGroup
              value={answers[currentQuestion.id] || ""}
              onValueChange={(value) => setAnswers({ ...answers, [currentQuestion.id]: value })}
              className="space-y-3"
            >
              {currentQuestion.options.map((option) => (
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
          <Button
            variant="outline"
            onClick={() => setCurrentIndex(Math.max(0, currentIndex - 1))}
            disabled={currentIndex === 0}
          >
            <ArrowLeft className="w-4 h-4 mr-1" /> Previous
          </Button>
          {currentIndex < questions.length - 1 ? (
            <Button
              onClick={() => setCurrentIndex(currentIndex + 1)}
              disabled={!answers[currentQuestion.id]}
            >
              Next <ArrowRight className="w-4 h-4 ml-1" />
            </Button>
          ) : (
            <Button
              onClick={handleSubmit}
              disabled={submitting || Object.keys(answers).length < questions.length}
            >
              {submitting ? "Submitting..." : "Submit"} <Send className="w-4 h-4 ml-1" />
            </Button>
          )}
        </div>
      </main>
    </div>
  );
}
