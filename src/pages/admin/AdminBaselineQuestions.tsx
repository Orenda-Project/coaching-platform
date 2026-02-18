import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import { toast } from "sonner";
import { Plus, Trash2, ChevronDown, ChevronUp, CheckCircle } from "lucide-react";

type Assessment = { id: string; title: string; type: string };
type Option = { id?: string; option_text: string; is_correct: boolean };
type QuestionForm = {
  id?: string;
  question_text: string;
  order_number: number;
  options: Option[];
};

export default function AdminBaselineQuestions() {
  const [assessment, setAssessment] = useState<Assessment | null>(null);
  const [questions, setQuestions] = useState<QuestionForm[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [expanded, setExpanded] = useState<number | null>(0);

  useEffect(() => { loadData(); }, []);

  const loadData = async () => {
    setLoading(true);
    const { data: assessments } = await supabase
      .from("assessments").select("id, title, type")
      .eq("type", "baseline").limit(1);

    if (!assessments?.length) {
      setLoading(false);
      return;
    }
    const a = assessments[0];
    setAssessment(a);

    const { data: qs } = await supabase
      .from("questions").select("*")
      .eq("assessment_id", a.id).order("order_number");

    if (qs?.length) {
      const qIds = qs.map((q) => q.id);
      const { data: opts } = await supabase.from("options").select("*").in("question_id", qIds);
      setQuestions(qs.map((q) => ({
        id: q.id,
        question_text: q.question_text,
        order_number: q.order_number,
        options: (opts || []).filter((o) => o.question_id === q.id).map((o) => ({
          id: o.id, option_text: o.option_text, is_correct: o.is_correct,
        })),
      })));
    }
    setLoading(false);
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

  const removeQuestion = (idx: number) => {
    setQuestions(questions.filter((_, i) => i !== idx));
  };

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

  const createBaselineAssessment = async () => {
    const { data, error } = await supabase.from("assessments").insert({
      title: "Baseline Assessment",
      type: "baseline",
      question_type: "mcq",
    } as never).select("id, title, type").single();
    if (error) { toast.error("Failed to create assessment"); return; }
    setAssessment(data as Assessment);
    toast.success("Baseline assessment created!");
  };

  const handleSave = async () => {
    if (!assessment) return;
    for (const q of questions) {
      if (!q.question_text.trim()) { toast.error("All questions must have text"); return; }
      if (q.options.length < 2) { toast.error("Each question needs at least 2 options"); return; }
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
            assessment_id: assessment.id,
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
      toast.success("Baseline questions saved!");
      loadData();
    } catch {
      toast.error("Failed to save questions");
    }
    setSaving(false);
  };

  if (loading) return <div className="flex items-center justify-center h-64"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" /></div>;

  return (
    <div className="max-w-3xl">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-display font-bold text-foreground">Baseline Questions</h1>
          <p className="text-muted-foreground text-sm mt-1">{questions.length} question{questions.length !== 1 ? "s" : ""}</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={addQuestion}><Plus className="w-4 h-4 mr-1" /> Add Question</Button>
          <Button onClick={handleSave} disabled={saving}>{saving ? "Saving..." : "Save All"}</Button>
        </div>
      </div>

      {!assessment && (
        <Card className="mb-6 border-dashed">
          <CardContent className="p-6 text-center">
            <p className="text-muted-foreground mb-4">No baseline assessment exists yet.</p>
            <Button onClick={createBaselineAssessment}>Create Baseline Assessment</Button>
          </CardContent>
        </Card>
      )}

      {questions.length === 0 && assessment && (
        <Card className="border-dashed">
          <CardContent className="p-8 text-center text-muted-foreground">
            No questions yet. Click "Add Question" to start.
          </CardContent>
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
                    <Button variant="ghost" size="sm" onClick={() => addOption(qIdx)}>
                      <Plus className="w-3 h-3 mr-1" /> Add Option
                    </Button>
                  </div>
                  <div className="space-y-2">
                    {q.options.map((opt, oIdx) => (
                      <div key={oIdx} className="flex items-center gap-2">
                        <button
                          onClick={() => updateOption(qIdx, oIdx, "is_correct", true)}
                          className={`p-1 rounded-full transition-colors shrink-0 ${opt.is_correct ? "text-primary" : "text-muted-foreground hover:text-primary/50"}`}
                          title="Mark as correct"
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
    </div>
  );
}
