import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import DCDashboard from './DCDashboard';
import { AlertCircle } from 'lucide-react';
import { toast } from 'sonner';
import { scheduleVisit, listObservationsForObserver } from '@/data/observations';
import type { CotObservation, ScheduleVisitFormData } from '@/types/observation';
import type { DCTeacher } from '@/types/teacher';
import { getScoreTrend, calculateDaysOverdue, assignPriorityTier, getVisitInterval } from '@/lib/scheduler-utils';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const typedSupabase = supabase as any;

interface SmartScheduleTabProps {
  onNewObservation?: (obs: CotObservation) => void;
}

export default function SmartScheduleTab({ onNewObservation }: SmartScheduleTabProps) {
  const { user, profile } = useAuth();
  const [teachers, setTeachers] = useState<DCTeacher[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [schedulingTeacherId, setSchedulingTeacherId] = useState<string | null>(null);
  const [isOffline, setIsOffline] = useState(false);
  const [lastSynced, setLastSynced] = useState<string | null>(null);
  const [connectionError, setConnectionError] = useState(false);
  const [visitedTeachers, setVisitedTeachers] = useState<Set<string>>(new Set());

  const coachName = profile?.full_name || user?.email || 'Coach';
  const coachSubRegion = (profile as Record<string, unknown>)?.sub_region as string | null;
  const coachRegion = (profile as Record<string, unknown>)?.region as string | null;

  // Coaching cycle management
  const getCycleStartDate = () => {
    if (!user?.id) return null;
    const stored = localStorage.getItem(`cycle_start_${user.id}`);
    return stored ? new Date(stored) : null;
  };

  const resetCycle = () => {
    if (!user?.id) return;
    localStorage.setItem(`cycle_start_${user.id}`, new Date().toISOString());
    toast.success('Coaching cycle reset');
  };

  const cycleStart = getCycleStartDate();

  // Mock test data merging teachers + coaches + schools for Urban-1
  const getMockTestData = useCallback((): DCTeacher[] => {
    const coachSchoolMap: Record<string, string> = {
      'IMS(I-V) No.2 G-8/4': 'Bushra',
      'IMS(I-V) PIMS G-8/3': 'Bushra',
      'IMS(I-V) No.1 G-8/4': 'Bushra',
      'ICG, F-6/2': 'Bushra',
      'IMS(I-V) F-6/1': 'Hiba',
      'IMS(I-V) G-6/4': 'Hiba',
      'IMCG, F-8/1': 'Hiba',
      'IMS(I-V) G-7/4': 'Hiba',
      'IMS (I-V) G-7/3-3': 'Hifza',
      'IMSG (I-VIII) F/7-4': 'Hifza',
      'IMCB, F-7/3': 'Hifza',
      'IMCG, ST. 25, F-6/2': 'Hifza',
      'IMS(I-V) No.1 G-8/2': 'Hifza',
      'IMS(I-V) No.2 G-8/2': 'Maroof',
      'IMSG(I-VIII) G-6/2': 'Khadija Akbar',
      'IMSG (VI-X) G-6/2': 'Maroof',
      'IMSG (VI-X) F-7/2': 'Maroof',
      'IMCG (VI-XII), G-6/1-4': 'Maroof',
    };

    const testTeachers: DCTeacher[] = [
      {
        user_id: '1', teacher_name: 'Amina Khan', school: 'IMS(I-V) No.2 G-8/4', sector: 'Urban-1',
        overall_percentage: 45, total_score: 1.8, created_date: new Date().toISOString(),
        grade: 'I-V', subject: 'Urdu',
        accurate_lesson_planning: 2.2, timely_lesson_delivery: 1.8, subject_command: 1.3, effective_pedagogy: 1.8,
        effective_resource_use: 1.5, activity_based_learning: 2.0, student_participation: 1.6, critical_thinking: 1.7,
        inclusive_practices: 1.4, technology_integration: 1.2, technology_handling: 1.5, verbal_communication: 2.0, non_verbal_communication: 1.8
      },
      {
        user_id: '2', teacher_name: 'Fatima Ahmed', school: 'IMS(I-V) PIMS G-8/3', sector: 'Urban-1',
        overall_percentage: 52, total_score: 2.08, created_date: new Date().toISOString(),
        grade: 'I-V', subject: 'Math',
        accurate_lesson_planning: 2.4, timely_lesson_delivery: 2.0, subject_command: 1.6, effective_pedagogy: 2.1,
        effective_resource_use: 1.8, activity_based_learning: 2.2, student_participation: 1.9, critical_thinking: 2.0,
        inclusive_practices: 1.7, technology_integration: 1.5, technology_handling: 1.8, verbal_communication: 2.2, non_verbal_communication: 2.0
      },
      {
        user_id: '3', teacher_name: 'Sara Malik', school: 'IMS(I-V) No.1 G-8/4', sector: 'Urban-1',
        overall_percentage: 58, total_score: 2.32, created_date: new Date().toISOString(),
        grade: 'I-V', subject: 'English',
        accurate_lesson_planning: 2.8, timely_lesson_delivery: 2.3, subject_command: 1.9, effective_pedagogy: 2.3,
        effective_resource_use: 2.1, activity_based_learning: 2.4, student_participation: 2.2, critical_thinking: 2.1,
        inclusive_practices: 2.0, technology_integration: 1.8, technology_handling: 2.0, verbal_communication: 2.5, non_verbal_communication: 2.3
      },
      {
        user_id: '4', teacher_name: 'Zainab Raza', school: 'ICG, F-6/2', sector: 'Urban-1',
        overall_percentage: 62, total_score: 2.48, created_date: new Date().toISOString(),
        grade: 'VI-X', subject: 'Science',
        accurate_lesson_planning: 3.0, timely_lesson_delivery: 2.5, subject_command: 2.1, effective_pedagogy: 2.5,
        effective_resource_use: 2.3, activity_based_learning: 2.6, student_participation: 2.4, critical_thinking: 2.3,
        inclusive_practices: 2.1, technology_integration: 2.0, technology_handling: 2.2, verbal_communication: 2.7, non_verbal_communication: 2.5
      },
      {
        user_id: '5', teacher_name: 'Hira Khan', school: 'IMS(I-V) F-6/1', sector: 'Urban-1',
        overall_percentage: 68, total_score: 2.72, created_date: new Date().toISOString(),
        grade: 'I-V', subject: 'Urdu',
        accurate_lesson_planning: 3.1, timely_lesson_delivery: 2.8, subject_command: 2.4, effective_pedagogy: 2.8,
        effective_resource_use: 2.6, activity_based_learning: 2.9, student_participation: 2.7, critical_thinking: 2.6,
        inclusive_practices: 2.5, technology_integration: 2.2, technology_handling: 2.5, verbal_communication: 2.9, non_verbal_communication: 2.8
      },
      {
        user_id: '6', teacher_name: 'Nida Hassan', school: 'IMS(I-V) G-6/4', sector: 'Urban-1',
        overall_percentage: 75, total_score: 3.0, created_date: new Date().toISOString(),
        grade: 'I-V', subject: 'Math',
        accurate_lesson_planning: 3.3, timely_lesson_delivery: 3.0, subject_command: 2.8, effective_pedagogy: 3.0,
        effective_resource_use: 2.8, activity_based_learning: 3.1, student_participation: 2.9, critical_thinking: 2.8,
        inclusive_practices: 2.7, technology_integration: 2.5, technology_handling: 2.8, verbal_communication: 3.1, non_verbal_communication: 3.0
      },
      {
        user_id: '7', teacher_name: 'Aisha Syed', school: 'IMCG, F-8/1', sector: 'Urban-1',
        overall_percentage: 82, total_score: 3.28, created_date: new Date().toISOString(),
        grade: 'VI-X', subject: 'English',
        accurate_lesson_planning: 3.6, timely_lesson_delivery: 3.3, subject_command: 3.1, effective_pedagogy: 3.3,
        effective_resource_use: 3.1, activity_based_learning: 3.4, student_participation: 3.2, critical_thinking: 3.1,
        inclusive_practices: 3.0, technology_integration: 2.9, technology_handling: 3.1, verbal_communication: 3.4, non_verbal_communication: 3.3
      },
      {
        user_id: '8', teacher_name: 'Rabia Ali', school: 'IMS(I-V) G-7/4', sector: 'Urban-1',
        overall_percentage: 88, total_score: 3.52, created_date: new Date().toISOString(),
        grade: 'I-V', subject: 'Science',
        accurate_lesson_planning: 3.8, timely_lesson_delivery: 3.6, subject_command: 3.4, effective_pedagogy: 3.6,
        effective_resource_use: 3.4, activity_based_learning: 3.7, student_participation: 3.5, critical_thinking: 3.4,
        inclusive_practices: 3.3, technology_integration: 3.2, technology_handling: 3.4, verbal_communication: 3.7, non_verbal_communication: 3.6
      },
    ];
    return testTeachers;
  }, []);

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

      // Load observations to compute visited teachers + urgency signals
      type UrgencyInfo = { lastVisitDate: Date | null; scoreTrend: 'falling' | 'flat' | 'improving' | null };
      const urgencyMap = new Map<string, UrgencyInfo>();
      if (user && coachSubRegion) {
        try {
          const observations = await listObservationsForObserver(user.id, coachSubRegion);
          const cycleDate = getCycleStartDate();
          const submittedObs = observations
            .filter(o => o.status === 'Submitted' || o.status === 'Approved')
            .filter(o => !cycleDate || (o.submitted_at && new Date(o.submitted_at) >= cycleDate));
          const visited = new Set(submittedObs.map(o => o.teacher_name));
          setVisitedTeachers(visited);

          // Group by teacher, sorted newest first
          const byTeacher = new Map<string, typeof submittedObs>();
          for (const obs of submittedObs) {
            if (!byTeacher.has(obs.teacher_name)) byTeacher.set(obs.teacher_name, []);
            byTeacher.get(obs.teacher_name)!.push(obs);
          }
          for (const [name, obs] of byTeacher.entries()) {
            obs.sort((a, b) => new Date(b.submitted_at || 0).getTime() - new Date(a.submitted_at || 0).getTime());
            urgencyMap.set(name, {
              lastVisitDate: obs[0].submitted_at ? new Date(obs[0].submitted_at) : null,
              scoreTrend: obs.length >= 2 ? getScoreTrend(obs[0].total_score, obs[1].total_score) : null,
            });
          }
        } catch (obsErr) {
          console.error('Failed to load observations:', obsErr);
        }
      }

      let query = typedSupabase
        .from('teacher_dc_scores')
        .select('*');

      if (coachSubRegion) {
        query = query.eq('region', coachSubRegion);
      }

      const { data, error: queryError } = await query;

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
        // No database data - try mock test data for local testing
        if (coachSubRegion === 'Urban-1') {
          const mockData = getMockTestData();
          setTeachers(mockData);
          writeCache(mockData, coachSubRegion);
          setConnectionError(false);
        } else if (cache.teachers) {
          setIsOffline(true);
          setTeachers([]);
        } else {
          setError('No teachers assigned to your sub-region.');
          setTeachers([]);
        }
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
        const mappedTeachers: DCTeacher[] = data.map((row: DbRow) => {
          const pct = row.raw_results?.overall_percentage || 0;
          const info = urgencyMap.get(row.teacher_name);
          const neverObserved = !info;
          const lastVisitDate = info?.lastVisitDate ?? null;
          const scoreTrend = info?.scoreTrend ?? null;
          const tier = assignPriorityTier(pct, neverObserved);
          const interval = getVisitInterval(tier);
          const daysOverdue = calculateDaysOverdue(lastVisitDate, interval);
          const urgency = neverObserved ? 9999 : daysOverdue + (scoreTrend === 'falling' ? 10 : 0) - (scoreTrend === 'improving' ? 5 : 0);
          return {
            user_id: row.id,
            teacher_name: row.teacher_name,
            school: row.school_name,
            sector: row.region,
            overall_percentage: pct,
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
            lastVisitDate,
            daysOverdue,
            scoreTrend,
            neverObserved,
            urgency,
          };
        });
        mappedTeachers.sort((a, b) => (b.urgency ?? 0) - (a.urgency ?? 0));
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
  }, [coachSubRegion, readCache, writeCache, getMockTestData]);

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
        visit_purpose: formData.visit_purpose || `${formData.visit_type} observation`,
        status: 'Scheduled',
        region: coachRegion || coachSubRegion || teacher.sector,
        week: formData.week,
        visit_type: formData.visit_type,
        planned_date: formData.planned_date,
        arrival_time: formData.arrival_time,
        departure_time: formData.departure_time,
        is_multi_grade: formData.is_multi_grade,
      });

      console.log('[handleScheduleVisit] Visit created successfully:', data);
      toast.success('Visit scheduled!');
      console.log('[handleScheduleVisit] Calling onNewObservation callback');
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

  // Region routing - only show ICT view for now
  const regionLower = coachRegion?.toLowerCase() || '';
  const isICT = !regionLower || regionLower.includes('ict') || regionLower.includes('islamabad');
  const isPindi = regionLower.includes('pindi') || regionLower.includes('rawalpindi');
  const isPunjab = regionLower.includes('punjab');

  // Pindi view (placeholder)
  if (isPindi) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <AlertCircle className="w-10 h-10 text-blue-600 mb-3" />
        <h3 className="font-semibold text-foreground mb-1">Pindi Smart Schedule</h3>
        <p className="text-sm text-muted-foreground max-w-xs">
          Coming soon — Pindi coaching structure is being set up
        </p>
      </div>
    );
  }

  // Punjab view (placeholder)
  if (isPunjab) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <AlertCircle className="w-10 h-10 text-blue-600 mb-3" />
        <h3 className="font-semibold text-foreground mb-1">Punjab Smart Schedule</h3>
        <p className="text-sm text-muted-foreground max-w-xs">
          Coming soon — Punjab cluster structure is being set up
        </p>
      </div>
    );
  }

  // ICT view - requires sub-region
  if (!coachSubRegion) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <AlertCircle className="w-10 h-10 text-amber-600 mb-3" />
        <h3 className="font-semibold text-foreground mb-1">No sub-region assigned</h3>
        <p className="text-sm text-muted-foreground max-w-xs">
          Your profile does not have a sub-region assigned. Please contact admin.
        </p>
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

  // Teacher list view (ICT)
  const visitedCount = visitedTeachers.size;
  const totalCount = teachers.length;
  const progressPercent = totalCount > 0 ? Math.round((visitedCount / totalCount) * 100) : 0;

  return (
    <div className="space-y-4">
      <div>
        <h2 className="font-display text-lg font-semibold text-foreground">Smart Schedule</h2>
        <p className="text-sm text-muted-foreground">
          Sub-region: <span className="font-medium text-foreground">{coachSubRegion}</span>
          {' '}· {teachers.length} teacher{teachers.length !== 1 ? 's' : ''} · Ranked by coaching priority
        </p>
      </div>

      {/* Progress bar */}
      {totalCount > 0 && (
        <div className="bg-slate-50 border border-slate-200 rounded-lg p-4 space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-foreground">
              {visitedCount} / {totalCount} teachers visited
            </span>
            <span className="text-xs text-muted-foreground">{progressPercent}%</span>
          </div>
          <div className="w-full bg-slate-200 rounded-full h-2">
            <div
              className="bg-green-600 h-2 rounded-full transition-all duration-300"
              style={{ width: `${progressPercent}%` }}
            />
          </div>
          <button
            onClick={() => {
              if (window.confirm('Reset coaching cycle? This will clear your progress count and start fresh.')) {
                resetCycle();
                window.location.reload();
              }
            }}
            className="text-xs font-medium text-slate-600 hover:text-slate-800 mt-2 underline"
          >
            Start New Cycle
          </button>
        </div>
      )}

      <DCDashboard
        teachers={teachers}
        loading={loading}
        onScheduleVisit={handleScheduleVisit}
        coachName={coachName}
        subRegion={coachSubRegion || 'Unknown'}
        isOffline={isOffline}
        lastSynced={lastSynced}
        onRetry={loadData}
        visitedTeachers={visitedTeachers}
      />
    </div>
  );
}
