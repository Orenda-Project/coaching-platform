/* eslint-disable @typescript-eslint/no-explicit-any */
import { useCallback, useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { usePunjabCoaching } from '@/hooks/usePunjabCoaching';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import {
  AlertCircle, ChevronDown, ChevronUp, MapPin,
  BookOpen, RefreshCw, CalendarDays, CheckCircle2,
  Clock, User, WifiOff,
} from 'lucide-react';
import { toast } from 'sonner';
import { scheduleVisit } from '@/data/observations';
import { queueVisit, makePseudoObservation, syncPendingVisits } from '@/lib/punjabOfflineQueue';
import { ScheduleVisitModal } from './ScheduleVisitModal';
import type { PunjabTeacher } from '@/types/teacher';
import type { DCTeacher } from '@/types/teacher';
import type { CotObservation, ScheduleVisitFormData } from '@/types/observation';
import {
  PUNJAB_CRITICAL_PCT,
  PUNJAB_ON_TRACK_PCT,
  PUNJAB_WEEKLY_VISIT_TARGET,
  PUNJAB_STAGNATION_OBS_MIN,
  PUNJAB_ESCALATION_OBS_MIN,
} from '@/domain/thresholds';

// Indicator max scores (sum = 51 = max_total_score)
const PUNJAB_INDICATORS = [
  { key: 'classroom_management' as const, label: 'Classroom Management', max: 9, hint: 'Environment fosters open discussion; students engage in complex tasks' },
  { key: 'lesson_planning' as const, label: 'Lesson Planning', max: 9, hint: 'Objectives link to critical thinking; real-world integration' },
  { key: 'instructional_strategies' as const, label: 'Instructional Strategies', max: 12, hint: 'Open-ended questions; problem-solving modeled; scaffolding used' },
  { key: 'student_engagement' as const, label: 'Student Engagement', max: 9, hint: 'Multiple perspectives explored; active discussion and debate' },
  { key: 'assessment_feedback' as const, label: 'Assessment & Feedback', max: 9, hint: 'Self/peer-assessment used; feedback is specific and actionable' },
  { key: 'multigrade_setup' as const, label: 'Multi-grade Setup', max: 3, hint: 'Separate tasks for each grade; non-targeted groups stay engaged' },
];

// Minimal adapter so ScheduleVisitModal (typed for DCTeacher) accepts a PunjabTeacher
function toModalTeacher(t: PunjabTeacher): DCTeacher {
  return {
    user_id: t.id,
    teacher_name: t.teacher_name,
    school: t.school_name,
    sector: t.cluster_name,
    overall_percentage: t.overall_percentage,
    total_score: t.total_score,
    created_date: t.last_observation_date || '',
    grade: t.grade,
    subject: t.subject,
    accurate_lesson_planning: 0,
    timely_lesson_delivery: 0,
    subject_command: 0,
    effective_pedagogy: 0,
    effective_resource_use: 0,
    activity_based_learning: 0,
    student_participation: 0,
    critical_thinking: 0,
    inclusive_practices: 0,
    technology_integration: 0,
    technology_handling: 0,
    verbal_communication: 0,
    non_verbal_communication: 0,
  };
}

function scoreBadgeClass(pct: number) {
  if (pct >= PUNJAB_ON_TRACK_PCT) return 'text-green-700 bg-green-50 border-green-200';
  if (pct >= PUNJAB_CRITICAL_PCT) return 'text-yellow-700 bg-yellow-50 border-yellow-200';
  return 'text-red-700 bg-red-50 border-red-200';
}

function tierLabel(pct: number) {
  if (pct >= PUNJAB_ON_TRACK_PCT) return { label: 'On Track', className: 'text-green-700 bg-green-50 border-green-200' };
  if (pct >= PUNJAB_CRITICAL_PCT) return { label: 'Needs Follow-up', className: 'text-yellow-700 bg-yellow-50 border-yellow-200' };
  return { label: 'Needs Visit', className: 'text-red-700 bg-red-50 border-red-200' };
}

// HOTS rubric level labels per CC-Tool document: Low/Medium/High
function indicatorLevel(score: number, max: number): { label: 'Low' | 'Medium' | 'High'; className: string } {
  const pct = (score / max) * 100;
  if (pct >= PUNJAB_ON_TRACK_PCT) return { label: 'High', className: 'text-green-700' };
  if (pct >= PUNJAB_CRITICAL_PCT) return { label: 'Medium', className: 'text-yellow-700' };
  return { label: 'Low', className: 'text-red-700' };
}

function formatLastVisit(dateStr: string | null) {
  if (!dateStr) return 'No observation';
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
}

// Visited entry shape — migrated from plain string[] to support timestamps
interface VisitedEntry {
  name: string;
  visitedAt: string;
}

function readVisitedEntries(userId: string, fallbackDate: string): VisitedEntry[] {
  try {
    const raw = localStorage.getItem(`punjab_visited_${userId}`);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    // Backward compat: old format was string[]
    if (Array.isArray(parsed) && (parsed.length === 0 || typeof parsed[0] === 'string')) {
      return (parsed as string[]).map(name => ({ name, visitedAt: fallbackDate }));
    }
    return parsed as VisitedEntry[];
  } catch { return []; }
}

interface Props {
  onNewObservation?: (obs: CotObservation) => void;
}

export default function PunjabSmartScheduleTab({ onNewObservation }: Props) {
  const { user, profile } = useAuth();
  const punjabCluster = (profile as Record<string, unknown>)?.punjab_cluster as string | null ?? null;
  const coachName = profile?.full_name || user?.email || 'Coordinator';

  const { teachers, loading, error, isOffline, lastSynced, loadTeachers } = usePunjabCoaching();
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [showSchoolCoverage, setShowSchoolCoverage] = useState(false);
  const [pendingTeacher, setPendingTeacher] = useState<PunjabTeacher | null>(null);
  const [schedulingId, setSchedulingId] = useState<string | null>(null);
  const [showCycleResetModal, setShowCycleResetModal] = useState(false);

  // Flagged-for-RO teachers: persistent localStorage set
  const [flaggedTeachers, setFlaggedTeachers] = useState<Set<string>>(() => {
    if (!user?.id) return new Set();
    try {
      const raw = localStorage.getItem(`punjab_flagged_${user.id}`);
      return new Set(raw ? JSON.parse(raw) : []);
    } catch { return new Set(); }
  });

  const flagForRO = (teacherName: string) => {
    if (!user?.id) return;
    const updated = new Set(flaggedTeachers);
    updated.add(teacherName);
    setFlaggedTeachers(updated);
    localStorage.setItem(`punjab_flagged_${user.id}`, JSON.stringify([...updated]));
    toast.success(`${teacherName} flagged — raise with Regional Office at next sync`);
  };

  const getCycleStartDate = () => {
    if (!user?.id) return null;
    const stored = localStorage.getItem(`punjab_cycle_start_${user.id}`);
    return stored ? new Date(stored) : null;
  };

  const cycleStart = getCycleStartDate();

  // Change G: visited entries with timestamps for weekly pace tracking
  const visitedEntries = user?.id
    ? readVisitedEntries(user.id, cycleStart?.toISOString() ?? new Date().toISOString())
    : [];

  const visitedTeachers = new Set<string>(visitedEntries.map(e => e.name));

  const sevenDaysAgo = Date.now() - 7 * 24 * 60 * 60 * 1000;
  const visitedThisWeek = visitedEntries.filter(e => new Date(e.visitedAt).getTime() > sevenDaysAgo).length;

  const visitedCount = visitedTeachers.size;
  const totalCount = teachers.length;
  const progressPercent = totalCount > 0 ? Math.round((visitedCount / totalCount) * 100) : 0;

  const markVisitedLocally = (teacherName: string) => {
    if (!user?.id) return;
    const filtered = visitedEntries.filter(e => e.name !== teacherName);
    const updated = [...filtered, { name: teacherName, visitedAt: new Date().toISOString() }];
    localStorage.setItem(`punjab_visited_${user.id}`, JSON.stringify(updated));
  };

  const resetCycle = () => {
    if (!user?.id) return;
    const existing = getCycleStartDate();
    if (existing) {
      const prev = JSON.parse(localStorage.getItem(`punjab_cycle_history_${user.id}`) || '[]');
      prev.unshift({ startDate: existing.toISOString(), endDate: new Date().toISOString(), visitedCount, totalCount });
      localStorage.setItem(`punjab_cycle_history_${user.id}`, JSON.stringify(prev.slice(0, 10)));
    }
    localStorage.setItem(`punjab_cycle_start_${user.id}`, new Date().toISOString());
    localStorage.removeItem(`punjab_visited_${user.id}`);
    toast.success('New cycle started');
  };

  const refresh = useCallback(() => {
    if (punjabCluster) loadTeachers(punjabCluster, user?.id ?? undefined);
  }, [punjabCluster, loadTeachers, user?.id]);

  useEffect(() => { refresh(); }, [refresh]);

  // Change F: sync offline queue when connectivity is restored
  useEffect(() => {
    if (!user?.id) return;
    const handler = async () => {
      const { synced } = await syncPendingVisits(user.id);
      if (synced > 0) {
        toast.success(`${synced} offline visit${synced > 1 ? 's' : ''} synced`);
        if (punjabCluster) loadTeachers(punjabCluster, user.id);
      }
    };
    window.addEventListener('online', handler);
    return () => window.removeEventListener('online', handler);
  }, [user?.id, punjabCluster, loadTeachers]);

  // Change F: offline queue integration
  const handleScheduleVisit = async (teacher: PunjabTeacher, formData: ScheduleVisitFormData) => {
    if (!user) return;
    setSchedulingId(teacher.id);

    const payload = {
      teacher_name: teacher.teacher_name,
      school_name: teacher.school_name,
      grade: teacher.grade,
      subject: teacher.subject,
      date: formData.date,
      observer_id: user.id,
      status: 'Scheduled' as const,
      region: punjabCluster || 'Punjab',
      visit_type: formData.visit_type,
      planned_date: formData.planned_date,
      arrival_time: formData.arrival_time,
      departure_time: formData.departure_time,
      week: formData.week,
      is_multi_grade: formData.is_multi_grade,
    } as any;

    try {
      const obs = await scheduleVisit(payload);
      markVisitedLocally(teacher.teacher_name);
      if (!getCycleStartDate()) {
        localStorage.setItem(`punjab_cycle_start_${user.id}`, new Date().toISOString());
      }
      toast.success(`Visit scheduled for ${teacher.teacher_name}`);
      setPendingTeacher(null);
      onNewObservation?.(obs);
    } catch {
      if (!navigator.onLine) {
        const pending = queueVisit(user.id, payload);
        markVisitedLocally(teacher.teacher_name);
        if (!getCycleStartDate()) {
          localStorage.setItem(`punjab_cycle_start_${user.id}`, new Date().toISOString());
        }
        toast.success("Saved offline — will sync when you're back online");
        setPendingTeacher(null);
        onNewObservation?.(makePseudoObservation(pending));
      } else {
        toast.error('Failed to schedule visit');
      }
    } finally {
      setSchedulingId(null);
    }
  };

  // No cluster assigned
  if (!punjabCluster) {
    return (
      <Card className="glass-card">
        <CardContent className="flex flex-col items-center justify-center py-14 text-center gap-4">
          <AlertCircle className="w-10 h-10 text-amber-500" />
          <div>
            <h3 className="font-semibold text-foreground mb-1">Cluster not assigned</h3>
            <p className="text-sm text-muted-foreground max-w-sm">
              Your account doesn't have a Punjab cluster assigned. Please contact your administrator
              to assign your cluster before using this scheduler.
            </p>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  if (error) {
    return (
      <Card className="glass-card">
        <CardContent className="flex flex-col items-center justify-center py-14 text-center gap-3">
          <AlertCircle className="w-8 h-8 text-destructive" />
          <p className="text-sm text-muted-foreground">{error}</p>
          <Button size="sm" variant="outline" onClick={refresh}>
            <RefreshCw className="w-4 h-4 mr-1" /> Retry
          </Button>
        </CardContent>
      </Card>
    );
  }

  const critical = teachers.filter(t => t.overall_percentage < PUNJAB_CRITICAL_PCT);
  const watch = teachers.filter(t => t.overall_percentage >= PUNJAB_CRITICAL_PCT && t.overall_percentage < PUNJAB_ON_TRACK_PCT);
  const onTrack = teachers.filter(t => t.overall_percentage >= PUNJAB_ON_TRACK_PCT);

  // Change A: first unvisited teacher for "Visit Next" card
  const nextTeacher =
    critical.find(t => !visitedTeachers.has(t.teacher_name)) ||
    watch.find(t => !visitedTeachers.has(t.teacher_name)) ||
    onTrack.find(t => !visitedTeachers.has(t.teacher_name));

  // School-level observation frequency (14-day window) — B2 standard
  const schoolFrequency = teachers.reduce((acc, teacher) => {
    const key = teacher.school_name;
    if (!acc[key]) acc[key] = { total: 0, visited: 0 };
    acc[key].total += 1;
    if (visitedTeachers.has(teacher.teacher_name)) acc[key].visited += 1;
    return acc;
  }, {} as Record<string, { total: number; visited: number }>);

  const schoolStatus = Object.entries(schoolFrequency).map(([school, data]: [string, { total: number; visited: number }]) => {
    const pct = (data.visited / data.total) * 100;
    const status: 'red' | 'yellow' | 'green' = pct < 60 ? 'red' : pct < 85 ? 'yellow' : 'green';
    return { school, visited: data.visited, total: data.total, pct, status };
  }).sort((a, b) => a.pct - b.pct);

  return (
    <div className="space-y-5">
      {/* Cluster header */}
      <div className="flex items-start justify-between gap-3">
        <div>
          <h2 className="font-display text-lg font-semibold text-foreground">{punjabCluster}</h2>
          <p className="text-sm text-muted-foreground">
            {totalCount} teachers · {critical.length} need urgent visit
          </p>
        </div>
        <div className="flex items-center gap-2">
          {isOffline && (
            <span className="text-xs text-amber-600 flex items-center gap-1">
              <WifiOff className="w-3 h-3" /> Offline
            </span>
          )}
          {lastSynced && !isOffline && (
            <span className="text-xs text-muted-foreground hidden sm:inline">
              Synced {new Date(lastSynced).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
            </span>
          )}
          <Button size="sm" variant="outline" onClick={refresh}>
            <RefreshCw className="w-3.5 h-3.5 mr-1" /> Refresh
          </Button>
        </div>
      </div>

      {/* Change A: Visit Next card */}
      {totalCount > 0 && (
        nextTeacher ? (
          <Card className="glass-card border-primary/30 bg-primary/5">
            <CardContent className="p-4">
              <p className="text-xs font-semibold text-primary uppercase tracking-wide mb-2">Visit Next</p>
              <div className="flex items-start gap-3">
                <div className={`shrink-0 w-10 h-10 rounded-full border-2 flex items-center justify-center text-xs font-bold ${
                  nextTeacher.overall_percentage >= PUNJAB_ON_TRACK_PCT ? 'border-green-400 text-green-700 bg-green-50' :
                  nextTeacher.overall_percentage >= PUNJAB_CRITICAL_PCT ? 'border-yellow-400 text-yellow-700 bg-yellow-50' :
                  'border-red-400 text-red-700 bg-red-50'
                }`}>
                  {Math.round(nextTeacher.overall_percentage)}%
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-semibold text-foreground text-sm">{nextTeacher.teacher_name}</p>
                  <p className="text-xs text-muted-foreground truncate">{nextTeacher.school_name}</p>
                  <Badge variant="outline" className={`text-xs h-5 mt-1 ${tierLabel(nextTeacher.overall_percentage).className}`}>
                    {tierLabel(nextTeacher.overall_percentage).label}
                  </Badge>
                </div>
                <Button
                  size="sm"
                  className="h-8 shrink-0"
                  disabled={schedulingId === nextTeacher.id}
                  onClick={() => setPendingTeacher(nextTeacher)}
                >
                  <CalendarDays className="w-3.5 h-3.5 mr-1" />
                  Schedule →
                </Button>
              </div>
            </CardContent>
          </Card>
        ) : (
          <Card className="glass-card border-green-200 bg-green-50/50">
            <CardContent className="p-4 flex items-center gap-3">
              <CheckCircle2 className="w-8 h-8 text-green-600 shrink-0" />
              <div>
                <p className="font-semibold text-green-800">All teachers visited this cycle 🎉</p>
                <p className="text-xs text-green-700 mt-0.5">Great work! Consider starting a new cycle.</p>
              </div>
            </CardContent>
          </Card>
        )
      )}

      {/* Change B: Stat summary cards — replace Avg Score with This Week pace */}
      <div className="grid grid-cols-3 gap-3">
        <Card className="glass-card">
          <CardContent className="p-3 text-center">
            <div className="text-2xl font-bold text-foreground">{totalCount}</div>
            <p className="text-xs text-muted-foreground mt-0.5">Total Teachers</p>
          </CardContent>
        </Card>
        <Card className={`glass-card border-l-4 ${visitedThisWeek >= PUNJAB_WEEKLY_VISIT_TARGET ? 'border-l-green-500' : visitedThisWeek >= 1 ? 'border-l-amber-500' : 'border-l-red-400'}`}>
          <CardContent className="p-3 text-center">
            <div className={`text-2xl font-bold ${visitedThisWeek >= PUNJAB_WEEKLY_VISIT_TARGET ? 'text-green-600' : visitedThisWeek >= 1 ? 'text-amber-600' : 'text-red-600'}`}>
              {visitedThisWeek}/{PUNJAB_WEEKLY_VISIT_TARGET}
            </div>
            <p className="text-xs text-muted-foreground mt-0.5">This Week</p>
          </CardContent>
        </Card>
        <Card className="glass-card border-l-4 border-l-red-500">
          <CardContent className="p-3 text-center">
            <div className="text-2xl font-bold text-red-600">{critical.length}</div>
            <p className="text-xs text-muted-foreground mt-0.5">Needs Urgent</p>
          </CardContent>
        </Card>
      </div>

      {/* Change C: Visit progress (was "Cycle Progress") */}
      <Card className="glass-card">
        <CardContent className="p-4 space-y-2">
          <div className="flex items-center justify-between text-sm">
            <span className="font-medium text-foreground">Visit Progress</span>
            <span className="text-muted-foreground">{visitedCount}/{totalCount} visited</span>
          </div>
          <Progress value={progressPercent} className="h-2" />
          <div className="flex items-center justify-between text-xs text-muted-foreground">
            <span>
              {cycleStart
                ? `Since ${cycleStart.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' })}`
                : 'No visits yet this cycle'}
            </span>
            <Button
              size="sm"
              variant="ghost"
              className="h-6 text-xs text-primary px-0 hover:bg-transparent hover:underline"
              onClick={() => setShowCycleResetModal(true)}
            >
              Start New Cycle
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* School-level observation frequency — B2 standard (collapsible) */}
      {schoolStatus.length > 0 && (
        <div className="border border-slate-200 rounded-lg overflow-hidden">
          <button
            className="w-full flex items-center justify-between px-4 py-3 bg-slate-50 hover:bg-slate-100 transition-colors text-sm"
            onClick={() => setShowSchoolCoverage(v => !v)}
          >
            <span className="font-medium text-foreground">
              School Coverage
              <span className="ml-2 text-xs font-normal text-muted-foreground">
                {schoolStatus.filter(s => s.status === 'red').length} urgent · {schoolStatus.filter(s => s.status === 'green').length} on track
              </span>
            </span>
            {showSchoolCoverage ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
          </button>
          {showSchoolCoverage && (
            <div className="p-3 space-y-2 bg-white">
              {schoolStatus.map(s => {
                const bgColor = s.status === 'red' ? 'bg-red-50 border-red-200' : s.status === 'yellow' ? 'bg-amber-50 border-amber-200' : 'bg-green-50 border-green-200';
                const textColor = s.status === 'red' ? 'text-red-900' : s.status === 'yellow' ? 'text-amber-900' : 'text-green-900';
                const statusLabel = s.status === 'red' ? '🔴 Urgent' : s.status === 'yellow' ? '🟡 Partial' : '🟢 On Track';
                return (
                  <div key={s.school} className={`border rounded-lg p-3 ${bgColor}`}>
                    <div className="flex items-center justify-between gap-2">
                      <div className="flex-1 min-w-0">
                        <p className={`text-sm font-medium truncate ${textColor}`}>{s.school}</p>
                        <p className={`text-xs ${textColor} opacity-80`}>
                          {s.visited}/{s.total} teachers visited
                        </p>
                      </div>
                      <span className={`text-xs font-semibold shrink-0 ${textColor}`}>{statusLabel}</span>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      )}

      {/* Tier sections */}
      {[
        { teachers: critical, color: 'red', title: 'Needs Urgent Visit', subtitle: 'Score below 60%' },
        { teachers: watch, color: 'yellow', title: 'Needs Follow-up', subtitle: 'Score 60–74%' },
        { teachers: onTrack, color: 'green', title: 'On Track', subtitle: 'Score 75%+' },
      ].map(({ teachers: tier, color, title, subtitle }) =>
        tier.length > 0 && (
          <div key={title} className="space-y-2">
            <div className="flex items-center gap-2">
              <div className={`w-2.5 h-2.5 rounded-full ${
                color === 'red' ? 'bg-red-500' : color === 'yellow' ? 'bg-yellow-500' : 'bg-green-500'
              }`} />
              <h3 className="text-sm font-semibold text-foreground">{title}</h3>
              <span className="text-xs text-muted-foreground">{subtitle} · {tier.length}</span>
            </div>

            {tier.map(teacher => {
              const isExpanded = expandedId === teacher.id;
              const tier_ = tierLabel(teacher.overall_percentage);
              const isVisited = visitedTeachers.has(teacher.teacher_name);
              // Two-tier escalation per CC-Tool document:
              // obs ≥ STAGNATION_OBS_MIN + score < CRITICAL_PCT → stagnation warning (amber)
              // obs ≥ ESCALATION_OBS_MIN + score < CRITICAL_PCT → escalate to Regional Office (red)
              const isStagnant = teacher.observation_count >= PUNJAB_STAGNATION_OBS_MIN && teacher.overall_percentage < PUNJAB_CRITICAL_PCT;
              const needsEscalation = teacher.observation_count >= PUNJAB_ESCALATION_OBS_MIN && teacher.overall_percentage < PUNJAB_CRITICAL_PCT;
              const isFlagged = flaggedTeachers.has(teacher.teacher_name);

              return (
                <Card key={teacher.id} className="glass-card">
                  <CardContent className="p-4 space-y-3">
                    {/* Top row: score bubble + info */}
                    <div className="flex items-start gap-3">
                      <div className={`shrink-0 w-11 h-11 rounded-full border-2 flex items-center justify-center text-xs font-bold ${
                        teacher.overall_percentage >= PUNJAB_ON_TRACK_PCT ? 'border-green-400 text-green-700 bg-green-50' :
                        teacher.overall_percentage >= PUNJAB_CRITICAL_PCT ? 'border-yellow-400 text-yellow-700 bg-yellow-50' :
                        'border-red-400 text-red-700 bg-red-50'
                      }`}>
                        {Math.round(teacher.overall_percentage)}%
                      </div>

                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 flex-wrap mb-1">
                          <span className="font-medium text-foreground text-sm">{teacher.teacher_name}</span>
                          {isVisited && (
                            <Badge variant="outline" className="text-green-600 border-green-200 bg-green-50 text-xs h-5">
                              <CheckCircle2 className="w-3 h-3 mr-0.5" /> Visited
                            </Badge>
                          )}
                          <Badge variant="outline" className={`text-xs h-5 ${tier_.className}`}>
                            {tier_.label}
                          </Badge>
                          {/* Two-tier stagnation/escalation flags */}
                          {needsEscalation ? (
                            <Badge variant="outline" className="text-red-700 border-red-300 bg-red-50 text-xs h-5">
                              {isFlagged ? '🚩 Flagged for RO' : `Observed ${teacher.observation_count}× · Escalate to RO`}
                            </Badge>
                          ) : isStagnant ? (
                            <Badge variant="outline" className="text-amber-700 border-amber-300 bg-amber-50 text-xs h-5">
                              Observed {teacher.observation_count}× · No improvement
                            </Badge>
                          ) : null}
                        </div>
                        <div className="flex flex-wrap gap-x-3 gap-y-0.5 text-xs text-muted-foreground">
                          <span className="flex items-center gap-1"><MapPin className="w-3 h-3" />{teacher.school_name}</span>
                          <span className="flex items-center gap-1"><BookOpen className="w-3 h-3" />{teacher.subject} · {teacher.grade}</span>
                          <span className="flex items-center gap-1"><Clock className="w-3 h-3" />Last observed: {formatLastVisit(teacher.last_observation_date)}</span>
                        </div>
                      </div>
                    </div>

                    {/* Indicator scores (expandable) — Change D: HOTS rubric labels */}
                    {isExpanded && (
                      <div className="space-y-1.5 border-t border-border pt-3">
                        {PUNJAB_INDICATORS.map(ind => {
                          const raw = teacher[ind.key] as number;
                          const pct = Math.round((raw / ind.max) * 100);
                          const level = indicatorLevel(raw, ind.max);
                          return (
                            <div key={ind.key} className="space-y-0.5">
                              <div className="flex justify-between text-xs">
                                <div>
                                  <span className="text-foreground font-medium">{ind.label}</span>
                                  <p className="text-muted-foreground text-[10px] mt-0.5">{ind.hint}</p>
                                </div>
                                <span className="font-medium shrink-0 ml-2">
                                  {raw}/{ind.max} · <span className={level.className}>{level.label}</span>
                                </span>
                              </div>
                              <div className="h-1.5 bg-muted rounded-full overflow-hidden">
                                <div
                                  className={`h-full rounded-full transition-all ${
                                    pct >= PUNJAB_ON_TRACK_PCT ? 'bg-green-500' : pct >= PUNJAB_CRITICAL_PCT ? 'bg-yellow-500' : 'bg-red-500'
                                  }`}
                                  style={{ width: `${pct}%` }}
                                />
                              </div>
                            </div>
                          );
                        })}
                        <p className="text-xs text-muted-foreground pt-1">
                          Total: {teacher.total_score}/{teacher.max_total_score} · {teacher.observation_count} observation{teacher.observation_count !== 1 ? 's' : ''}
                        </p>
                      </div>
                    )}

                    {/* Bottom action bar */}
                    <div className="flex items-center justify-between pt-1 border-t border-border">
                      <button
                        className="text-xs text-muted-foreground hover:text-foreground flex items-center gap-1 transition-colors"
                        onClick={() => setExpandedId(isExpanded ? null : teacher.id)}
                      >
                        {isExpanded ? <ChevronUp className="w-3.5 h-3.5" /> : <ChevronDown className="w-3.5 h-3.5" />}
                        {isExpanded ? 'Hide scores' : 'View scores'}
                      </button>
                      <div className="flex items-center gap-2">
                        {needsEscalation && !isFlagged && (
                          <Button
                            size="sm"
                            variant="outline"
                            className="h-7 text-xs text-red-700 border-red-300 hover:bg-red-50"
                            onClick={() => flagForRO(teacher.teacher_name)}
                          >
                            🚩 Flag for RO
                          </Button>
                        )}
                        <Button
                          size="sm"
                          variant="outline"
                          className="h-7 text-xs"
                          disabled={schedulingId === teacher.id}
                          onClick={() => setPendingTeacher(teacher)}
                        >
                          <CalendarDays className="w-3.5 h-3.5 mr-1" />
                          {schedulingId === teacher.id ? 'Scheduling…' : 'Schedule Visit'}
                        </Button>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        )
      )}

      {teachers.length === 0 && (
        <Card className="glass-card">
          <CardContent className="flex flex-col items-center justify-center py-14 text-center gap-3">
            <User className="w-10 h-10 text-muted-foreground" />
            <h3 className="font-semibold text-foreground">No teachers found</h3>
            <p className="text-sm text-muted-foreground">
              No teachers in {punjabCluster} yet. Check back after data sync.
            </p>
          </CardContent>
        </Card>
      )}

      {/* Schedule visit modal */}
      {pendingTeacher && (
        <ScheduleVisitModal
          teacher={toModalTeacher(pendingTeacher)}
          coachName={coachName}
          subRegion={punjabCluster}
          onClose={() => setPendingTeacher(null)}
          onConfirm={(formData) => handleScheduleVisit(pendingTeacher, formData)}
        />
      )}

      {/* Cycle reset modal */}
      {showCycleResetModal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-lg p-6 max-w-sm w-full space-y-4 shadow-xl">
            <h3 className="font-semibold text-foreground">Start New Cycle?</h3>
            <p className="text-sm text-muted-foreground">
              Your visit progress will reset to 0. Previous cycle data will be saved.
            </p>
            {cycleStart && (
              <div className="bg-slate-50 border border-slate-200 rounded p-3 text-sm">
                <p className="font-medium text-foreground">Current cycle</p>
                <p className="text-muted-foreground">
                  {visitedCount}/{totalCount} teachers visited
                  {' · '}since {cycleStart.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' })}
                </p>
              </div>
            )}
            <div className="flex gap-3">
              <Button variant="outline" className="flex-1" onClick={() => setShowCycleResetModal(false)}>
                Cancel
              </Button>
              <Button className="flex-1" onClick={() => { resetCycle(); setShowCycleResetModal(false); window.location.reload(); }}>
                Start New Cycle
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
