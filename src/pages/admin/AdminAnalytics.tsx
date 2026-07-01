import { useEffect, useState } from "react";
import { fetchAnalyticsDashboard, CoachRow } from "@/lib/apiClients/adminAnalyticsApiClient";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { BarChart2, Users, TrendingUp, Search, AlertTriangle, CheckCircle2, Clock, Flag, ChevronDown, ChevronRight, Download } from "lucide-react";
import { exportCoachDataToExcel } from "@/domain/excel-export";

const REGIONS = [
  { value: "", label: "All Regions" },
  { value: "islamabad", label: "Islamabad (ICT)" },
  { value: "balochistan", label: "Balochistan" },
  { value: "punjab", label: "Punjab" },
  { value: "rawalpindi", label: "Rawalpindi (Rwp)" },
];

const SUB_REGIONS = ["Nilore", "Tarnol", "Sihala", "B.K", "Urban-I", "Urban-II"] as const;

const PERSONAS = [
  { value: "", label: "All Personas" },
  { value: "A", label: "A -- Advanced" },
  { value: "B", label: "B -- Intermediate" },
  { value: "C", label: "C -- Developing" },
  { value: "D", label: "D -- Entry-level" },
];

function regionLabel(val: string | null): string {
  const found = REGIONS.find((r) => r.value === val);
  return found && found.value ? found.label : val || "--";
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
  const [subRegionFilter, setSubRegionFilter] = useState("");
  const [personaFilter, setPersonaFilter] = useState("");
  const [showFlaggedOnly, setShowFlaggedOnly] = useState(false);
  const [expandedCoachId, setExpandedCoachId] = useState<string | null>(null);

  useEffect(() => {
    async function load() {
      setLoading(true);
      try {
        const result = await fetchAnalyticsDashboard();
        setCoaches(result.coaches);
      } catch (err) {
        console.error("Failed to load analytics dashboard:", err);
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  const filtered = coaches.filter((c) => {
    if (regionFilter && c.region !== regionFilter) return false;
    if (subRegionFilter && c.region === "islamabad" && c.sub_region !== subRegionFilter) return false;
    if (personaFilter && c.persona !== personaFilter) return false;
    if (showFlaggedOnly && !c.flagged) return false;
    if (search) {
      const q = search.toLowerCase();
      const name = (c.full_name || "").toLowerCase();
      const phone = (c.phone || "").toLowerCase();
      const email = (c.email || "").toLowerCase();
      const school = (c.school_id || "").toLowerCase();
      if (!name.includes(q) && !phone.includes(q) && !email.includes(q) && !school.includes(q)) return false;
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

  const handleExportToExcel = async () => {
    const exportData = filtered.map((c) => ({
      full_name: c.full_name,
      email: c.email,
      phone: c.phone,
      region: c.region,
      sub_region: c.region === "islamabad" ? c.sub_region : undefined,
      school_id: c.school_id,
      persona: c.persona,
      baseline_score: c.baseline_score,
      endline_score: c.endline_score,
    }));

    await exportCoachDataToExcel(exportData, "coaching-analytics");
  };

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
            onChange={(e) => {
              setRegionFilter(e.target.value);
              if (e.target.value !== "islamabad") setSubRegionFilter("");
            }}
            className="h-8 px-3 border border-input rounded-md bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          >
            {REGIONS.map((r) => <option key={r.value} value={r.value}>{r.label}</option>)}
          </select>
        </div>
        {regionFilter === "islamabad" && (
          <div>
            <Label className="text-xs mb-1 block">Sub-Region</Label>
            <select
              value={subRegionFilter}
              onChange={(e) => setSubRegionFilter(e.target.value)}
              className="h-8 px-3 border border-input rounded-md bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="">All Sub-Regions</option>
              {SUB_REGIONS.map((sr) => <option key={sr} value={sr}>{sr}</option>)}
            </select>
          </div>
        )}
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
        <div className="flex items-center gap-3 self-center pt-4">
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
          <button
            onClick={handleExportToExcel}
            disabled={filtered.length === 0}
            className="ml-auto flex items-center gap-2 px-3 py-1.5 bg-primary text-primary-foreground rounded-md text-sm font-medium hover:bg-primary/90 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            <Download className="w-3.5 h-3.5" />
            Export Excel
          </button>
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
                <th className="text-center px-2 py-2 font-semibold whitespace-nowrap w-8"></th>
                <th className="text-left px-3 py-2 font-semibold whitespace-nowrap">Coach Name / Phone / Email</th>
                <th className="text-left px-3 py-2 font-semibold whitespace-nowrap">Region</th>
                <th className="text-left px-3 py-2 font-semibold whitespace-nowrap">Sub-Region</th>
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
                <>
                  <tr key={c.id} className={c.flagged ? "bg-red-50/40" : "hover:bg-muted/30 transition-colors"}>
                    {/* Expand/Collapse button */}
                    <td className="px-2 py-2 text-center w-8" onClick={() => setExpandedCoachId(expandedCoachId === c.id ? null : c.id)} style={{ cursor: (c.moduleDetails.length > 0 || c.total_tab_switches > 0) ? "pointer" : "default" }}>
                      {(c.moduleDetails.length > 0 || c.total_tab_switches > 0) ? (
                        expandedCoachId === c.id ? (
                          <ChevronDown className="w-4 h-4 text-primary" />
                        ) : (
                          <ChevronRight className="w-4 h-4 text-muted-foreground" />
                        )
                      ) : null}
                    </td>

                    {/* Coach: Name, Phone, Email */}
                    <td className="px-3 py-2">
                      <p className="font-medium text-foreground text-sm">{c.full_name || "--"}</p>
                      <p className="text-xs text-muted-foreground">{c.phone || "--"}</p>
                      {c.email && <p className="text-xs text-muted-foreground truncate max-w-48" title={c.email}>{c.email}</p>}
                    </td>

                    {/* Region */}
                    <td className="px-3 py-2 whitespace-nowrap text-sm text-foreground">{regionLabel(c.region)}</td>

                    {/* Sub-Region */}
                    <td className="px-3 py-2 whitespace-nowrap text-sm text-foreground">
                      {c.region === "islamabad" ? (c.sub_region || "--") : "--"}
                    </td>

                    {/* School */}
                    <td className="px-3 py-2 whitespace-nowrap text-sm text-foreground max-w-40 truncate" title={c.school_id || ""}>
                      {c.school_id || "--"}
                    </td>

                    {/* Persona */}
                    <td className="px-3 py-2 text-center">
                      {c.persona ? (
                        <span className={`inline-block px-2 py-0.5 rounded-full text-xs font-semibold ${personaColor(c.persona)}`}>{c.persona}</span>
                      ) : (
                        <span className="text-xs text-muted-foreground">--</span>
                      )}
                    </td>

                    {/* Baseline Score */}
                    <td className="px-3 py-2 text-center text-sm">
                      {c.baseline_completed ? (
                        <div>
                          <span className="font-semibold text-green-700 block">{c.baseline_score ?? "--"}%</span>
                          <span className="text-xs text-muted-foreground">{c.baseline_attempt_count} attempt{c.baseline_attempt_count !== 1 ? "s" : ""}</span>
                        </div>
                      ) : (
                        <span className="text-xs text-muted-foreground flex items-center justify-center gap-1">
                          <Clock className="w-3 h-3" /> Pending
                        </span>
                      )}
                    </td>

                    {/* Endline Score */}
                    <td className="px-3 py-2 text-center text-sm">
                      {c.endline_completed ? (
                        <div>
                          <span className="font-semibold text-blue-700 block">{c.endline_score ?? "--"}%</span>
                          <span className="text-xs text-muted-foreground">{c.endline_attempt_count} attempt{c.endline_attempt_count !== 1 ? "s" : ""}</span>
                        </div>
                      ) : (
                        <span className="text-xs text-muted-foreground flex items-center justify-center gap-1">
                          <Clock className="w-3 h-3" /> Pending
                        </span>
                      )}
                    </td>

                    {/* Modules completed / total modules */}
                    <td className="px-3 py-2 text-center text-sm font-semibold">
                      {c.moduleDetails.length > 0 ? (
                        <span className="text-foreground">{c.modulesCompleted}/{c.moduleDetails.length}</span>
                      ) : (
                        <span className="text-xs text-muted-foreground">--</span>
                      )}
                    </td>

                    {/* Avg Quiz Score */}
                    <td className="px-3 py-2 text-center text-sm">
                      {c.avg_quiz_score !== null ? (
                        <span className={`font-semibold ${c.avg_quiz_score >= 80 ? "text-green-700" : c.avg_quiz_score >= 60 ? "text-yellow-700" : "text-red-600"}`}>
                          {c.avg_quiz_score}%
                        </span>
                      ) : (
                        <span className="text-xs text-muted-foreground">--</span>
                      )}
                    </td>

                    {/* Tab Switches */}
                    <td className="px-3 py-2 text-center text-sm font-medium">
                      {c.total_tab_switches > 0 ? (
                        <span className={c.total_tab_switches >= 3 ? "text-red-600" : "text-foreground"}>
                          {c.total_tab_switches}
                        </span>
                      ) : (
                        <span className="text-muted-foreground">0</span>
                      )}
                    </td>

                    {/* Flag */}
                    <td className="px-3 py-2 text-center">
                      {c.flagged || c.total_tab_switches >= 3 ? (
                        <span title="Flagged: Tab switches >= 3" className="inline-flex">
                          <AlertTriangle className="w-4 h-4 text-red-500 mx-auto" aria-label="Flagged: Tab switches >= 3" />
                        </span>
                      ) : (
                        <CheckCircle2 className="w-4 h-4 text-green-500 mx-auto" />
                      )}
                    </td>
                  </tr>

                  {/* Expanded module details row with unit-level status and tab switches */}
                  {expandedCoachId === c.id && (c.moduleDetails.length > 0 || c.total_tab_switches > 0) && (
                    <tr className="bg-muted/20 border-b border-border">
                      <td colSpan={12} className="px-6 py-4">
                        <div className="space-y-4">
                          <div>
                            <h4 className="font-semibold text-sm text-foreground mb-3">Assessment & Module Details</h4>
                            {/* Tab switches summary */}
                            <div className="grid grid-cols-3 gap-3 mb-4">
                              <div className="bg-blue-50 border border-blue-200 rounded p-3">
                                <p className="text-xs font-semibold text-blue-700 mb-1">Baseline</p>
                                <p className="text-lg font-bold text-blue-900">{c.tabSwitchBreakdown.baseline}</p>
                                <p className="text-xs text-blue-600">tab switches</p>
                              </div>
                              <div className="bg-purple-50 border border-purple-200 rounded p-3">
                                <p className="text-xs font-semibold text-purple-700 mb-1">Module Quiz</p>
                                <p className="text-lg font-bold text-purple-900">{c.tabSwitchBreakdown.module}</p>
                                <p className="text-xs text-purple-600">tab switches</p>
                              </div>
                              <div className="bg-orange-50 border border-orange-200 rounded p-3">
                                <p className="text-xs font-semibold text-orange-700 mb-1">Endline</p>
                                <p className="text-lg font-bold text-orange-900">{c.tabSwitchBreakdown.endline}</p>
                                <p className="text-xs text-orange-600">tab switches</p>
                              </div>
                            </div>
                          </div>

                          {/* Module breakdown */}
                          {c.moduleDetails.map((mod, idx) => (
                            <div key={mod.moduleId} className="bg-card border border-border rounded-lg p-4">
                              {/* Module header */}
                              <div className="flex items-center justify-between mb-3">
                                <span className="text-foreground font-semibold text-sm">
                                  <span className="text-primary font-bold mr-2">{idx + 1}.</span>
                                  {mod.moduleTitle}
                                </span>
                                <div className="flex items-center gap-2">
                                  {mod.avgScore !== null && (
                                    <span className={`text-xs font-semibold px-2 py-0.5 rounded-full ${
                                      mod.avgScore >= 80 ? "bg-green-100 text-green-700" : mod.avgScore >= 60 ? "bg-yellow-100 text-yellow-700" : "bg-red-100 text-red-600"
                                    }`}>
                                      avg {mod.avgScore}%
                                    </span>
                                  )}
                                  <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${
                                    mod.unitsCompleted === mod.unitsTotal && mod.unitsTotal > 0
                                      ? "bg-green-100 text-green-700"
                                      : mod.unitsCompleted > 0
                                      ? "bg-amber-100 text-amber-700"
                                      : "bg-gray-100 text-gray-600"
                                  }`}>
                                    {mod.unitsCompleted}/{mod.unitsTotal} units
                                  </span>
                                </div>
                              </div>
                              {/* Units list */}
                              <div className="space-y-2">
                                {mod.units.map((unit) => (
                                  <div key={unit.unitId} className="flex items-center justify-between text-xs pl-3 pr-2 py-2 bg-background rounded border border-border/50 hover:bg-muted/20 transition-colors">
                                    <div className="flex-1">
                                      <p className="text-foreground font-medium">{unit.unitTitle}</p>
                                      <p className="text-muted-foreground text-xs mt-0.5">
                                        {unit.quizType.charAt(0).toUpperCase() + unit.quizType.slice(1)} - {unit.score !== null ? `${unit.score}%` : "--"} - {unit.attemptCount} attempt{unit.attemptCount !== 1 ? "s" : ""} - {unit.tabSwitches} tab switch{unit.tabSwitches !== 1 ? "es" : ""}
                                      </p>
                                    </div>
                                    <span className={`font-medium flex items-center gap-1.5 whitespace-nowrap ml-2 ${unit.passed ? "text-green-600" : "text-amber-600"}`}>
                                      {unit.passed ? (
                                        <>
                                          <CheckCircle2 className="w-3.5 h-3.5 flex-shrink-0" />
                                          <span>Passed</span>
                                        </>
                                      ) : (
                                        <>
                                          <Clock className="w-3.5 h-3.5 flex-shrink-0" />
                                          <span>Pending</span>
                                        </>
                                      )}
                                    </span>
                                  </div>
                                ))}
                              </div>
                            </div>
                          ))}
                        </div>
                      </td>
                    </tr>
                  )}
                </>
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
