import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import DCDashboard from './DCDashboard';
import { AlertCircle } from 'lucide-react';
import { toast } from 'sonner';
import { scheduleVisit } from '@/data/observations';
import type { CotObservation, ScheduleVisitFormData } from '@/types/observation';
import type { DCTeacher } from '@/types/teacher';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const typedSupabase = supabase as any;

interface SmartScheduleTabProps {
  onNewObservation?: (obs: CotObservation) => void;
}

export default function SmartScheduleTab({ onNewObservation }: SmartScheduleTabProps) {
  const { user, profile } = useAuth();
  const [teachers, setTeachers] = useState<DCTeacher[]>([]);
  const [loading, setLoading] = useState(true);
  const [assignmentLoading, setAssignmentLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [coachSubRegion, setCoachSubRegion] = useState<string | null>(null);
  const [schedulingTeacherId, setSchedulingTeacherId] = useState<string | null>(null);
  const [isOffline, setIsOffline] = useState(false);
  const [lastSynced, setLastSynced] = useState<string | null>(null);
  const [connectionError, setConnectionError] = useState(false);

  const coachName = profile?.full_name || user?.email || 'Coach';

  // Cache management helpers
  const getCacheKey = useCallback((suffix: string) => `scheduler_${suffix}_${user?.id}`, [user?.id]);

  const readCache = useCallback(() => {
    if (!user) return { teachers: null, assignment: null, timestamp: null };
    try {
      const cachedTeachers = localStorage.getItem(getCacheKey('teachers'));
      const cachedAssignment = localStorage.getItem(getCacheKey('assignment'));
      const cachedTimestamp = localStorage.getItem(getCacheKey('cache_ts'));

      return {
        teachers: cachedTeachers ? JSON.parse(cachedTeachers) : null,
        assignment: cachedAssignment,
        timestamp: cachedTimestamp,
      };
    } catch {
      return { teachers: null, assignment: null, timestamp: null };
    }
  }, [user, getCacheKey]);

  const writeCache = useCallback((teacherList: DCTeacher[], assignment: string | null) => {
    if (!user) return;
    try {
      const now = new Date().toISOString();
      localStorage.setItem(getCacheKey('teachers'), JSON.stringify(teacherList));
      if (assignment) localStorage.setItem(getCacheKey('assignment'), assignment);
      localStorage.setItem(getCacheKey('cache_ts'), now);
      setLastSynced(now);
      setIsOffline(false);
      setConnectionError(false);
    } catch {
      // localStorage full or not available, continue without caching
    }
  }, [user, getCacheKey]);

  // Load coach's assigned sub-region from coach_assignments
  useEffect(() => {
    const loadAssignment = async () => {
      if (!user) {
        setAssignmentLoading(false);
        return;
      }

      // Try cache first
      const cache = readCache();
      if (cache.assignment) {
        setCoachSubRegion(cache.assignment);
      }

      try {
        const { data, error: queryError } = await typedSupabase
          .from('coach_assignments')
          .select('sub_region')
          .eq('coach_id', user.id)
          .single();

        if (queryError && queryError.code !== 'PGRST116') {
          // PGRST116 = no rows, which is expected for new/unassigned coaches
          console.error('Failed to load coach assignment:', queryError);
        }

        const subRegion = data?.sub_region ?? null;
        setCoachSubRegion(subRegion);
        if (subRegion) {
          localStorage.setItem(getCacheKey('assignment'), subRegion);
        }
      } catch (err) {
        console.error('Error loading coach assignment:', err);
        setIsOffline(true);
      } finally {
        setAssignmentLoading(false);
      }
    };

    loadAssignment();
  }, [user, readCache, getCacheKey]);

  const loadData = useCallback(async () => {
    // Load from cache first, if available
    const cache = readCache();
    if (cache.teachers) {
      setTeachers(cache.teachers);
      setLastSynced(cache.timestamp);
      setLoading(false);
      setError(null);
    } else {
      setLoading(true);
    }

    // Set a 10s timeout for first load with no cache
    const timeoutId = setTimeout(() => {
      if (cache.teachers === null) {
        setConnectionError(true);
      }
    }, 10000);

    try {
      setError(null);

      let query = typedSupabase
        .from('teacher_dc_scores')
        .select('*');

      if (coachSubRegion) {
        query = query.eq('region', coachSubRegion);
      }

      const { data, error: queryError } = await query
        .order('total_score', { ascending: true });

      clearTimeout(timeoutId);

      if (queryError) {
        // Network error - show cached data if available, otherwise show error
        if (cache.teachers) {
          setIsOffline(true);
          setConnectionError(false);
        } else {
          setError(queryError.message);
          setTeachers([]);
          setConnectionError(false);
        }
      } else if (!data || data.length === 0) {
        if (cache.teachers) {
          setIsOffline(true);
        } else {
          setError('No teachers assigned to your sub-region.');
        }
        setTeachers([]);
      } else {
        // Map database fields to component interface
        interface DbRow {
          id: string;
          teacher_name: string;
          school_name: string;
          region: string;
          grade: string;
          subject: string;
          total_score: number;
          scored_at: string;
          raw_results?: {
            overall_percentage?: number;
            accurate_lesson_planning?: number;
            timely_lesson_delivery?: number;
            subject_command?: number;
            effective_pedagogy?: number;
            effective_resource_use?: number;
            activity_based_learning?: number;
            student_participation?: number;
            critical_thinking?: number;
            inclusive_practices?: number;
            technology_integration?: number;
            technology_handling?: number;
            verbal_communication?: number;
            non_verbal_communication?: number;
          };
        }
        const mappedTeachers: DCTeacher[] = data.map((row: DbRow) => ({
          user_id: row.id,
          teacher_name: row.teacher_name,
          school: row.school_name,
          sector: row.region,
          overall_percentage: row.raw_results?.overall_percentage || 0,
          total_score: row.total_score,
          created_date: row.scored_at,
          grade: row.grade,
          subject: row.subject,
          accurate_lesson_planning: row.raw_results?.accurate_lesson_planning || 0,
          timely_lesson_delivery: row.raw_results?.timely_lesson_delivery || 0,
          subject_command: row.raw_results?.subject_command || 0,
          effective_pedagogy: row.raw_results?.effective_pedagogy || 0,
          effective_resource_use: row.raw_results?.effective_resource_use || 0,
          activity_based_learning: row.raw_results?.activity_based_learning || 0,
          student_participation: row.raw_results?.student_participation || 0,
          critical_thinking: row.raw_results?.critical_thinking || 0,
          inclusive_practices: row.raw_results?.inclusive_practices || 0,
          technology_integration: row.raw_results?.technology_integration || 0,
          technology_handling: row.raw_results?.technology_handling || 0,
          verbal_communication: row.raw_results?.verbal_communication || 0,
          non_verbal_communication: row.raw_results?.non_verbal_communication || 0,
        }));
        setTeachers(mappedTeachers);
        writeCache(mappedTeachers, coachSubRegion);
        setConnectionError(false);
      }
    } catch (err) {
      clearTimeout(timeoutId);
      // Network error - show cached data if available
      if (cache.teachers) {
        setIsOffline(true);
      } else {
        setError(err instanceof Error ? err.message : 'Unknown error');
        setTeachers([]);
      }
      setConnectionError(false);
    } finally {
      setLoading(false);
    }
  }, [coachSubRegion, readCache, writeCache]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const handleScheduleVisit = useCallback(async (teacher: DCTeacher, formData: ScheduleVisitFormData) => {
    if (!user) {
      toast.error('Not authenticated');
      return;
    }

    // Defense-in-depth: validate that date is not in the past
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const selectedDate = new Date(formData.date);
    selectedDate.setHours(0, 0, 0, 0);

    if (selectedDate < today) {
      toast.error('Visit date cannot be in the past');
      return;
    }

    setSchedulingTeacherId(teacher.user_id);
    try {
      const data = await scheduleVisit({
        observer_id: user.id,
        teacher_name: teacher.teacher_name,
        school_name: teacher.school,
        subject: teacher.subject,
        grade: teacher.grade,
        topic: formData.lesson_topic || null,
        framework: 'FICO',
        date: formData.date,
        visit_purpose: formData.visit_purpose,
        status: 'Scheduled',
        region: coachSubRegion || teacher.sector,
      });

      toast.success('Visit scheduled! Opening Neo recording...');
      onNewObservation?.(data);
    } catch (err) {
      const errMsg = err instanceof Error ? err.message : 'Unknown error';
      if (errMsg.includes('Failed to fetch') || errMsg.includes('network')) {
        toast.error('No connection — reconnect and try again');
      } else {
        toast.error('Failed to schedule visit');
      }
      // Log error code only, not the full payload containing user.id
      console.error('scheduleVisit error:', err instanceof Error ? err.message : errMsg);
    } finally {
      setSchedulingTeacherId(null);
    }
  }, [user, onNewObservation, coachSubRegion]);

  // Show loading state while fetching assignment
  if (assignmentLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  // No assignment state - show sector picker as fallback
  if (!coachSubRegion) {
    const uniqueSectors = Array.from(
      new Map(
        teachers.map(t => [
          t.sector,
          { sector: t.sector, count: teachers.filter(x => x.sector === t.sector).length }
        ])
      ).values()
    ).sort((a, b) => a.sector.localeCompare(b.sector));

    if (uniqueSectors.length === 0) {
      return (
        <div className="flex flex-col items-center justify-center py-14 text-center">
          <AlertCircle className="w-10 h-10 text-amber-600 mb-3" />
          <h3 className="font-semibold text-foreground mb-1">No teachers available</h3>
          <p className="text-sm text-muted-foreground max-w-xs">
            No teacher data available. Please seed the database.
          </p>
        </div>
      );
    }

    return (
      <div className="space-y-4">
        <div>
          <h2 className="font-display text-lg font-semibold text-foreground">Select Your Sector</h2>
          <p className="text-sm text-muted-foreground">
            Choose your sector to see assigned teachers
          </p>
        </div>

        <div className="flex flex-wrap gap-2">
          {uniqueSectors.map((sector) => (
            <button
              key={sector.sector}
              onClick={() => setCoachSubRegion(sector.sector)}
              className="px-4 py-2 rounded-md bg-blue-50 text-blue-700 hover:bg-blue-100 hover:text-blue-800 transition-colors font-medium border border-blue-200"
            >
              {sector.sector}
            </button>
          ))}
        </div>
      </div>
    );
  }

  // Connection timeout state (first load with no cache and timeout reached)
  if (connectionError && teachers.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <AlertCircle className="w-10 h-10 text-red-600 mb-3" />
        <h3 className="font-semibold text-foreground mb-1">Unable to connect</h3>
        <p className="text-sm text-muted-foreground max-w-xs mb-4">Check your signal and try again.</p>
        <button
          onClick={() => loadData()}
          className="px-4 py-2 rounded-md bg-primary text-primary-foreground hover:bg-primary/90 transition-colors font-medium text-sm"
        >
          Retry
        </button>
      </div>
    );
  }

  // Load error state
  if (error && teachers.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <AlertCircle className="w-10 h-10 text-amber-600 mb-3" />
        <h3 className="font-semibold text-foreground mb-1">Unable to load teachers</h3>
        <p className="text-sm text-muted-foreground max-w-xs mb-4">{error}</p>
        <button
          onClick={() => loadData()}
          className="px-4 py-2 rounded-md bg-primary text-primary-foreground hover:bg-primary/90 transition-colors font-medium text-sm"
        >
          Retry
        </button>
      </div>
    );
  }

  // Teacher list view
  return (
    <div className="space-y-4">
      <div>
        <h2 className="font-display text-lg font-semibold text-foreground">Smart Schedule</h2>
        <p className="text-sm text-muted-foreground">
          Sub-region: <span className="font-medium text-foreground">{coachSubRegion}</span>
          {' '}· {teachers.length} teacher{teachers.length !== 1 ? 's' : ''} · Ranked by coaching priority
        </p>
      </div>

      <DCDashboard
        teachers={teachers}
        loading={loading}
        onScheduleVisit={handleScheduleVisit}
        coachName={coachName}
        subRegion={coachSubRegion || 'Unknown'}
        isOffline={isOffline}
        lastSynced={lastSynced}
        onRetry={loadData}
      />
    </div>
  );
}
