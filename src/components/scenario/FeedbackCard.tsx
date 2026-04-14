import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { CheckCircle2, XCircle } from "lucide-react";
import { cn } from "@/lib/utils";

interface FeedbackCardProps {
  isCorrect: boolean;
  chosenOptionText: string;
  correctOptionText: string;
  rationale: string;
  principleTag?: string | null;
  onContinue: () => void;
  isLast: boolean;
}

export default function FeedbackCard({
  isCorrect,
  chosenOptionText,
  correctOptionText,
  rationale,
  principleTag,
  onContinue,
  isLast,
}: FeedbackCardProps) {
  return (
    <Card
      className={cn(
        "border-2",
        isCorrect
          ? "border-green-500/30 bg-green-500/5"
          : "border-red-500/30 bg-red-500/5"
      )}
    >
      <CardHeader>
        <div className="flex items-center gap-3">
          {isCorrect ? (
            <CheckCircle2 className="h-6 w-6 text-green-500" />
          ) : (
            <XCircle className="h-6 w-6 text-red-500" />
          )}
          <CardTitle className="text-xl">
            {isCorrect ? "Correct!" : "Not quite right"}
          </CardTitle>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Your Answer */}
        <div className="space-y-1.5">
          <p className="text-xs font-semibold text-muted-foreground uppercase">
            Your Answer:
          </p>
          <p className="text-sm text-foreground">{chosenOptionText}</p>
        </div>

        {/* Correct Answer (if wrong) */}
        {!isCorrect && (
          <div className="space-y-1.5 border-t border-secondary/20 pt-4">
            <p className="text-xs font-semibold text-muted-foreground uppercase">
              Correct Answer:
            </p>
            <p className="text-sm text-foreground">{correctOptionText}</p>
          </div>
        )}

        {/* Rationale */}
        <div className="border-t border-secondary/20 pt-4">
          <p className="text-xs font-semibold text-muted-foreground uppercase mb-2">
            Rationale:
          </p>
          <p className="text-sm leading-relaxed text-foreground">{rationale}</p>
          {principleTag && (
            <div className="mt-3">
              <Badge variant="secondary" className="text-xs">
                {principleTag}
              </Badge>
            </div>
          )}
        </div>

        {/* Continue Button */}
        <Button onClick={onContinue} className="w-full mt-4" size="lg">
          {isLast ? "See Summary" : "Continue"}
        </Button>
      </CardContent>
    </Card>
  );
}
