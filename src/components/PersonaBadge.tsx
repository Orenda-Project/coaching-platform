import { cn } from "@/lib/utils";

const personaConfig = {
  A: { label: "Persona A", className: "persona-badge-a", description: "Advanced" },
  B: { label: "Persona B", className: "persona-badge-b", description: "Proficient" },
  C: { label: "Persona C", className: "persona-badge-c", description: "Intermediate" },
  D: { label: "Persona D", className: "persona-badge-d", description: "Foundational" },
  E: { label: "Persona E", className: "persona-badge-e", description: "Entry-level" },
};

interface PersonaBadgeProps {
  persona: string;
  size?: "sm" | "md" | "lg";
  showDescription?: boolean;
}

export function PersonaBadge({ persona, size = "md", showDescription = false }: PersonaBadgeProps) {
  const config = personaConfig[persona as keyof typeof personaConfig];
  if (!config) return null;

  const sizeClasses = {
    sm: "px-2 py-0.5 text-xs",
    md: "px-3 py-1 text-sm",
    lg: "px-4 py-2 text-base",
  };

  return (
    <div className="flex items-center gap-2">
      <span className={cn("rounded-full font-semibold inline-flex items-center", sizeClasses[size], config.className)}>
        {config.label}
      </span>
      {showDescription && (
        <span className="text-sm text-muted-foreground">{config.description}</span>
      )}
    </div>
  );
}
