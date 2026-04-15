import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { BarChart2, Users, TrendingUp, Search, AlertTriangle, CheckCircle2, Clock, Flag } from "lucide-react";

const REGIONS = [
  { value: "", label: "All Regions" },
  { value: "islamabad", label: "Islamabad (ICT)" },
  { value: "balochistan", label: "Balochistan" },
  { value: "punjab", label: "Punjab" },
  { value: "rawalpindi", label: "Rawalpindi (Rwp)" },
];

const PERSONAS = [
  { value: "", label: "All Personas" },
  { value: "A", label: "A — Advanced" },
  { value: "B", label: "B — Intermediate" },
  { value: "C", label: "C — Developing" },
  { value: "D", label: "D — Entry-level" },
];

interface ProfileRow {
  id: string;
  full_name: string | null;
  phone: string;
  region: string | null;
  school_id: string | null;
  persona: string | null;
  baseline_completed: boolean;
  baseline_score: number | null;
  baseline_attempt_count: number;
  endline_completed: boolean;
  endline_score: number | null;
  endline_attempt_count: number;
  weak_modules: string[];
  created_at: string;
}

interface TrainingProgressRow {
  user_id: string;
  training_id: string;
  passed: boolean;
  score: number | null;
  attempt_count: number;
  tab_switch_count: number;
  fullscreen_violations: number;
  flagged_for_review: boolean;
  content_completed: boolean;
}

interface CoachRow extends ProfileRow {
  trainings_passed: number;
  trainings_started: number;
  avg_quiz_score: number | null;
  total_tab_switches: number;
  flagged: boolean;
}

function regionLabel(val: string | null): string {
  const found = REGIONS.find((r) => r.value === val);
  return found && found.value ? found.label : val || "—";
}

function personaColor(p: string | null): string {
  if (p === "A") return "bg-green-100 text-green-700";
  if (p === "B") return "bg-blue-100 text-blue-700";
  if (p === "C") return "bg-yellow-100 text-yellow-700";
  if (p === "D") return "bg-orange-100 text-orange-700";
  return "bg-muted text-muted-foreground";
}

export default function AdminAnalytics() {
  const [coaches, setCoaches] = useState<CoachRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [regionFilter, setRegionFilter] = useState("");
  const [personaFilter, setPersonaFilter] = useState("");
  const [showFlaggedOnly, setShowFlaggedOnly] = useState(false);

  useEffect(() => {
    async function load() {
      setLoading(true);
      try {
        const [{ data: profiles }, { data: progress }] = await Promise.all([
          supabase.from("profiles").select("*").order("created_at", { ascending: false }),
          supabase.from("training_progress").select("user_id, training_id, passed, score, attempt_count, tab_switch_count, fullscreen_violations, flagged_for_review, content_completed"),
        ]);

        const progressByUser = new Map<string, TrainingProgressRow[]>();
        for (const row of (progress || []) as TrainingProgressRow[]) {
          if (!progressByUser.has(row.user_id)) progressByUser.set(row.user_id, []);
          progressByUser.get(row.user_id)!.push(row);
        }

        const rows: CoachRow[] = ((profiles || []) as ProfileRow[]).map((p) => {
          const tp = progressByUser.get(p.id) || [];
          const passed = tp.filter((r) => r.passed).length;
          const started = tp.length;
          const scores = tp.map((r) => r.score).filter((s): s is number => s !== null);
          const avg = scores.length ? Math.round(scores.reduce((a, b) => a + b, 0) / scores.length) : null;
          const tabs = tp.reduce((a, r) => a + r.tab_switch_count, 0);
          const flagged = tp.some((r) => r.flagged_for_review);
          return { ...p, trainings_passed: passed, trainings_started: started, avg_quiz_score: avg, total_tab_switches: tabs, flagged };
        });

        setCoaches(rows);
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  const filtered = coaches.filter((c) => {
    if (regionFilter && c.region !== regionFilter) return false;
    if (personaFilter && c.persona !== personaFilter) return false;
    if (showFlaggedOnly && !c.flagged) return false;
    if (search) {
      const q = search.toLowerCase();
      const name = (c.full_name || "").toLowerCase();
      const phone = (c.phone || "").toLowerCase();
      const school = (c.school_id || "").toLowerCase();
      if (!name.includes(q) && !phone.includes(q) && !school.includes(q)) return false;
    }
    return true;
  });

  // Summary stats from filtered set
  const total = filtered.length;
  const baselineCompleted = filtered.filter((c) => c.baseline_completed).length;
  const endlineCompleted = filtered.filter((c) => c.endline_completed).length;
  const flaggedCount = filtered.filter((c) => c.flagged).length;
  const avgBaseline = baselineCompleted
    ? Math.round(filtered.filter((c) => c.baseline_score !== null).reduce((a, c) => a + (c.baseline_score || 0), 0) / (filtered.filter((c) => c.baseline_score !== null).length || 1))
    : null;
  const avgEndline = endlineCompleted
    ? Math.round(filtered.filter((c) => c.endline_score !== null).reduce((a, c) => a + (c.endline_score || 0), 0) / (filtered.filter((c) => c.endline_score !== null).length || 1))
    : null;

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div>
        <h1 className="text-2xl font-display font-bold text-foreground flex items-center gap-2">
          <BarChart2 className="w-6 h-6 text-primary" />
          Analytics Dashboard
        </h1>
        <p className="text-sm text-muted-foreground mt-1">Coach-level data: assessments, training progress, and integrity flags</p>
      </div>

      {/* Summary cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div className="bg-card border border-border rounded-lg p-4">
          <p className="text-xs font-semibold text-muted-foreground uppercase mb-1 flex items-center gap-1">
            <Users className="w-3 h-3" /> Coaches
          </p>
          <p className="text-2xl font-bold text-foreground">{total}</p>
        </div>
        <div className="bg-card border border-border rounded-lg p-4">
          <p className="text-xs font-semibold text-muted-foreground uppercase mb-1 flex items-center gap-1">
            <CheckCircle2 className="w-3 h-3 text-green-600" /> Baseline Done
          </p>
          <p className="text-2xl font-bold text-foreground">{baselineCompleted}</p>
          {avgBaseline !== null && <p className="text-xs text-muted-foreground mt-1">Avg: {avgBaseline}%</p>}
        </div>
        <div className="bg-card border border-border rounded-lg p-4">
          <p className="text-xs font-semibold text-muted-foreground uppercase mb-1 flex items-center gap-1">
            <TrendingUp className="w-3 h-3 text-blue-600" /> Endline Done
          </p>
          <p className="text-2xl font-bold text-foreground">{endlineCompleted}</p>
          {avgEndline !== null && <p className="text-xs text-muted-foreground mt-1">Avg: {avgEndline}%</p>}
        </div>
        <div className="bg-card border border-border rounded-lg p-4">
          <p className="text-xs font-semibold text-muted-foreground uppercase mb-1 flex items-center gap-1">
            <Flag className="w-3 h-3 text-red-500" /> Flagged
          </p>
          <p className="text-2xl font-bold text-foreground">{flaggedCount}</p>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3 items-end bg-card border border-border rounded-lg p-4">
        <div className="flex-1 min-w-48">
          <Label className="text-xs mb-1 block">Search</Label>
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-3 h-3 text-muted-foreground" />
            <Input
              className="pl-8 h-8 text-sm"
              placeholder="Name, phone, school..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
        </div>
        <div>
          <Label className="text-xs mb-1 block">Region</Label>
          <select
            value={regionFilter}
            onChange={(e) => setRegionFilter(e.target.value)}
            className="h-8 px-3 border border-input rounded-md bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          >
            {REGIONS.map((r) => <option key={r.value} value={r.value}>{r.label}</option>)}
          </select>
        </div>
        <div>
          <Label className="text-xs mb-1 block">Persona</Label>
          <select
            value={personaFilter}
            onChange={(e) => setPersonaFilter(e.target.value)}
            className="h-8 px-3 border border-input rounded-md bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          >
            {PERSONAS.map((p) => <option key={p.value} value={p.value}>{p.label}</option>)}
          </select>
        </div>
        <div className="flex items-center gap-2 self-center pt-4">
          <input
            type="checkbox"
            id="flagged-only"
            checked={showFlaggedOnly}
            onChange={(e) => setShowFlaggedOnly(e.target.checked)}
            className="h-4 w-4 rounded border-input"
          />
          <label htmlFor="flagged-only" className="text-sm text-foreground whitespace-nowrap flex items-center gap-1">
            <AlertTriangle className="w-3 h-3 text-amber-500" /> Flagged only
          </label>
        </div>
      </div>

      {/* Table */}
      {loading ? (
        <div className="flex items-center justify-center py-16">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
        </div>
      ) : filtered.length === 0 ? (
        <div className="text-center py-16 text-muted-foreground text-sm">No coaches match the current filters.</div>
      ) : (
        <div className="overflow-x-auto rounded-lg border border-border">
          <table className="w-full text-sm">
            <thead className="bg-muted text-muted-foreground">
              <tr>
                <th className="text-left px-3 py-2 font-semibold whitespace-nowrap">Coach</th>
                <th className="text-left px-3 py-2 font-semibold whitespace-nowrap">Region</th>
                <th className="text-left px-3 py-2 font-semibold whitespace-nowrap">School</th>
                <th className="text-center px-3 py-2 font-semibold whitespace-nowrap">Persona</th>
                <th className="text-center px-3 py-2 font-semibold whitespace-nowrap">Baseline</th>
                <th className="text-center px-3 py-2 font-semibold whitespace-nowrap">Endline</th>
                <th className="text-center px-3 py-2 font-semibold whitespace-nowrap">Modules</th>
                <th className="text-center px-3 py-2 font-semibold whitespace-nowrap">Avg Quiz</th>
                <th className="text-center px-3 py-2 font-semibold whitespace-nowrap">Tab Sw.</th>
                <th className="text-center px-3 py-2 font-semibold whitespace-nowrap">Flag</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border bg-card">
              {filtered.map((c) => (
                <tr key={c.id} className={c.flagged ? "bg-red-50/40" : "hover:bg-muted/30 transition-colors"}>
                  {/* Coach */}
                  <td className="px-3 py-2 whitespace-nowrap">
                    <p className="font-medium text-foreground">{c.full_name || "—"}</p>
                    <p className="text-xs text-muted-foreground">{c.phone || "—"}</p>
                  </td>
                  {/* Region */}
                  <td className="px-3 py-2 whitespace-nowrap text-foreground">{regionLabel(c.region)}</td>
                  {/* School */}
                  <td className="px-3 py-2 whitespace-nowrap text-foreground max-w-32 truncate">{c.school_id || "—"}</td>
                  {/* Persona */}
                  <td className="px-3 py-2 text-center">
                    {c.persona ? (
                      <span className={`inline-block px-2 py-0.5 rounded-full text-xs font-semibold ${personaColor(c.persona)}`}>{c.persona}</span>
                    ) : (
                      <span className="text-xs text-muted-foreground">—</span>
                    )}
                  </td>
                  {/* Baseline */}
                  <td className="px-3 py-2 text-center whitespace-nowrap">
                    {c.baseline_completed ? (
                      <span className="font-semibold text-green-700">{c.baseline_score ?? "—"}%</span>
                    ) : (
                      <span className="text-xs text-muted-foreground flex items-center justify-center gap-1">
                        <Clock className="w-3 h-3" /> Pending
                      </span>
                    )}
                    {c.baseline_attempt_count > 0 && (
                      <p className="text-xs text-muted-foreground">{c.baseline_attempt_count} attempt{c.baseline_attempt_count !== 1 ? "s" : ""}</p>
                    )}
                  </td>
                  {/* Endline */}
                  <td className="px-3 py-2 text-center whitespace-nowrap">
                    {c.endline_completed ? (
                      <span className="font-semibold text-blue-700">{c.endline_score ?? "—"}%</span>
                    ) : (
                      <span className="text-xs text-muted-foreground flex items-center justify-center gap-1">
                        <Clock className="w-3 h-3" /> Pending
                      </span>
                    )}
                    {c.endline_attempt_count > 0 && (
                      <p className="text-xs text-muted-foreground">{c.endline_attempt_count} attempt{c.endline_attempt_count !== 1 ? "s" : ""}</p>
                    )}
                  </td>
                  {/* Modules passed / started */}
                  <td className="px-3 py-2 text-center whitespace-nowrap">
                    {c.trainings_started > 0 ? (
                      <span className="font-medium text-foreground">{c.trainings_passed}/{c.trainings_started}</span>
                    ) : (
                      <span className="text-xs text-muted-foreground">—</span>
                    )}
                  </td>
                  {/* Avg quiz score */}
                  <td className="px-3 py-2 text-center">
                    {c.avg_quiz_score !== null ? (
                      <span className={`font-semibold ${c.avg_quiz_score >= 80 ? "text-green-700" : c.avg_quiz_score >= 60 ? "text-yellow-700" : "text-red-600"}`}>
                        {c.avg_quiz_score}%
                      </span>
                    ) : (
                      <span className="text-xs text-muted-foreground">—</span>
                    )}
                  </td>
                  {/* Tab switches */}
                  <td className="px-3 py-2 text-center">
                    {c.total_tab_switches > 0 ? (
                      <span className={`font-medium ${c.total_tab_switches >= 5 ? "text-amber-600" : "text-foreground"}`}>{c.total_tab_switches}</span>
                    ) : (
                      <span className="text-xs text-muted-foreground">0</span>
                    )}
                  </td>
                  {/* Flag */}
                  <td className="px-3 py-2 text-center">
                    {c.flagged ? (
                      <AlertTriangle className="w-4 h-4 text-red-500 mx-auto" />
                    ) : (
                      <CheckCircle2 className="w-4 h-4 text-green-500 mx-auto" />
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Weak modules breakdown */}
      {filtered.some((c) => c.weak_modules?.length > 0) && (
        <div className="bg-card border border-border rounded-lg p-4">
          <h2 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
            <TrendingUp className="w-4 h-4 text-blue-600" />
            Weak Module Distribution (filtered coaches)
          </h2>
          <WeakModuleBreakdown coaches={filtered} />
        </div>
      )}
    </div>
  );
}

function WeakModuleBreakdown({ coaches }: { coaches: CoachRow[] }) {
  const counts: Record<string, number> = {};
  for (const c of coaches) {
    for (const m of c.weak_modules || []) {
      counts[m] = (counts[m] || 0) + 1;
    }
  }
  const sorted = Object.entries(counts).sort((a, b) => b[1] - a[1]);
  if (sorted.length === 0) return <p className="text-xs text-muted-foreground">No weak module data.</p>;
  const max = sorted[0][1];

  return (
    <div className="space-y-2">
      {sorted.map(([mod, count]) => (
        <div key={mod} className="flex items-center gap-3">
          <span className="text-xs text-foreground w-28 shrink-0 truncate">{mod}</span>
          <div className="flex-1 bg-muted rounded-full h-2">
            <div
              className="bg-blue-500 h-2 rounded-full transition-all"
              style={{ width: `${(count / max) * 100}%` }}
            />
          </div>
          <span className="text-xs font-semibold text-muted-foreground w-8 text-right">{count}</span>
        </div>
      ))}
    </div>
  );
}
