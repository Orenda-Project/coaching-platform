import { supabase } from '@/integrations/supabase/client';
import type { PunjabTeacher } from '@/types/teacher';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const db = supabase as any;

export async function listRawalpindiTeachersByCluster(cluster: string): Promise<PunjabTeacher[]> {
  const { data, error } = await db
    .from('rawalpindi_teacher_scores')
    .select('*')
    .eq('cluster_name', cluster)
    .order('overall_percentage', { ascending: true });
  if (error) throw error;
  return (data ?? []) as PunjabTeacher[];
}
