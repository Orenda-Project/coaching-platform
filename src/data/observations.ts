import type { CotObservation } from '@/types/observation';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

export interface ScheduleVisitPayload {
  observer_id: string;
  teacher_name: string;
  school_name: string;
  subject: string;
  grade: string;
  topic: string | null;
  framework: 'FICO' | 'HOTS';
  date: string;
  visit_purpose: string;
  status: 'Scheduled' | 'Draft';
  region: string;
  week?: string;
  visit_type?: 'FICO' | 'Head-Co Observation' | 'M&H' | 'General Visit' | 'RM Visit';
  planned_date?: string;
  arrival_time?: string;
  departure_time?: string;
}

async function apiFetch<T>(url: string, options?: RequestInit): Promise<T> {
  const response = await fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
  });

  if (!response.ok) {
    const errorBody = await response.text().catch(() => '');
    throw new Error(`API error ${response.status}: ${errorBody || response.statusText}`);
  }

  return response.json() as Promise<T>;
}

export async function scheduleVisit(payload: ScheduleVisitPayload): Promise<CotObservation> {
  console.log('[scheduleVisit] Creating observation via backend API:', payload);

  const data = await apiFetch<CotObservation>(
    `${API_URL}/api/coaching/observations`,
    { method: 'POST', body: JSON.stringify(payload) },
  );

  console.log('[scheduleVisit] Success, returned data:', data);
  return data;
}

export async function listObservationsForObserver(observer_id: string, region?: string): Promise<CotObservation[]> {
  const params = new URLSearchParams({ observer_id });
  if (region) {
    params.append('region', region);
  }

  const data = await apiFetch<{ observations: CotObservation[]; total: number }>(
    `${API_URL}/api/coaching/observations?${params.toString()}`,
  );

  return data.observations || [];
}

export async function markObservationDraft(observation_id: string): Promise<void> {
  await apiFetch<unknown>(
    `${API_URL}/api/coaching/observations/${observation_id}/status`,
    { method: 'PUT', body: JSON.stringify({ status: 'Draft' }) },
  );
}

export async function updateObservationStatus(
  observation_id: string,
  status: 'Submitted' | 'Approved' | 'Draft',
): Promise<void> {
  await apiFetch<unknown>(
    `${API_URL}/api/coaching/observations/${observation_id}/status`,
    { method: 'PUT', body: JSON.stringify({ status }) },
  );
}

export async function deleteObservation(observation_id: string): Promise<void> {
  await apiFetch<unknown>(
    `${API_URL}/api/coaching/observations/${observation_id}`,
    { method: 'DELETE' },
  );
}

export async function getObservation(observation_id: string): Promise<CotObservation> {
  return apiFetch<CotObservation>(
    `${API_URL}/api/coaching/observations/${observation_id}`,
  );
}

export async function patchObservation(
  observation_id: string,
  fields: Partial<Pick<CotObservation,
    | 'status'
    | 'notes_for_teacher'
    | 'hots_notes'
    | 'hots_rubric'
    | 'fico_rubric'
    | 'total_score'
    | 'proficiency_level'
    | 'submitted_at'
    | 'neo_task_id'
    | 'neo_status'
    | 'neo_results'
    | 'neo_error'
  >>,
): Promise<CotObservation> {
  return apiFetch<CotObservation>(
    `${API_URL}/api/coaching/observations/${observation_id}`,
    { method: 'PATCH', body: JSON.stringify(fields) },
  );
}
