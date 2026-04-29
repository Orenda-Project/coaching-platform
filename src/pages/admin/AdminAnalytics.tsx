import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { BarChart2, Users, TrendingUp, Search, AlertTriangle, CheckCircle2, Clock, Flag, ChevronDown, ChevronRight } from "lucide-react";

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

interface UnitDetail {
  unitId: string;
  unitTitle: string;
  passed: boolean;
  tabSwitches: number;
  quizType: "baseline" | "module" | "endline";
}

interface ModuleDetail {
  moduleId: string;
  moduleTitle: string;
  unitsCompleted: number;
  unitsTotal: number;
  units: UnitDetail[];
}

interface TabSwitchBreakdown {
  baseline: number;
  module: number;
  endline: number;
}

interface CoachRow extends ProfileRow {
  trainings_passed: number;
  trainings_started: number;
  trainings_total: number;
  modulesCompleted: number;
  avg_quiz_score: number | null;
  total_tab_switches: number;
  tabSwitchBreakdown: TabSwitchBreakdown;
  flagged: boolean;
  moduleDetails: ModuleDetail[];
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
  const [expandedCoachId, setExpandedCoachId] = useState<string | null>(null);

  useEffect(() => {
    async function load() {
      setLoading(true);
      try {
        const [{ data: profiles }, { data: progress }, { data: trainingsData }, { data: modulesData }, { data: assessmentsData }] = await Promise.all([
          supabase.from("profiles").select("*").order("created_at", { ascending: false }),
          supabase.from("training_progress").select("user_id, training_id, passed, score, attempt_count, tab_switch_count, fullscreen_violations, flagged_for_review, content_completed"),
          supabase.from("trainings").select("id, persona_required, module_id, title"),
          supabase.from("modules").select("id, title"),
          supabase.from("assessments").select("training_id, type"),
        ]);

        const progressByUser = new Map<string, TrainingProgressRow[]>();
        for (const row of (progress || []) as TrainingProgressRow[]) {
          if (!progressByUser.has(row.user_id)) progressByUser.set(row.user_id, []);
          progressByUser.get(row.user_id)!.push(row);
        }

        // Count total trainings per persona and map assessments
        const totalByPersona = new Map<string, number>();
        const trainingsMap = new Map<string, { title: string; module_id: string | null; persona_required: string | null }>();
        const assessmentMap = new Map<string, string>(); // training_id -> assessment type
        const modulesMap = new Map<string, string>(); // module_id -> module title

        for (const training of (trainingsData || []) as Array<{ id: string; title: string; module_id: string | null; persona_required: string | null }>) {
          trainingsMap.set(training.id, training);
          const key = training.persona_required || "all";
          totalByPersona.set(key, (totalByPersona.get(key) || 0) + 1);
        }

        for (const module of (modulesData || []) as Array<{ id: string; title: string }>) {
          modulesMap.set(module.id, module.title);
        }

        for (const assessment of (assessmentsData || []) as Array<{ training_id: string | null; type: string }>) {
          if (assessment.training_id) {
            assessmentMap.set(assessment.training_id, assessment.type);
          }
        }

        // Map assessment type to quiz type (baseline, module, endline)
        const getQuizType = (trainingId: string): "baseline" | "module" | "endline" => {
          const assessmentType = assessmentMap.get(trainingId);
          if (assessmentType === "baseline") return "baseline";
          if (assessmentType === "endline") return "endline";
          return "module";
        };

        // Build module details for each coach with unit-level details
        const buildModuleDetails = (userTrainings: TrainingProgressRow[]): ModuleDetail[] => {
          const moduleMap = new Map<string, { title: string; unitsList: UnitDetail[] }>();
          const moduleProgress = new Map<string, { completed: number; total: number }>();

          for (const ut of userTrainings) {
            const training = trainingsMap.get(ut.training_id);
            if (!training || !training.module_id) continue;

            const moduleId = training.module_id;
            if (!moduleMap.has(moduleId)) {
              moduleMap.set(moduleId, { title: "", unitsList: [] });
              moduleProgress.set(moduleId, { completed: 0, total: 0 });
            }

            const moduleInfo = moduleMap.get(moduleId)!;
            // Get module name from modules table
            const moduleName = modulesMap.get(moduleId) || "Unknown Module";
            moduleInfo.title = moduleName;

            // Extract unit title (e.g., "Unit 1.0: Title" → "Unit 1.0: Title")
            const unitTitle = training.title;
            const quizType = getQuizType(ut.training_id);
            moduleInfo.unitsList.push({
              unitId: ut.training_id,
              unitTitle,
              passed: ut.passed,
              tabSwitches: ut.tab_switch_count,
              quizType,
            });

            const progress = moduleProgress.get(moduleId)!;
            progress.total += 1;
            if (ut.passed) progress.completed += 1;
          }

          return Array.from(moduleMap.entries()).map(([moduleId, info]) => ({
            moduleId,
            moduleTitle: info.title,
            unitsCompleted: moduleProgress.get(moduleId)?.completed || 0,
            unitsTotal: moduleProgress.get(moduleId)?.total || 0,
            units: info.unitsList,
          }));
        };

        const rows: CoachRow[] = ((profiles || []) as ProfileRow[]).map((p) => {
          const tp = progressByUser.get(p.id) || [];
          const passed = tp.filter((r) => r.passed).length;
          const started = tp.length;
          // Avg Quiz: only module quiz scores (exclude baseline/endline)
          const moduleScores = tp
            .filter((r) => {
              const quizType = getQuizType(r.training_id);
              return quizType === "module";
            })
            .map((r) => r.score)
            .filter((s): s is number => s !== null);
          const avg = moduleScores.length ? Math.round(moduleScores.reduce((a, b) => a + b, 0) / moduleScores.length) : null;
          const tabs = tp.reduce((a, r) => a + r.tab_switch_count, 0);
          const flagged = tp.some((r) => r.flagged_for_review);
          const total = totalByPersona.get(p.persona || "all") || 0;
          const moduleDetails = buildModuleDetails(tp);

          // Count completed modules (where all units are passed)
          const modulesCompleted = moduleDetails.filter(
            (m) => m.unitsCompleted === m.unitsTotal && m.unitsTotal > 0
          ).length;

          // Calculate tab switches breakdown by quiz type (including baseline/endline from ALL tp rows)
          const tabSwitchBreakdown: TabSwitchBreakdown = {
            baseline: 0,
            module: 0,
            endline: 0,
          };
          // Loop through ALL training_progress rows and classify by assessment type
          for (const row of tp) {
            const quizType = getQuizType(row.training_id);
            tabSwitchBreakdown[quizType] += row.tab_switch_count;
          }

          return {
            ...p,
            trainings_passed: passed,
            trainings_started: started,
            trainings_total: total,
            modulesCompleted,
            avg_quiz_score: avg,
            total_tab_switches: tabs,
            tabSwitchBreakdown,
            flagged,
            moduleDetails
          };
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
                <th className="text-center px-2 py-2 font-semibold whitespace-nowrap w-8"></th>
                <th className="text-left px-3 py-2 font-semibold whitespace-nowrap">Coach Name / Phone / Email</th>
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
                      <p className="font-medium text-foreground text-sm">{c.full_name || "—"}</p>
                      <p className="text-xs text-muted-foreground">{c.phone || "—"}</p>
                    </td>

                    {/* Region */}
                    <td className="px-3 py-2 whitespace-nowrap text-sm text-foreground">{regionLabel(c.region)}</td>

                    {/* School */}
                    <td className="px-3 py-2 whitespace-nowrap text-sm text-foreground max-w-40 truncate" title={c.school_id || ""}>
                      {c.school_id || "—"}
                    </td>

                    {/* Persona */}
                    <td className="px-3 py-2 text-center">
                      {c.persona ? (
                        <span className={`inline-block px-2 py-0.5 rounded-full text-xs font-semibold ${personaColor(c.persona)}`}>{c.persona}</span>
                      ) : (
                        <span className="text-xs text-muted-foreground">—</span>
                      )}
                    </td>

                    {/* Baseline Score */}
                    <td className="px-3 py-2 text-center text-sm">
                      {c.baseline_completed ? (
                        <div>
                          <span className="font-semibold text-green-700 block">{c.baseline_score ?? "—"}%</span>
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
                          <span className="font-semibold text-blue-700 block">{c.endline_score ?? "—"}%</span>
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
                        <span className="text-xs text-muted-foreground">—</span>
                      )}
                    </td>

                    {/* Avg Quiz Score */}
                    <td className="px-3 py-2 text-center text-sm">
                      {c.avg_quiz_score !== null ? (
                        <span className={`font-semibold ${c.avg_quiz_score >= 80 ? "text-green-700" : c.avg_quiz_score >= 60 ? "text-yellow-700" : "text-red-600"}`}>
                          {c.avg_quiz_score}%
                        </span>
                      ) : (
                        <span className="text-xs text-muted-foreground">—</span>
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
                        <span title="Flagged: Tab switches ≥ 3" className="inline-flex">
                          <AlertTriangle className="w-4 h-4 text-red-500 mx-auto" aria-label="Flagged: Tab switches ≥ 3" />
                        </span>
                      ) : (
                        <CheckCircle2 className="w-4 h-4 text-green-500 mx-auto" />
                      )}
                    </td>
                  </tr>

                  {/* Expanded module details row with unit-level status and tab switches */}
                  {expandedCoachId === c.id && (c.moduleDetails.length > 0 || c.total_tab_switches > 0) && (
                    <tr className="bg-muted/20 border-b border-border">
                      <td colSpan={11} className="px-6 py-4">
                        <div className="space-y-4">
                          <div>
                            <h4 className="font-semibold text-sm text-foreground mb-3">📊 Assessment & Module Details</h4>
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
                              {/* Units list */}
                              <div className="space-y-2">
                                {mod.units.map((unit) => (
                                  <div key={unit.unitId} className="flex items-center justify-between text-xs pl-3 pr-2 py-2 bg-background rounded border border-border/50 hover:bg-muted/20 transition-colors">
                                    <div className="flex-1">
                                      <p className="text-foreground font-medium">{unit.unitTitle}</p>
                                      <p className="text-muted-foreground text-xs mt-0.5">
                                        {unit.quizType.charAt(0).toUpperCase() + unit.quizType.slice(1)} • {unit.tabSwitches} tab switch{unit.tabSwitches !== 1 ? "es" : ""}
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
