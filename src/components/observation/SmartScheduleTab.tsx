import { useCallback, useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { useCoaching } from '@/hooks/useCoaching';
import DCDashboard from './DCDashboard';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { AlertCircle } from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import { toast } from 'sonner';
import { scheduleVisit } from '@/data/observations';
import type { CotObservation, ScheduleVisitFormData } from '@/types/observation';
import type { DCTeacher } from '@/types/teacher';

interface SmartScheduleTabProps {
  onNewObservation?: (obs: CotObservation) => void;
}

export default function SmartScheduleTab({ onNewObservation }: SmartScheduleTabProps) {
  const { user, profile } = useAuth();
  const { loadTeachers } = useCoaching();
  const [teachers, setTeachers] = useState<DCTeacher[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [schedulingTeacherId, setSchedulingTeacherId] = useState<string | null>(null);
  const [isOffline, setIsOffline] = useState(false);
  const [lastSynced, setLastSynced] = useState<string | null>(null);
  const [connectionError, setConnectionError] = useState(false);
  const [showCycleResetModal, setShowCycleResetModal] = useState(false);

  const coachName = profile?.full_name || user?.email || 'Coach';
  const coachSubRegion = (profile as Record<string, unknown>)?.sub_region as string | null || null;

  const [cycleStart, setCycleStart] = useState<Date | null>(() => {
    if (!user?.id) return null;
    const stored = localStorage.getItem(`cycle_start_${user.id}`);
    return stored ? new Date(stored) : null;
  });

  const [visitedTeachers, setVisitedTeachers] = useState<Set<string>>(() => {
    if (!user?.id) return new Set();
    try {
      const raw = localStorage.getItem(`ict_visited_${user.id}`);
      return new Set(raw ? JSON.parse(raw) : []);
    } catch { return new Set(); }
  });

  const markVisitedLocally = (teacherName: string) => {
    if (!user?.id) return;
    const updated = new Set(visitedTeachers);
    updated.add(teacherName);
    localStorage.setItem(`ict_visited_${user.id}`, JSON.stringify([...updated]));
    setVisitedTeachers(updated);
    if (!cycleStart) {
      const newStart = new Date();
      localStorage.setItem(`cycle_start_${user.id}`, newStart.toISOString());
      setCycleStart(newStart);
    }
  };

  const resetCycle = () => {
    if (!user?.id) return;
    if (cycleStart) {
      const prev = JSON.parse(localStorage.getItem(`cycle_history_${user.id}`) || '[]');
      prev.unshift({ startDate: cycleStart.toISOString(), endDate: new Date().toISOString(), visitedCount: visitedTeachers.size, totalCount: teachers.length });
      localStorage.setItem(`cycle_history_${user.id}`, JSON.stringify(prev.slice(0, 10)));
    }
    const newStart = new Date();
    localStorage.setItem(`cycle_start_${user.id}`, newStart.toISOString());
    localStorage.removeItem(`ict_visited_${user.id}`);
    setCycleStart(newStart);
    setVisitedTeachers(new Set());
    toast.success('New cycle started');
  };

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

  const mapTeachersData = useCallback((data: typeof apiTeachers): DCTeacher[] => {
    return data.map((row) => ({
      user_id: row.id,
      teacher_name: row.teacher_name,
      school: row.school_name,
      sector: row.region,
      overall_percentage: row.raw_results?.overall_percentage || 0,
      total_score: row.total_score,
      created_date: row.scored_at ?? null,
      grade: row.grade ?? null,
      subject: row.subject ?? null,
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
  }, []);

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
      const fetchedTeachers = await loadTeachers(coachSubRegion || undefined);

      clearTimeout(timeoutId);

      if (!fetchedTeachers || fetchedTeachers.length === 0) {
        if (cache.teachers) {
          setIsOffline(true);
        } else {
          setError('No teachers assigned to your sub-region.');
        }
        setTeachers([]);
      } else {
        const mappedTeachers = mapTeachersData(fetchedTeachers);
        setTeachers(mappedTeachers);
        writeCache(mappedTeachers, coachSubRegion);
        setIsOffline(false);
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
  }, [coachSubRegion, readCache, writeCache, loadTeachers, mapTeachersData]);

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
        visit_type: formData.visit_type,
        date: formData.date,
        planned_date: formData.planned_date || formData.date,
        arrival_time: formData.arrival_time,
        departure_time: formData.departure_time,
        visit_purpose: formData.visit_purpose,
        status: 'Scheduled',
        region: coachSubRegion || teacher.sector,
      });

      markVisitedLocally(teacher.teacher_name);
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

  // ICT view - requires sub-region
  if (!coachSubRegion) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <AlertCircle className="w-10 h-10 text-amber-600 mb-3" />
        <h3 className="font-semibold text-foreground mb-1">No region assigned</h3>
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

  // Teacher list view
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
          <Button
            size="sm"
            variant="outline"
            onClick={() => setShowCycleResetModal(true)}
            className="mt-2"
          >
            Start New Cycle
          </Button>
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

      <Dialog open={showCycleResetModal} onOpenChange={setShowCycleResetModal}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Start New Cycle?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-muted-foreground">
            Your progress will reset to 0. Previous cycle data will be saved.
          </p>
          {cycleStart && (
            <div className="bg-slate-50 border border-slate-200 rounded p-3 text-sm">
              <p className="font-medium text-foreground">Current cycle</p>
              <p className="text-muted-foreground">
                {visitedTeachers.size}/{teachers.length} teachers visited
                {' · '}since {cycleStart.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' })}
              </p>
            </div>
          )}
          <DialogFooter className="gap-2 sm:gap-0">
            <Button variant="outline" onClick={() => setShowCycleResetModal(false)}>
              Cancel
            </Button>
            <Button onClick={() => { resetCycle(); setShowCycleResetModal(false); }}>
              Start New Cycle
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
