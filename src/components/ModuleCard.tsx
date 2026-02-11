import { Lock, CheckCircle2, PlayCircle, Circle } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { cn } from "@/lib/utils";

interface ModuleCardProps {
  title: string;
  description?: string | null;
  orderNumber: number;
  isLocked: boolean;
  status: "not_started" | "in_progress" | "passed" | "failed";
  score?: number | null;
  onClick: () => void;
}

export function ModuleCard({ title, description, orderNumber, isLocked, status, score, onClick }: ModuleCardProps) {
  const statusConfig = {
    not_started: { icon: Circle, label: "Not Started", color: "text-muted-foreground" },
    in_progress: { icon: PlayCircle, label: "In Progress", color: "text-secondary" },
    passed: { icon: CheckCircle2, label: "Passed", color: "text-success" },
    failed: { icon: Circle, label: "Retry", color: "text-destructive" },
  };

  const { icon: StatusIcon, label, color } = statusConfig[status];

  return (
    <Card
      className={cn(
        "transition-all duration-200 cursor-pointer group",
        isLocked
          ? "opacity-60 cursor-not-allowed"
          : "hover:shadow-md hover:-translate-y-0.5",
        status === "passed" && "border-success/30 bg-success/5"
      )}
      onClick={() => !isLocked && onClick()}
    >
      <CardContent className="p-5">
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-start gap-3 flex-1">
            <div className={cn(
              "w-10 h-10 rounded-lg flex items-center justify-center text-sm font-bold shrink-0 font-display",
              isLocked ? "bg-muted text-muted-foreground" : "bg-primary text-primary-foreground"
            )}>
              {isLocked ? <Lock className="w-4 h-4" /> : orderNumber}
            </div>
            <div className="flex-1 min-w-0">
              <h3 className="font-semibold font-display text-card-foreground">{title}</h3>
              {description && (
                <p className="text-sm text-muted-foreground mt-1 line-clamp-2">{description}</p>
              )}
            </div>
          </div>
          <div className="flex flex-col items-end gap-1 shrink-0">
            <div className={cn("flex items-center gap-1 text-sm font-medium", color)}>
              <StatusIcon className="w-4 h-4" />
              <span>{label}</span>
            </div>
            {score !== null && score !== undefined && (
              <span className="text-xs text-muted-foreground">{Math.round(score)}%</span>
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
