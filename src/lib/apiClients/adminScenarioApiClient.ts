/**
 * Admin Scenario API Client — CRUD for scenarios and options.
 * Replaces direct Supabase calls in AdminScenarios and AdminScenarioOptions.
 */

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

async function apiFetch<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, {
    headers: { "Content-Type": "application/json", ...init?.headers },
    ...init,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`API ${res.status}: ${text}`);
  }
  if (res.status === 204) return undefined as unknown as T;
  return res.json();
}

// ===== Scenarios =====

export async function listScenarios(trainingId?: string) {
  const qs = trainingId ? `?training_id=${trainingId}` : "";
  return apiFetch<{ scenarios: Record<string, unknown>[] }>(`${API_URL}/api/admin/scenarios${qs}`);
}

export async function createScenario(data: Record<string, unknown>) {
  return apiFetch<Record<string, unknown>>(`${API_URL}/api/admin/scenarios`, {
    method: "POST",
    body: JSON.stringify(data),
  });
}

export async function updateScenario(scenarioId: string, data: Record<string, unknown>) {
  return apiFetch<Record<string, unknown>>(`${API_URL}/api/admin/scenarios/${scenarioId}`, {
    method: "PUT",
    body: JSON.stringify(data),
  });
}

export async function deleteScenario(scenarioId: string) {
  return apiFetch<void>(`${API_URL}/api/admin/scenarios/${scenarioId}`, {
    method: "DELETE",
  });
}

/**
 * Get a single scenario by ID (fetches all scenarios and filters client-side).
 * The admin API does not expose a GET /scenarios/:id endpoint.
 */
export async function getScenario(scenarioId: string) {
  const { scenarios } = await listScenarios();
  const match = scenarios.find((s) => s.id === scenarioId);
  if (!match) throw new Error(`Scenario ${scenarioId} not found`);
  return match;
}

// ===== Scenario Options =====

export async function upsertScenarioOptions(
  scenarioId: string,
  options: Record<string, unknown>[],
) {
  return apiFetch<{ options: Record<string, unknown>[] }>(
    `${API_URL}/api/admin/scenarios/${scenarioId}/options`,
    {
      method: "POST",
      body: JSON.stringify({ options }),
    }
  );
}
