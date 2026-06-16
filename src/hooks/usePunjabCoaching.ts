import { useState, useCallback } from 'react';
import { supabase } from '@/integrations/supabase/client';
import type { PunjabTeacher } from '@/types/teacher';

const CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24 hours

function cacheKey(userId: string, cluster: string) {
  return `punjab_teachers_${userId}_${cluster}`;
}

function readCache(userId: string, cluster: string): { teachers: PunjabTeacher[]; ts: string } | null {
  try {
    const raw = localStorage.getItem(cacheKey(userId, cluster));
    if (!raw) return null;
    const parsed = JSON.parse(raw) as { teachers: PunjabTeacher[]; ts: string };
    if (Date.now() - new Date(parsed.ts).getTime() > CACHE_TTL_MS) return null;
    return parsed;
  } catch {
    return null;
  }
}

function writeCache(userId: string, cluster: string, teachers: PunjabTeacher[]): string {
  const ts = new Date().toISOString();
  try {
    localStorage.setItem(cacheKey(userId, cluster), JSON.stringify({ teachers, ts }));
  } catch {
    // localStorage full — continue without caching
  }
  return ts;
}

export interface UsePunjabCoachingState {
  teachers: PunjabTeacher[];
  loading: boolean;
  error: string | null;
  isOffline: boolean;
  lastSynced: string | null;
}

export interface UsePunjabCoachingActions {
  loadTeachers: (cluster: string, userId?: string) => Promise<void>;
}

export function usePunjabCoaching(): UsePunjabCoachingState & UsePunjabCoachingActions {
  const [teachers, setTeachers] = useState<PunjabTeacher[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isOffline, setIsOffline] = useState(false);
  const [lastSynced, setLastSynced] = useState<string | null>(null);

  const loadTeachers = useCallback(async (cluster: string, userId?: string) => {
    setLoading(true);
    setError(null);

    // Serve from cache immediately if available
    if (userId) {
      const cached = readCache(userId, cluster);
      if (cached) {
        setTeachers(cached.teachers);
        setLastSynced(cached.ts);
        setLoading(false);
        // Still attempt background refresh below
      }
    }

    try {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const { data, error: dbError } = await (supabase as any)
        .from('punjab_teacher_scores')
        .select('*')
        .eq('cluster_name', cluster)
        .order('overall_percentage', { ascending: true });

      if (dbError) throw dbError;

      const fresh = (data ?? []) as unknown as PunjabTeacher[];
      setTeachers(fresh);
      setIsOffline(false);

      if (userId) {
        const ts = writeCache(userId, cluster, fresh);
        setLastSynced(ts);
      }
    } catch (err) {
      // If we already served from cache, just flag offline — don't show error
      if (teachers.length > 0) {
        setIsOffline(true);
      } else {
        setError(err instanceof Error ? err.message : 'Failed to load teachers');
        setIsOffline(true);
      }
    } finally {
      setLoading(false);
    }
  }, [teachers.length]);

  return { teachers, loading, error, isOffline, lastSynced, loadTeachers };
}
