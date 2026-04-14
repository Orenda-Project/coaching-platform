import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";
import { cn } from "@/lib/utils";

export interface ScenarioOption {
  id: string;
  option_letter: string;
  option_text: string;
}

interface ScenarioCardProps {
  situation: string;
  question: string;
  options: ScenarioOption[];
  selectedLetter: string | null;
  onSelect: (letter: string) => void;
  onSubmit: () => void;
  locked: boolean;
  isSubmitting?: boolean;
}

export default function ScenarioCard({
  situation,
  question,
  options,
  selectedLetter,
  onSelect,
  onSubmit,
  locked,
  isSubmitting = false,
}: ScenarioCardProps) {
  return (
    <Card className="border-secondary/30 bg-secondary/5">
      <CardHeader>
        <CardTitle className="text-xl">Scenario</CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Situation */}
        <div className="space-y-2">
          <p className="text-sm font-semibold text-muted-foreground">SITUATION:</p>
          <p className="text-base leading-relaxed text-foreground">{situation}</p>
        </div>

        {/* Question */}
        <div className="space-y-3">
          <p className="text-sm font-semibold text-muted-foreground">
            Question: {question}
          </p>
        </div>

        {/* Options */}
        <div className="space-y-3 py-4 border-t border-secondary/20">
          <p className="text-sm font-semibold text-muted-foreground">
            How do you respond?
          </p>
          <RadioGroup value={selectedLetter ?? ""} onValueChange={onSelect}>
            {options.map((option) => (
              <div
                key={option.id}
                className={cn(
                  "flex items-start space-x-3 rounded-md border p-4 transition-colors",
                  selectedLetter === option.option_letter
                    ? "border-primary bg-primary/10"
                    : "border-secondary/20 hover:bg-secondary/5",
                  locked && "opacity-60 cursor-not-allowed"
                )}
              >
                <RadioGroupItem
                  value={option.option_letter}
                  id={option.id}
                  disabled={locked}
                  className="mt-1"
                />
                <Label
                  htmlFor={option.id}
                  className="flex-1 cursor-pointer font-medium"
                >
                  <span className="font-bold text-primary">
                    {option.option_letter}.
                  </span>{" "}
                  {option.option_text}
                </Label>
              </div>
            ))}
          </RadioGroup>
        </div>

        {/* Submit Button */}
        <Button
          onClick={onSubmit}
          disabled={!selectedLetter || locked || isSubmitting}
          className="w-full"
          size="lg"
        >
          {isSubmitting ? "Submitting..." : "Submit Answer"}
        </Button>
      </CardContent>
    </Card>
  );
}
