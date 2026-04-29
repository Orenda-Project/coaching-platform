import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { CheckCircle2, Circle, ArrowLeft } from "lucide-react";
import { toast } from "sonner";

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
  situation: string;
  question: string;
}

export default function AdminScenarioOptions() {
  const { scenarioId } = useParams<{ scenarioId: string }>();
  const navigate = useNavigate();

  const [scenario, setScenario] = useState<Scenario | null>(null);
  const [options, setOptions] = useState<ScenarioOption[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  // Load scenario and options
  useEffect(() => {
    const load = async () => {
      try {
        if (!scenarioId) return;

        // Get scenario
        const { data: scenarioData } = await supabase
          .from("scenarios")
          .select("*")
          .eq("id", scenarioId)
          .single();

        if (scenarioData) {
          setScenario(scenarioData as Scenario);
        }

        // Get options
        const { data: optionsData } = await supabase
          .from("scenario_options")
          .select("*")
          .eq("scenario_id", scenarioId)
          .order("option_letter");

        if (!optionsData || optionsData.length === 0) {
          // Create empty options if none exist
          const newOptions: ScenarioOption[] = [
            {
              id: `${scenarioId}-A`,
              scenario_id: scenarioId,
              option_letter: "A",
              option_text: "",
              is_correct: false,
              rationale: "",
              principle_tag: null,
            },
            {
              id: `${scenarioId}-B`,
              scenario_id: scenarioId,
              option_letter: "B",
              option_text: "",
              is_correct: false,
              rationale: "",
              principle_tag: null,
            },
            {
              id: `${scenarioId}-C`,
              scenario_id: scenarioId,
              option_letter: "C",
              option_text: "",
              is_correct: false,
              rationale: "",
              principle_tag: null,
            },
            {
              id: `${scenarioId}-D`,
              scenario_id: scenarioId,
              option_letter: "D",
              option_text: "",
              is_correct: false,
              rationale: "",
              principle_tag: null,
            },
          ];
          setOptions(newOptions);
        } else {
          setOptions(optionsData as ScenarioOption[]);
        }
      } catch (error) {
        console.error("Error loading options:", error);
        toast.error("Failed to load options");
      } finally {
        setLoading(false);
      }
    };

    load();
  }, [scenarioId]);

  const handleUpdateOption = (
    index: number,
    field: keyof ScenarioOption,
    value: unknown
  ) => {
    const updated = [...options];
    (updated[index] as unknown as Record<string, unknown>)[field] = value;

    // If marking as correct, unmark others
    if (field === "is_correct" && value) {
      updated.forEach((opt, idx) => {
        if (idx !== index) {
          opt.is_correct = false;
        }
      });
    }

    setOptions(updated);
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      // Ensure at least one option is marked correct
      const hasCorrect = options.some((opt) => opt.is_correct);
      if (!hasCorrect) {
        toast.error("Please mark one option as correct");
        setSaving(false);
        return;
      }

      // Upsert all options
      const { error } = await supabase
        .from("scenario_options")
        .upsert(
          options.map((opt) => ({
            scenario_id: opt.scenario_id,
            option_letter: opt.option_letter,
            option_text: opt.option_text,
            is_correct: opt.is_correct,
            rationale: opt.rationale,
            principle_tag: opt.principle_tag || null,
          })) as never,
          { onConflict: "scenario_id,option_letter" }
        );

      if (error) throw error;

      toast.success("Options saved");
      // Navigate back to scenarios
      navigate(-1);
    } catch (error) {
      console.error("Error saving options:", error);
      toast.error("Failed to save options");
    } finally {
      setSaving(false);
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
        <Button variant="ghost" size="sm" onClick={() => navigate(-1)}>
          <ArrowLeft className="h-4 w-4 mr-1" />
          Back
        </Button>
        <h1 className="text-3xl font-bold">Scenario Options (A/B/C/D)</h1>
      </div>

      {/* Scenario Context */}
      {scenario && (
        <Card className="bg-muted/50">
          <CardContent className="pt-4">
            <p className="text-sm font-semibold text-muted-foreground mb-1">
              SITUATION:
            </p>
            <p className="text-sm mb-3">{scenario.situation}</p>
            <p className="text-sm font-semibold text-muted-foreground mb-1">
              QUESTION:
            </p>
            <p className="text-sm">{scenario.question}</p>
          </CardContent>
        </Card>
      )}

      {/* Options Editor */}
      <div className="space-y-4">
        {options.map((option, idx) => (
          <Card key={option.id}>
            <CardContent className="pt-4">
              <div className="space-y-3">
                {/* Letter + Correct */}
                <div className="flex items-center gap-3">
                  <div className="flex-shrink-0 w-12 h-12 rounded-lg bg-muted flex items-center justify-center font-bold text-lg">
                    {option.option_letter}
                  </div>
                  <div className="flex-1">
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() =>
                        handleUpdateOption(idx, "is_correct", !option.is_correct)
                      }
                      className="gap-2"
                    >
                      {option.is_correct ? (
                        <CheckCircle2 className="h-4 w-4 text-green-600" />
                      ) : (
                        <Circle className="h-4 w-4 text-gray-400" />
                      )}
                      <span className="text-xs">
                        {option.is_correct ? "Correct Answer" : "Mark Correct"}
                      </span>
                    </Button>
                  </div>
                </div>

                {/* Option Text */}
                <div>
                  <Label htmlFor={`option-text-${idx}`} className="text-xs">
                    Option Text *
                  </Label>
                  <Textarea
                    id={`option-text-${idx}`}
                    value={option.option_text}
                    onChange={(e) =>
                      handleUpdateOption(idx, "option_text", e.target.value)
                    }
                    placeholder={`Option ${option.option_letter} text...`}
                    className="mt-1 text-sm"
                  />
                </div>

                {/* Rationale */}
                <div>
                  <Label htmlFor={`rationale-${idx}`} className="text-xs">
                    Rationale *
                  </Label>
                  <Textarea
                    id={`rationale-${idx}`}
                    value={option.rationale}
                    onChange={(e) =>
                      handleUpdateOption(idx, "rationale", e.target.value)
                    }
                    placeholder="Why is this correct or incorrect?"
                    className="mt-1 text-sm"
                  />
                </div>

                {/* Principle Tag */}
                <div>
                  <Label
                    htmlFor={`principle-tag-${idx}`}
                    className="text-xs"
                  >
                    Principle Tag (optional)
                  </Label>
                  <Input
                    id={`principle-tag-${idx}`}
                    value={option.principle_tag || ""}
                    onChange={(e) =>
                      handleUpdateOption(idx, "principle_tag", e.target.value)
                    }
                    placeholder="e.g., Confidentiality, Integrity..."
                    className="mt-1 text-sm"
                  />
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Save Button */}
      <div className="flex gap-2">
        <Button onClick={handleSave} disabled={saving}>
          {saving ? "Saving..." : "Save Options"}
        </Button>
        <Button variant="outline" onClick={() => navigate(-1)}>
          Cancel
        </Button>
      </div>
    </div>
  );
}
