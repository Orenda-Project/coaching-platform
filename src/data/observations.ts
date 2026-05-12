import { supabase } from '@/integrations/supabase/client';
import type { CotObservation } from '@/types/observation';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
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
