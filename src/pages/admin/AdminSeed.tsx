import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { seedModule1 } from "@/lib/seedModule1";
import { CheckCircle2, XCircle, Loader2, Database } from "lucide-react";

export default function AdminSeed() {
  const [running, setRunning] = useState(false);
  const [result, setResult] = useState<{ success: boolean; log: string[] } | null>(null);

  const handleSeed = async () => {
    setRunning(true);
    setResult(null);
    try {
      const res = await seedModule1();
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

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-lg">
            <Database className="w-5 h-5 text-primary" />
            Module 1: Universal Core Refresher
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-sm text-muted-foreground">
            Seeds all 7 units (1.0–1.6) with slides, scenario-based training, and quiz questions.
            Safe to re-run — uses upsert on existing records.
          </p>
          <Button onClick={handleSeed} disabled={running} className="w-full">
            {running ? (
              <><Loader2 className="w-4 h-4 mr-2 animate-spin" /> Seeding…</>
            ) : (
              "Seed Module 1"
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
    </div>
  );
}
