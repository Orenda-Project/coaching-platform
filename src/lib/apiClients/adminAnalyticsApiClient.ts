/**
 * Admin Analytics API Client — calls FastAPI backend for pre-aggregated dashboard data.
 * Replaces the 5 parallel Supabase queries in AdminAnalytics.tsx.
 */

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

export interface TabSwitchBreakdown {
  baseline: number;
  module: number;
  endline: number;
}

export interface UnitDetail {
  unitId: string;
  unitTitle: string;
  passed: boolean;
  tabSwitches: number;
  quizType: "baseline" | "module" | "endline";
  score: number | null;
  attemptCount: number;
}

export interface ModuleDetail {
  moduleId: string;
  moduleTitle: string;
  unitsCompleted: number;
  unitsTotal: number;
  units: UnitDetail[];
  avgScore: number | null;
}

export interface CoachRow {
  id: string;
  full_name: string | null;
  phone: string | null;
  region: string | null;
  sub_region?: string | null;
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

export interface AnalyticsDashboardResponse {
  coaches: CoachRow[];
}

export interface DashboardFilters {
  region?: string;
  persona?: string;
}

export async function fetchAnalyticsDashboard(
  filters: DashboardFilters = {},
): Promise<AnalyticsDashboardResponse> {
  const params = new URLSearchParams();
  if (filters.region) params.append("region", filters.region);
  if (filters.persona) params.append("persona", filters.persona);

  const qs = params.toString();
  const url = `${API_URL}/api/admin/analytics/dashboard${qs ? `?${qs}` : ""}`;

  const res = await fetch(url, {
    headers: { "Content-Type": "application/json" },
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Analytics API error: ${res.status} ${err}`);
  }

  return res.json();
}
