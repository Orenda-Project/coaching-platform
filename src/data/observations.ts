import { supabase } from '@/integrations/supabase/client';
import type { CotObservation } from '@/types/observation';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
// TODO: Regenerate types in src/types/observation.ts to include cot_observations table
const typedSupabase = supabase as any;

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
}

export async function scheduleVisit(payload: ScheduleVisitPayload): Promise<CotObservation> {
  const { data, error } = await typedSupabase
    .from('cot_observations')
    .insert(payload)
    .select()
    .single();

  if (error) {
    throw error;
  }

  return data as CotObservation;
}

export async function listObservationsForObserver(observer_id: string): Promise<CotObservation[]> {
  const { data, error } = await typedSupabase
    .from('cot_observations')
    .select('*')
    .eq('observer_id', observer_id)
    .order('created_at', { ascending: false });

  if (error) {
    throw error;
  }

  return (data || []) as CotObservation[];
}

export async function markObservationDraft(observation_id: string): Promise<void> {
  const { error } = await typedSupabase
    .from('cot_observations')
    .update({
      status: 'Draft',
      updated_at: new Date().toISOString(),
    })
    .eq('id', observation_id);

  if (error) {
    throw error;
  }
}

export async function updateObservationStatus(
  observation_id: string,
  status: 'Submitted' | 'Approved' | 'Draft'
): Promise<void> {
  const { error } = await typedSupabase
    .from('cot_observations')
    .update({
      status,
      submitted_at: status === 'Submitted' ? new Date().toISOString() : undefined,
      updated_at: new Date().toISOString(),
    })
    .eq('id', observation_id);

  if (error) {
    throw error;
  }
}
