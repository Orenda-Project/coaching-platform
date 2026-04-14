import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { ArrowLeft, Plus, Trash2, ChevronRight } from "lucide-react";
import { toast } from "sonner";

interface Scenario {
  id: string;
  unit_id: string;
  order_number: number;
  situation: string;
  question: string;
  difficulty: string;
  feedback_slides: string;
  reveal_content: string | null;
  deep_content: string | null;
  is_active: boolean;
}

export default function AdminScenarios() {
  const { unitId } = useParams<{ unitId: string }>();
  const navigate = useNavigate();

  const [scenarios, setScenarios] = useState<Scenario[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [showForm, setShowForm] = useState(false);
  const [unitTitle, setUnitTitle] = useState("");

  // Form state
  const [form, setForm] = useState({
    situation: "",
    question: "",
    difficulty: "medium",
    feedback_slides: "[]",
    reveal_content: "",
    deep_content: "",
    is_active: true,
  });

  // Load scenarios
  useEffect(() => {
    const loadScenarios = async () => {
      try {
        // Get unit title
        const { data: unitData } = await supabase
          .from("trainings")
          .select("title")
          .eq("id", unitId)
          .single();

        if (unitData) {
          setUnitTitle(unitData.title);
        }

        // Get scenarios
        const { data, error } = await supabase
          .from("scenarios")
          .select("*")
          .eq("unit_id", unitId)
          .order("order_number");

        if (error) throw error;
        setScenarios((data || []) as Scenario[]);
      } catch (error) {
        console.error("Error loading scenarios:", error);
        toast.error("Failed to load scenarios");
      } finally {
        setLoading(false);
      }
    };

    if (unitId) {
      loadScenarios();
    }
  }, [unitId]);

  const handleAddScenario = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!unitId) return;

    setSaving(true);
    try {
      // Validate feedback_slides JSON
      let feedbackSlides = [];
      if (form.feedback_slides.trim()) {
        try {
          feedbackSlides = JSON.parse(form.feedback_slides);
        } catch {
          toast.error("Invalid JSON in feedback_slides field");
          setSaving(false);
          return;
        }
      }

      const { error } = await supabase.from("scenarios").insert({
        unit_id: unitId,
        order_number: scenarios.length + 1,
        situation: form.situation,
        question: form.question,
        difficulty: form.difficulty,
        feedback_slides: feedbackSlides,
        reveal_content: form.reveal_content || null,
        deep_content: form.deep_content || null,
        is_active: form.is_active,
      } as Record<string, unknown>);

      if (error) throw error;

      toast.success("Scenario added");
      setForm({
        situation: "",
        question: "",
        difficulty: "medium",
        feedback_slides: "[]",
        reveal_content: "",
        deep_content: "",
        is_active: true,
      });
      setShowForm(false);

      // Reload
      const { data } = await supabase
        .from("scenarios")
        .select("*")
        .eq("unit_id", unitId)
        .order("order_number");

      setScenarios((data || []) as Scenario[]);
    } catch (error) {
      console.error("Error adding scenario:", error);
      toast.error("Failed to add scenario");
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteScenario = async (scenarioId: string) => {
    if (!confirm("Delete this scenario?")) return;

    try {
      const { error } = await supabase
        .from("scenarios")
        .delete()
        .eq("id", scenarioId);

      if (error) throw error;

      toast.success("Scenario deleted");
      setScenarios((prev) => prev.filter((s) => s.id !== scenarioId));
    } catch (error) {
      console.error("Error deleting scenario:", error);
      toast.error("Failed to delete scenario");
    }
  };

  if (loading) {
    return (
      <div className="h-64 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => navigate("/admin/modules")}
        >
          <ArrowLeft className="h-4 w-4 mr-1" />
          Back
        </Button>
        <h1 className="text-3xl font-bold">{unitTitle}: Scenarios</h1>
      </div>

      {/* Add Form */}
      {showForm && (
        <Card className="border-primary/20 bg-primary/5">
          <CardHeader>
            <CardTitle>Add Scenario</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleAddScenario} className="space-y-4">
              <div>
                <Label htmlFor="situation">Situation *</Label>
                <Textarea
                  id="situation"
                  value={form.situation}
                  onChange={(e) =>
                    setForm({ ...form, situation: e.target.value })
                  }
                  placeholder="Describe the real-world situation..."
                  required
                  className="mt-1"
                />
              </div>

              <div>
                <Label htmlFor="question">Question *</Label>
                <Textarea
                  id="question"
                  value={form.question}
                  onChange={(e) =>
                    setForm({ ...form, question: e.target.value })
                  }
                  placeholder="What's the decision the learner needs to make?"
                  required
                  className="mt-1"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="difficulty">Difficulty</Label>
                  <Select
                    value={form.difficulty}
                    onValueChange={(val) =>
                      setForm({ ...form, difficulty: val })
                    }
                  >
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="easy">Easy</SelectItem>
                      <SelectItem value="medium">Medium</SelectItem>
                      <SelectItem value="hard">Hard</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="flex items-end gap-2">
                  <div className="flex-1">
                    <Label htmlFor="is_active">Active</Label>
                    <div className="mt-2">
                      <Switch
                        id="is_active"
                        checked={form.is_active}
                        onCheckedChange={(checked) =>
                          setForm({ ...form, is_active: checked })
                        }
                      />
                    </div>
                  </div>
                </div>
              </div>

              <div>
                <Label htmlFor="reveal_content">Reveal Content (optional)</Label>
                <Textarea
                  id="reveal_content"
                  value={form.reveal_content}
                  onChange={(e) =>
                    setForm({ ...form, reveal_content: e.target.value })
                  }
                  placeholder="Short rationale shown after decision..."
                  className="mt-1 text-sm"
                />
              </div>

              <div>
                <Label htmlFor="deep_content">Deep Content (optional)</Label>
                <Textarea
                  id="deep_content"
                  value={form.deep_content}
                  onChange={(e) =>
                    setForm({ ...form, deep_content: e.target.value })
                  }
                  placeholder="Full context for 'Read more' expandable..."
                  className="mt-1 text-sm"
                />
              </div>

              <div>
                <Label htmlFor="feedback_slides">
                  Feedback Slides JSON (optional)
                </Label>
                <Textarea
                  id="feedback_slides"
                  value={form.feedback_slides}
                  onChange={(e) =>
                    setForm({ ...form, feedback_slides: e.target.value })
                  }
                  placeholder='[{"title":"Slide 1","body":"Content..."}]'
                  className="mt-1 text-xs font-mono"
                />
              </div>

              <div className="flex gap-2">
                <Button type="submit" disabled={saving}>
                  {saving ? "Saving..." : "Save Scenario"}
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setShowForm(false)}
                >
                  Cancel
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* List */}
      {scenarios.length === 0 ? (
        <Card className="border-dashed">
          <CardContent className="pt-8 text-center">
            <p className="text-muted-foreground mb-4">No scenarios yet</p>
            <Button onClick={() => setShowForm(true)}>
              <Plus className="h-4 w-4 mr-2" />
              Add First Scenario
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {!showForm && (
            <Button onClick={() => setShowForm(true)} variant="outline">
              <Plus className="h-4 w-4 mr-2" />
              Add Scenario
            </Button>
          )}

          {scenarios.map((scenario, idx) => (
            <Card key={scenario.id} className="hover:border-primary/50">
              <CardContent className="pt-4">
                <div className="flex items-start gap-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-xs font-mono bg-secondary text-secondary-foreground px-2 py-1 rounded">
                        #{idx + 1}
                      </span>
                      <span className="text-xs px-2 py-1 rounded bg-slate-100 text-slate-700">
                        {scenario.difficulty}
                      </span>
                      {!scenario.is_active && (
                        <span className="text-xs px-2 py-1 rounded bg-gray-100 text-gray-700">
                          Inactive
                        </span>
                      )}
                    </div>
                    <p className="font-semibold text-sm">
                      {scenario.situation.substring(0, 80)}...
                    </p>
                    <p className="text-xs text-muted-foreground mt-1">
                      {scenario.question.substring(0, 60)}...
                    </p>
                  </div>

                  <div className="flex gap-1">
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() =>
                        navigate(`/admin/scenarios/${scenario.id}/options`)
                      }
                    >
                      Options
                      <ChevronRight className="h-3 w-3 ml-1" />
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      onClick={() => handleDeleteScenario(scenario.id)}
                    >
                      <Trash2 className="h-4 w-4 text-red-500" />
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
