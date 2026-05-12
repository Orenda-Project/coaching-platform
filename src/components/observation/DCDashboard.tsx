import { useState, useMemo } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { TrendingDown, TrendingUp, BarChart3, AlertCircle, RefreshCw } from 'lucide-react';

interface DCTeacher {
  user_id: string;
  teacher_name: string;
  school: string;
  sector: string;
  overall_percentage: number;
  total_score: number;
  created_date: string;
  grade: string;
  subject: string;
  accurate_lesson_planning: number;
  timely_lesson_delivery: number;
  subject_command: number;
  effective_pedagogy: number;
  effective_resource_use: number;
  activity_based_learning: number;
  student_participation: number;
  critical_thinking: number;
  inclusive_practices: number;
  technology_integration: number;
  technology_handling: number;
  verbal_communication: number;
  non_verbal_communication: number;
}

interface Props {
  teachers: DCTeacher[];
  onScheduleVisit: (teacher: DCTeacher) => void;
  loading: boolean;
  isOffline?: boolean;
  lastSynced?: string | null;
  onRetry?: () => void;
}

const INDICATORS = [
  { key: 'accurate_lesson_planning', label: 'Lesson Planning' },
  { key: 'timely_lesson_delivery', label: 'Lesson Delivery' },
  { key: 'subject_command', label: 'Subject Mastery' },
  { key: 'effective_pedagogy', label: 'Pedagogy' },
  { key: 'effective_resource_use', label: 'Resource Use' },
  { key: 'activity_based_learning', label: 'Activity-Based' },
  { key: 'student_participation', label: 'Participation' },
  { key: 'critical_thinking', label: 'Critical Thinking' },
  { key: 'inclusive_practices', label: 'Inclusion' },
  { key: 'technology_integration', label: 'Tech Integration' },
  { key: 'technology_handling', label: 'Tech Skills' },
  { key: 'verbal_communication', label: 'Verbal' },
  { key: 'non_verbal_communication', label: 'Non-Verbal' },
];

function getScoreColor(percentage: number) {
  if (percentage >= 90) return 'text-green-600';
  if (percentage >= 75) return 'text-blue-600';
  if (percentage >= 60) return 'text-yellow-600';
  return 'text-red-600';
}

function getScoreBg(percentage: number) {
  if (percentage >= 90) return 'bg-green-50';
  if (percentage >= 75) return 'bg-blue-50';
  if (percentage >= 60) return 'bg-yellow-50';
  return 'bg-red-50';
}

function getPriorityTier(percentage: number): { label: string; description: string; headerBg: string; headerText: string } {
  if (percentage < 60) return { label: 'Priority Tier 1', description: 'Lowest Scores — Needs Immediate Coaching', headerBg: 'bg-red-100', headerText: 'text-red-800' };
  if (percentage < 75) return { label: 'Priority Tier 2', description: 'Middle Scores — Needs Regular Support', headerBg: 'bg-yellow-100', headerText: 'text-yellow-800' };
  return { label: 'Priority Tier 3', description: 'Highest Scores — Performing Well', headerBg: 'bg-green-100', headerText: 'text-green-800' };
}

function formatRelativeTime(isoString: string | null): string {
  if (!isoString) return 'unknown time';
  const date = new Date(isoString);
  const now = new Date();
  const seconds = Math.floor((now.getTime() - date.getTime()) / 1000);

  if (seconds < 60) return 'just now';
  if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
  if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
  return `${Math.floor(seconds / 86400)}d ago`;
}

function isCacheStale(timestamp: string | null): boolean {
  if (!timestamp) return true;
  const age = Date.now() - new Date(timestamp).getTime();
  const ttl = 24 * 60 * 60 * 1000; // 24 hours
  return age > ttl;
}

export default function DCDashboard({ teachers, onScheduleVisit, loading, isOffline, lastSynced, onRetry }: Props) {
  const [expanded, setExpanded] = useState<string | null>(null);

  const groupedTeachers = useMemo(() => {
    const sorted = [...teachers].sort((a, b) => a.overall_percentage - b.overall_percentage);
    const tier1 = sorted.filter(t => t.overall_percentage < 60);
    const tier2 = sorted.filter(t => t.overall_percentage >= 60 && t.overall_percentage < 75);
    const tier3 = sorted.filter(t => t.overall_percentage >= 75);
    return [
      { tier: getPriorityTier(0), teachers: tier1 },
      { tier: getPriorityTier(60), teachers: tier2 },
      { tier: getPriorityTier(75), teachers: tier3 },
    ].filter(group => group.teachers.length > 0);
  }, [teachers]);

  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  if (teachers.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-12 text-center">
        <BarChart3 className="w-10 h-10 text-muted-foreground mb-3" />
        <h3 className="font-semibold text-foreground mb-1">No DC scores available</h3>
        <p className="text-sm text-muted-foreground max-w-xs">DC observation data will appear here once synced from the Digital Coach dashboard.</p>
      </div>
    );
  }

  const stale = isCacheStale(lastSynced);

  return (
    <div className="space-y-4">
      {isOffline && (
        <div className="rounded-lg border border-amber-200 bg-amber-50 p-3 flex items-start gap-3">
          <AlertCircle className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-amber-900">
              Offline — showing data last synced {formatRelativeTime(lastSynced)}
              {stale && ' (may be outdated)'}
            </p>
          </div>
          {onRetry && (
            <button
              onClick={onRetry}
              className="shrink-0 px-3 py-1.5 rounded-md bg-amber-100 hover:bg-amber-200 text-amber-900 text-xs font-medium transition-colors flex items-center gap-1.5"
            >
              <RefreshCw className="w-3 h-3" />
              Retry
            </button>
          )}
        </div>
      )}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Total Teachers</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{teachers.length}</div>
            <p className="text-xs text-muted-foreground mt-1">with DC observations</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Average Score</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {(teachers.reduce((sum, t) => sum + t.overall_percentage, 0) / teachers.length).toFixed(1)}%
            </div>
            <p className="text-xs text-muted-foreground mt-1">across all indicators</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Needs Support</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">
              {teachers.filter(t => t.overall_percentage < 60).length}
            </div>
            <p className="text-xs text-muted-foreground mt-1">below 60% threshold</p>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="tier1" className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          {groupedTeachers.map((group, idx) => (
            <TabsTrigger key={group.tier.label} value={`tier${idx + 1}`} className="gap-2">
              {group.tier.label} <Badge variant="secondary" className="ml-1">{group.teachers.length}</Badge>
            </TabsTrigger>
          ))}
        </TabsList>

        {groupedTeachers.map((group, idx) => (
          <TabsContent key={group.tier.label} value={`tier${idx + 1}`} className="space-y-2 mt-4">
            {group.teachers.map((teacher) => (
              <div key={teacher.user_id} className={`border rounded-lg p-4 ${getScoreBg(teacher.overall_percentage)}`}>
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="font-semibold text-foreground truncate">{teacher.teacher_name}</h3>
                      <Badge variant="outline" className={`shrink-0 ${getScoreColor(teacher.overall_percentage)}`}>
                        {teacher.overall_percentage.toFixed(1)}%
                      </Badge>
                    </div>
                    <p className="text-sm text-muted-foreground">{teacher.school}</p>
                    <p className="text-xs text-muted-foreground">Grade {teacher.grade} · {teacher.subject} · Last assessed: {new Date(teacher.created_date).toLocaleDateString()}</p>
                  </div>

                  <div className="flex gap-2 shrink-0">
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => setExpanded(expanded === teacher.user_id ? null : teacher.user_id)}
                    >
                      {expanded === teacher.user_id ? 'Hide' : 'View'} Indicators
                    </Button>
                    <Button
                      size="sm"
                      onClick={() => onScheduleVisit(teacher)}
                    >
                      Schedule Visit
                    </Button>
                  </div>
                </div>

                {/* Indicators Grid */}
                {expanded === teacher.user_id && (
                  <div className="mt-4 pt-4 border-t grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
                    {INDICATORS.map((indicator) => {
                      const value = teacher[indicator.key as keyof DCTeacher] as number;
                      const percentage = (value / 4) * 100;
                      return (
                        <div key={indicator.key} className="space-y-1">
                          <div className="flex justify-between items-center">
                            <label className="text-xs font-medium text-foreground">{indicator.label}</label>
                            <span className="text-xs font-bold">{value.toFixed(1)}</span>
                          </div>
                          <Progress value={percentage} className="h-1.5" />
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            ))}
          </TabsContent>
        ))}
      </Tabs>
    </div>
  );
}
