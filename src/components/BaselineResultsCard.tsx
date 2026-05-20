import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { PersonaBadge } from "./PersonaBadge";
import { CheckCircle2, ArrowRight } from "lucide-react";

interface BaselineResultsCardProps {
  baselineScore: number;
  persona: string;
  weakModules: string[];
}

export function BaselineResultsCard({
  baselineScore,
  persona,
  weakModules,
}: BaselineResultsCardProps) {
  const personaDescriptions: Record<
    string,
    { strengths: string[]; growth: string[] }
  > = {
    A: {
      strengths: [
        "Data-driven decision making",
        "Technical coaching depth",
        "Systematic approach",
      ],
      growth: [
        "Relationship warmth",
        "Adaptive communication",
        "Coaching flexibility",
      ],
    },
    B: {
      strengths: [
        "Building trust",
        "Collaborative problem-solving",
        "Responsive to feedback",
      ],
      growth: [
        "Data-driven decisions",
        "Advanced questioning",
        "Structured reflection",
      ],
    },
    C: {
      strengths: ["Teacher support", "Empathy and listening", "Field presence"],
      growth: [
        "Technical accuracy",
        "Data literacy",
        "Structured coaching cycles",
      ],
    },
    D: {
      strengths: ["Enthusiasm", "Team support", "Willingness to learn"],
      growth: [
        "Coaching fundamentals",
        "Observation skills",
        "Data interpretation",
      ],
    },
    E: {
      strengths: [
        "Openness to learning",
        "Commitment to growth",
        "Team readiness",
      ],
      growth: [
        "Coaching fundamentals",
        "Observation and listening",
        "Data-driven decisions",
        "Structured coaching cycles",
      ],
    },
  };

  const desc = personaDescriptions[persona] || personaDescriptions["B"];

  return (
    <Card className="mb-6">
      <CardHeader>
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
          <CardTitle className="text-lg">Your Coaching Profile</CardTitle>
          <PersonaBadge persona={persona} size="sm" />
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        <p className="text-sm text-muted-foreground">
          Based on your baseline score of{" "}
          <span className="font-semibold text-foreground">
            {baselineScore}%
          </span>
          , we've identified your coaching strengths and areas for growth.
        </p>
        {/* //test */}
        <div>
          <h3 className="font-semibold text-sm mb-2 text-foreground">
            Your Strengths
          </h3>
          <ul className="space-y-1">
            {desc.strengths.map((s) => (
              <li key={s} className="text-sm flex items-start gap-2">
                <CheckCircle2 className="w-4 h-4 text-green-600 mt-0.5 flex-shrink-0" />
                <span className="text-foreground">{s}</span>
              </li>
            ))}
          </ul>
        </div>

        <div>
          <h3 className="font-semibold text-sm mb-2 text-foreground">
            Areas for Growth (Your Focus)
          </h3>
          <ul className="space-y-1">
            {desc.growth.map((g) => (
              <li key={g} className="text-sm flex items-start gap-2">
                <ArrowRight className="w-4 h-4 text-blue-600 mt-0.5 flex-shrink-0" />
                <span className="text-foreground">{g}</span>
              </li>
            ))}
          </ul>
        </div>

        <div className="bg-muted p-3 rounded border-l-4 border-primary">
          <p className="text-sm font-semibold text-foreground mb-1">
            Next Step
          </p>
          {persona === "E" ? (
            <p className="text-sm text-muted-foreground">
              You'll go through all training modules to build strong
              foundations. Complete each module at your own pace to develop
              coaching expertise.
            </p>
          ) : (
            <p className="text-sm text-muted-foreground">
              Complete{" "}
              {weakModules.length > 0 ? weakModules.length : "recommended"}{" "}
              personalized modules to develop expertise across all coaching
              areas.
            </p>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
