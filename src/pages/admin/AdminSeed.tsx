import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { seedModule1 } from "@/lib/seedModule1";
import { seedModule2 } from "@/lib/seedModule2";
import { seedModule3 } from "@/lib/seedModule3";
import { seedModule4 } from "@/lib/seedModule4";
import { seedModule5 } from "@/lib/seedModule5";
import { seedModule6 } from "@/lib/seedModule6";
import { CheckCircle2, XCircle, Loader2, Database } from "lucide-react";

type SeedResult = { success: boolean; log: string[] } | null;

function SeedCard({
  title,
  description,
  onSeed,
  running,
  result,
}: {
  title: string;
  description: string;
  onSeed: () => void;
  running: boolean;
  result: SeedResult;
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-lg">
          <Database className="w-5 h-5 text-primary" />
          {title}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <p className="text-sm text-muted-foreground">{description}</p>
        <Button onClick={onSeed} disabled={running} className="w-full">
          {running ? (
            <><Loader2 className="w-4 h-4 mr-2 animate-spin" /> Seeding…</>
          ) : (
            `Seed ${title.split(":")[0]}`
          )}
        </Button>

        {result && (
          <div className="space-y-2">
            <div className={`flex items-center gap-2 font-semibold text-sm ${result.success ? "text-green-500" : "text-red-500"}`}>
              {result.success
                ? <><CheckCircle2 className="w-4 h-4" /> Seed completed successfully</>
                : <><XCircle className="w-4 h-4" /> Seed failed</>}
            </div>
            <div className="bg-muted rounded-lg p-3 max-h-64 overflow-y-auto font-mono text-xs space-y-0.5">
              {result.log.map((line, i) => (
                <div key={i} className={line.startsWith("✗") ? "text-red-400" : line.startsWith("✓") ? "text-green-400" : "text-muted-foreground"}>
                  {line}
                </div>
              ))}
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  );
}

export default function AdminSeed() {
  const [running1, setRunning1] = useState(false);
  const [result1, setResult1] = useState<SeedResult>(null);
  const [running2, setRunning2] = useState(false);
  const [result2, setResult2] = useState<SeedResult>(null);
  const [running3, setRunning3] = useState(false);
  const [result3, setResult3] = useState<SeedResult>(null);
  const [running4, setRunning4] = useState(false);
  const [result4, setResult4] = useState<SeedResult>(null);
  const [running5, setRunning5] = useState(false);
  const [result5, setResult5] = useState<SeedResult>(null);
  const [running6, setRunning6] = useState(false);
  const [result6, setResult6] = useState<SeedResult>(null);

  const makeSeedHandler = (
    fn: () => Promise<{ success: boolean; log: string[] }>,
    setRunning: (v: boolean) => void,
    setResult: (v: SeedResult) => void
  ) => async () => {
    setRunning(true);
    setResult(null);
    try {
      const res = await fn();
      setResult(res);
    } catch (e: unknown) {
      setResult({ success: false, log: [String(e)] });
    } finally {
      setRunning(false);
    }
  };

  return (
    <div className="max-w-2xl space-y-6">
      <div>
        <h1 className="text-2xl font-display font-bold text-foreground">Seed Data</h1>
        <p className="text-muted-foreground mt-1">Run seed scripts to populate module content.</p>
      </div>

      <SeedCard
        title="Module 1: Universal Core Refresher"
        description="Seeds all 7 units (1.0–1.6) with slides, scenario-based training, and quiz questions. Safe to re-run — uses upsert on existing records."
        onSeed={makeSeedHandler(seedModule1, setRunning1, setResult1)}
        running={running1}
        result={result1}
      />

      <SeedCard
        title="Module 2: The Partnership Foundation"
        description="Seeds 3 units (2.1–2.3): Status & Psychological Safety, Evidence-Based Dialogue, Goal-Setting as Co-Creation. Safe to re-run."
        onSeed={makeSeedHandler(seedModule2, setRunning2, setResult2)}
        running={running2}
        result={result2}
      />

      <SeedCard
        title="Module 3: The Mirror Specialist"
        description="Seeds 3 units (3.1–3.3): The Mirror Specialist, The Artifact Architect, Data Into Dialogue. Safe to re-run."
        onSeed={makeSeedHandler(seedModule3, setRunning3, setResult3)}
        running={running3}
        result={result3}
      />

      <SeedCard
        title="Module 4: Digital & Data Intelligence"
        description="Seeds 4 units (4.1–4.4): Digital Journal, Adaptive Facilitator, Partnership Advocate, Consistency Guardian (WRER). Safe to re-run."
        onSeed={makeSeedHandler(seedModule4, setRunning4, setResult4)}
        running={running4}
        result={result4}
      />

      <SeedCard
        title="Module 5: The Instructional Catalyst"
        description="Seeds 4 units (5.1–5.4): Power of Choice, Finding the Why, Closing the Loop, Diagnosing the 3 Loops. Safe to re-run."
        onSeed={makeSeedHandler(seedModule5, setRunning5, setResult5)}
        running={running5}
        result={result5}
      />

      <SeedCard
        title="Module 6: The Excellence Loop"
        description="Seeds 4 units (6.1–6.4): Closing the Loop, Protocol Guardrail, Responsive Contextualization, Reciprocity (Ethical Defense). Safe to re-run."
        onSeed={makeSeedHandler(seedModule6, setRunning6, setResult6)}
        running={running6}
        result={result6}
      />
    </div>
  );
}
