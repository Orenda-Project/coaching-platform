import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { CheckCircle2, XCircle, AlertCircle, RotateCcw } from "lucide-react";

export interface ScenarioBranch {
  id: string;
  text: string;
  isCorrect: boolean;
  rationale: string;
  principle?: string;
}

export interface ScenarioStep {
  id: string;
  situation: string;
  context?: string;
  question: string;
  branches: ScenarioBranch[];
}

interface ScenarioPlayerProps {
  title: string;
  description: string;
  steps: ScenarioStep[];
  onCompleted: () => void;
  completed: boolean;
}

type StepResult = { chosen: string; correct: boolean; rationale: string; principle?: string };

export default function ScenarioPlayer({ title, description, steps, onCompleted, completed }: ScenarioPlayerProps) {
  const [currentStep, setCurrentStep] = useState(0);
  const [chosen, setChosen] = useState<string | null>(null);
  const [revealed, setRevealed] = useState(false);
  const [results, setResults] = useState<StepResult[]>([]);
  const [done, setDone] = useState(false);

  const step = steps[currentStep];
  const progress = ((currentStep + (revealed ? 1 : 0)) / steps.length) * 100;

  const handleChoose = (branchId: string) => {
    if (revealed) return;
    setChosen(branchId);
  };

  const handleReveal = () => {
    if (!chosen) return;
    setRevealed(true);
  };

  const handleNext = () => {
    const branch = step.branches.find((b) => b.id === chosen)!;
    const newResults = [...results, {
      chosen: branch.text,
      correct: branch.isCorrect,
      rationale: branch.rationale,
      principle: branch.principle,
    }];
    setResults(newResults);

    if (currentStep + 1 >= steps.length) {
      setDone(true);
      onCompleted();
    } else {
      setCurrentStep((i) => i + 1);
      setChosen(null);
      setRevealed(false);
    }
  };

  const handleRetry = () => {
    setCurrentStep(0);
    setChosen(null);
    setRevealed(false);
    setResults([]);
    setDone(false);
  };

  const chosenBranch = step?.branches.find((b) => b.id === chosen);
  const score = results.filter((r) => r.correct).length;

  if (done) {
    const pct = Math.round((score / steps.length) * 100);
    return (
      <div className="space-y-4">
        <Card className="border-primary/20">
          <CardContent className="p-8 text-center space-y-4">
            <div className={`w-16 h-16 rounded-full mx-auto flex items-center justify-center ${pct >= 70 ? "bg-green-500/10" : "bg-orange-500/10"}`}>
              {pct >= 70
                ? <CheckCircle2 className="w-8 h-8 text-green-500" />
                : <AlertCircle className="w-8 h-8 text-orange-500" />}
            </div>
            <h3 className="text-xl font-display font-bold text-foreground">Scenario Complete</h3>
            <p className="text-muted-foreground">
              You made the right call in <span className="font-bold text-foreground">{score} of {steps.length}</span> situations ({pct}%)
            </p>

            {/* Result breakdown */}
            <div className="space-y-3 text-left mt-4">
              {steps.map((s, i) => {
                const r = results[i];
                return (
                  <div key={i} className={`p-3 rounded-lg border ${r?.correct ? "border-green-500/30 bg-green-500/5" : "border-red-500/30 bg-red-500/5"}`}>
                    <div className="flex items-start gap-2">
                      {r?.correct
                        ? <CheckCircle2 className="w-4 h-4 text-green-500 mt-0.5 shrink-0" />
                        : <XCircle className="w-4 h-4 text-red-500 mt-0.5 shrink-0" />}
                      <div>
                        <p className="text-xs font-semibold text-foreground mb-1">Situation {i + 1}: {s.situation.slice(0, 60)}…</p>
                        <p className="text-xs text-muted-foreground">You chose: "{r?.chosen}"</p>
                        <p className="text-xs text-primary mt-1">{r?.rationale}</p>
                        {r?.principle && <p className="text-xs text-muted-foreground mt-0.5">Principle: {r.principle}</p>}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>

            <Button variant="outline" onClick={handleRetry} className="mt-2">
              <RotateCcw className="w-4 h-4 mr-1" /> Try Again
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Progress */}
      <div className="flex items-center justify-between text-sm text-muted-foreground mb-1">
        <span>Situation {currentStep + 1} of {steps.length}</span>
        {completed && (
          <span className="flex items-center gap-1 text-green-500 font-medium">
            <CheckCircle2 className="w-4 h-4" /> Completed
          </span>
        )}
      </div>
      <Progress value={progress} className="h-1.5" />

      {/* Scenario header */}
      <Card className="border-secondary/30 bg-secondary/5">
        <CardContent className="p-5">
          <p className="text-xs font-semibold text-secondary uppercase tracking-wide mb-1">Scenario</p>
          <p className="font-medium text-foreground">{step.situation}</p>
          {step.context && <p className="text-sm text-muted-foreground mt-2">{step.context}</p>}
        </CardContent>
      </Card>

      {/* Question */}
      <p className="font-semibold text-foreground">{step.question}</p>

      {/* Branches */}
      <div className="space-y-2">
        {step.branches.map((branch) => {
          const isChosen = chosen === branch.id;
          let borderClass = "border-border hover:border-primary";
          if (revealed && isChosen) {
            borderClass = branch.isCorrect ? "border-green-500 bg-green-500/10" : "border-red-500 bg-red-500/10";
          } else if (revealed && branch.isCorrect) {
            borderClass = "border-green-500/50 bg-green-500/5";
          } else if (isChosen && !revealed) {
            borderClass = "border-primary bg-primary/10";
          }

          return (
            <button
              key={branch.id}
              onClick={() => handleChoose(branch.id)}
              disabled={revealed}
              className={`w-full text-left p-4 rounded-lg border-2 transition-all ${borderClass}`}
            >
              <div className="flex items-start gap-3">
                <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center shrink-0 mt-0.5 ${isChosen ? "border-primary bg-primary" : "border-muted-foreground"}`}>
                  {isChosen && <div className="w-2 h-2 rounded-full bg-white" />}
                </div>
                <div className="flex-1">
                  <p className="text-sm text-foreground">{branch.text}</p>
                  {revealed && isChosen && (
                    <div className="mt-2 flex items-start gap-1">
                      {branch.isCorrect
                        ? <CheckCircle2 className="w-4 h-4 text-green-500 shrink-0 mt-0.5" />
                        : <XCircle className="w-4 h-4 text-red-500 shrink-0 mt-0.5" />}
                      <p className="text-xs text-muted-foreground">{branch.rationale}</p>
                    </div>
                  )}
                  {revealed && !isChosen && branch.isCorrect && (
                    <p className="text-xs text-green-600 mt-1 font-medium">✓ This was the best response</p>
                  )}
                </div>
              </div>
            </button>
          );
        })}
      </div>

      {/* Actions */}
      <div className="flex gap-3 pt-2">
        {!revealed ? (
          <Button onClick={handleReveal} disabled={!chosen} className="flex-1">
            Check My Response
          </Button>
        ) : (
          <Button onClick={handleNext} className="flex-1 bg-primary hover:bg-primary/90">
            {currentStep + 1 >= steps.length ? "See Results" : "Next Situation"}
          </Button>
        )}
      </div>
    </div>
  );
}
