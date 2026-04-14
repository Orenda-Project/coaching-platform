import { useRef, useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ChevronDown, ChevronUp } from "lucide-react";
import { useAnalytics } from "@/hooks/useAnalytics";
import { cn } from "@/lib/utils";

interface ExpandableDepthProps {
  content: string;
  scenarioId: string;
  unitId: string;
}

export default function ExpandableDepth({
  content,
  scenarioId,
  unitId,
}: ExpandableDepthProps) {
  const [expanded, setExpanded] = useState(false);
  const hasTracked = useRef(false);
  const { track } = useAnalytics();

  const handleToggle = () => {
    if (!expanded && !hasTracked.current) {
      hasTracked.current = true;
      track({
        event_type: "read_more_clicked",
        scenario_id: scenarioId,
        unit_id: unitId,
      });
    }
    setExpanded(!expanded);
  };

  if (!content) {
    return null;
  }

  return (
    <Card className="border-secondary/20 bg-secondary/5">
      <CardContent className="pt-4">
        <Button
          variant="ghost"
          onClick={handleToggle}
          className="w-full justify-start text-left font-semibold text-sm hover:bg-secondary/10"
        >
          {expanded ? (
            <ChevronUp className="h-4 w-4 mr-2 shrink-0" />
          ) : (
            <ChevronDown className="h-4 w-4 mr-2 shrink-0" />
          )}
          <span>{expanded ? "Hide" : "Read more"} — Full Context</span>
        </Button>

        {/* Expandable Content */}
        <div
          className={cn(
            "overflow-hidden transition-all duration-300",
            expanded ? "max-h-[2000px]" : "max-h-0"
          )}
        >
          <div className="mt-4 space-y-3 border-t border-secondary/20 pt-4 text-sm leading-relaxed text-foreground whitespace-pre-wrap">
            {content}
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
