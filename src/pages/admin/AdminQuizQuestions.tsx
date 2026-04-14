import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { toast } from "sonner";
import { Plus, Trash2, ChevronDown, ChevronUp, CheckCircle } from "lucide-react";
import { Tables } from "@/integrations/supabase/types";

type Training = Tables<"trainings">;
type Option = { id?: string; option_text: string; is_correct: boolean };
type QuestionForm = { id?: string; question_text: string; order_number: number; options: Option[] };

export default function AdminQuizQuestions() {
  const [trainings, setTrainings] = useState<Training[]>([]);
  const [selectedTraining, setSelectedTraining] = useState<string>("");
  const [assessmentId, setAssessmentId] = useState<string | null>(null);
  const [questions, setQuestions] = useState<QuestionForm[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [expanded, setExpanded] = useState<number | null>(0);

  useEffect(() => { loadTrainings(); }, []);
  useEffect(() => { if (selectedTraining) loadQuiz(); }, [selectedTraining]); // eslint-disable-line react-hooks/exhaustive-deps

  const loadTrainings = async () => {
    setLoading(true);
    const { data } = await supabase.from("trainings").select("*").order("order_number");
    setTrainings(data || []);
    if (data?.length) setSelectedTraining(data[0].id);
    setLoading(false);
  };

  const loadQuiz = async () => {
    if (!selectedTraining) return;
    setQuestions([]);
    setAssessmentId(null);

    const { data: assessments } = await supabase
      .from("assessments").select("id")
      .eq("type", "training").eq("training_id", selectedTraining).limit(1);

    if (!assessments?.length) return;
    const aId = assessments[0].id;
    setAssessmentId(aId);

    const { data: qs } = await supabase.from("questions").select("*").eq("assessment_id", aId).order("order_number");
    if (!qs?.length) return;

    const { data: opts } = await supabase.from("options").select("*").in("question_id", qs.map((q) => q.id));
    setQuestions(qs.map((q) => ({
      id: q.id,
      question_text: q.question_text,
      order_number: q.order_number,
      options: (opts || []).filter((o) => o.question_id === q.id).map((o) => ({ id: o.id, option_text: o.option_text, is_correct: o.is_correct })),
    })));
  };

  const createAssessment = async () => {
    const t = trainings.find((tr) => tr.id === selectedTraining);
    if (!t) return;
    const { data, error } = await supabase.from("assessments").insert({
      title: `${t.title} Quiz`,
      type: "training",
      training_id: selectedTraining,
    } as never).select("id").single();
    if (error) { toast.error("Failed to create quiz"); return; }
    setAssessmentId((data as { id: string }).id);
    toast.success("Quiz created!");
  };

  const addQuestion = () => {
    const newQ: QuestionForm = {
      question_text: "",
      order_number: questions.length + 1,
      options: [
        { option_text: "", is_correct: false },
        { option_text: "", is_correct: false },
        { option_text: "", is_correct: false },
        { option_text: "", is_correct: true },
      ],
    };
    setQuestions([...questions, newQ]);
    setExpanded(questions.length);
  };

  const removeQuestion = (idx: number) => setQuestions(questions.filter((_, i) => i !== idx));

  const updateQuestion = (idx: number, text: string) => {
    const updated = [...questions];
    updated[idx] = { ...updated[idx], question_text: text };
    setQuestions(updated);
  };

  const updateOption = (qIdx: number, oIdx: number, field: keyof Option, value: string | boolean) => {
    const updated = [...questions];
    if (field === "is_correct" && value === true) {
      updated[qIdx].options = updated[qIdx].options.map((o, i) => ({ ...o, is_correct: i === oIdx }));
    } else {
      updated[qIdx].options[oIdx] = { ...updated[qIdx].options[oIdx], [field]: value };
    }
    setQuestions(updated);
  };

  const addOption = (qIdx: number) => {
    const updated = [...questions];
    updated[qIdx].options.push({ option_text: "", is_correct: false });
    setQuestions(updated);
  };

  const removeOption = (qIdx: number, oIdx: number) => {
    const updated = [...questions];
    updated[qIdx].options = updated[qIdx].options.filter((_, i) => i !== oIdx);
    setQuestions(updated);
  };

  const handleSave = async () => {
    if (!assessmentId) return;
    for (const q of questions) {
      if (!q.question_text.trim()) { toast.error("All questions must have text"); return; }
      if (!q.options.some((o) => o.is_correct)) { toast.error("Each question must have a correct answer"); return; }
      if (q.options.some((o) => !o.option_text.trim())) { toast.error("All options must have text"); return; }
    }

    setSaving(true);
    try {
      for (let i = 0; i < questions.length; i++) {
        const q = questions[i];
        let questionId = q.id;

        if (questionId) {
          await supabase.from("questions").update({ question_text: q.question_text, order_number: i + 1 }).eq("id", questionId);
        } else {
          const { data } = await supabase.from("questions").insert({
            assessment_id: assessmentId,
            question_text: q.question_text,
            order_number: i + 1,
            question_type: "mcq",
          }).select("id").single();
          questionId = data?.id;
          questions[i].id = questionId;
        }

        if (!questionId) continue;
        for (const opt of q.options) {
          if (opt.id) {
            await supabase.from("options").update({ option_text: opt.option_text, is_correct: opt.is_correct }).eq("id", opt.id);
          } else {
            const { data } = await supabase.from("options").insert({
              question_id: questionId,
              option_text: opt.option_text,
              is_correct: opt.is_correct,
            }).select("id").single();
            opt.id = data?.id;
          }
        }
      }
      toast.success("Quiz questions saved!");
      loadQuiz();
    } catch {
      toast.error("Failed to save questions");
    }
    setSaving(false);
  };

  const selectedTrainingData = trainings.find((t) => t.id === selectedTraining);

  if (loading) return <div className="flex items-center justify-center h-64"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" /></div>;

  return (
    <div className="max-w-3xl">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-display font-bold text-foreground">Quiz Questions</h1>
          <p className="text-muted-foreground text-sm mt-1">Manage quiz questions per training module</p>
        </div>
      </div>

      <div className="mb-6">
        <Label className="text-xs text-muted-foreground mb-1 block">Select Training Module</Label>
        <Select value={selectedTraining} onValueChange={setSelectedTraining}>
          <SelectTrigger className="w-full">
            <SelectValue placeholder="Choose a module" />
          </SelectTrigger>
          <SelectContent>
            {trainings.map((t, i) => (
              <SelectItem key={t.id} value={t.id}>#{i + 1} — {t.title}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {selectedTraining && !assessmentId && (
        <Card className="mb-6 border-dashed">
          <CardContent className="p-6 text-center">
            <p className="text-muted-foreground mb-4">No quiz exists for <strong>{selectedTrainingData?.title}</strong> yet.</p>
            <Button onClick={createAssessment}>Create Quiz</Button>
          </CardContent>
        </Card>
      )}

      {assessmentId && (
        <>
          <div className="flex items-center justify-between mb-4">
            <p className="text-sm font-medium text-foreground">{questions.length} question{questions.length !== 1 ? "s" : ""}</p>
            <div className="flex gap-2">
              <Button variant="outline" onClick={addQuestion}><Plus className="w-4 h-4 mr-1" /> Add Question</Button>
              <Button onClick={handleSave} disabled={saving}>{saving ? "Saving..." : "Save All"}</Button>
            </div>
          </div>

          {questions.length === 0 && (
            <Card className="border-dashed">
              <CardContent className="p-8 text-center text-muted-foreground">No questions yet. Click "Add Question" to start.</CardContent>
            </Card>
          )}

          <div className="space-y-3">
            {questions.map((q, qIdx) => (
              <Card key={qIdx} className="overflow-hidden">
                <CardHeader
                  className="p-4 cursor-pointer flex flex-row items-center justify-between"
                  onClick={() => setExpanded(expanded === qIdx ? null : qIdx)}
                >
                  <div className="flex items-center gap-3 flex-1 min-w-0">
                    <span className="text-xs font-medium text-muted-foreground bg-muted px-2 py-1 rounded shrink-0">Q{qIdx + 1}</span>
                    <span className="text-sm font-medium text-foreground truncate">
                      {q.question_text || <span className="text-muted-foreground italic">Untitled question</span>}
                    </span>
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    <button onClick={(e) => { e.stopPropagation(); removeQuestion(qIdx); }} className="text-destructive hover:text-destructive/80 p-1">
                      <Trash2 className="w-4 h-4" />
                    </button>
                    {expanded === qIdx ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
                  </div>
                </CardHeader>

                {expanded === qIdx && (
                  <CardContent className="px-4 pb-4 space-y-4">
                    <div>
                      <Label className="text-xs text-muted-foreground mb-1 block">Question Text</Label>
                      <Textarea
                        value={q.question_text}
                        onChange={(e) => updateQuestion(qIdx, e.target.value)}
                        placeholder="Enter your question..."
                        rows={2}
                      />
                    </div>
                    <div>
                      <div className="flex items-center justify-between mb-2">
                        <Label className="text-xs text-muted-foreground">Answer Options (click ✓ to mark correct)</Label>
                        <Button variant="ghost" size="sm" onClick={() => addOption(qIdx)}><Plus className="w-3 h-3 mr-1" /> Add Option</Button>
                      </div>
                      <div className="space-y-2">
                        {q.options.map((opt, oIdx) => (
                          <div key={oIdx} className="flex items-center gap-2">
                            <button
                              onClick={() => updateOption(qIdx, oIdx, "is_correct", true)}
                              className={`p-1 rounded-full transition-colors shrink-0 ${opt.is_correct ? "text-primary" : "text-muted-foreground hover:text-primary/50"}`}
                            >
                              <CheckCircle className="w-5 h-5" />
                            </button>
                            <Input
                              value={opt.option_text}
                              onChange={(e) => updateOption(qIdx, oIdx, "option_text", e.target.value)}
                              placeholder={`Option ${oIdx + 1}`}
                              className={opt.is_correct ? "border-primary/50 bg-primary/5" : ""}
                            />
                            <button onClick={() => removeOption(qIdx, oIdx)} className="text-muted-foreground hover:text-destructive p-1 shrink-0">
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </div>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                )}
              </Card>
            ))}
          </div>

          {questions.length > 0 && (
            <div className="mt-6 flex justify-end">
              <Button onClick={handleSave} disabled={saving} size="lg">{saving ? "Saving..." : "Save All Questions"}</Button>
            </div>
          )}
        </>
      )}
    </div>
  );
}
