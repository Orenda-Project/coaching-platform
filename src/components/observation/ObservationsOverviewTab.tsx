import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import {
  BarChart2,
  School,
  Users,
  CheckCircle,
  TrendingUp,
  Award,
} from 'lucide-react';
import { getProficiencyLevel } from '@/lib/observation-utils';
import type { CotObservation, ObservationStatus } from '@/types/observation';

interface Props {
  observations: CotObservation[];
}

const STATUS_BADGE: Record<ObservationStatus, string> = {
  Scheduled: 'text-blue-600 border-blue-200 bg-blue-50',
  Draft: 'text-orange-600 border-orange-200 bg-orange-50',
  Submitted: 'text-green-600 border-green-200 bg-green-50',
  Approved: 'text-emerald-700 border-emerald-200 bg-emerald-50',
};

export function ObservationsOverviewTab({ observations }: Props) {
  const completed = observations.filter(
    o => o.status === 'Submitted' || o.status === 'Approved',
  );
  const uniqueSchools = new Set(observations.map(o => o.school_name)).size;
  const uniqueTeachers = new Set(observations.map(o => o.teacher_name)).size;

  const avgScore =
    completed.length > 0
      ? Math.round(completed.reduce((sum, o) => sum + (o.total_score || 0), 0) / completed.length)
      : 0;

  const avgProficiency = avgScore > 0 ? getProficiencyLevel(avgScore) : null;

  const statusCounts: Record<ObservationStatus, number> = {
    Scheduled: observations.filter(o => o.status === 'Scheduled').length,
    Draft: observations.filter(o => o.status === 'Draft').length,
    Submitted: observations.filter(o => o.status === 'Submitted').length,
    Approved: observations.filter(o => o.status === 'Approved').length,
  };

  const stats = [
    { label: 'Total Visits', value: observations.length, Icon: BarChart2, color: 'text-blue-600', bg: 'bg-blue-50' },
    { label: 'Schools Covered', value: uniqueSchools, Icon: School, color: 'text-green-600', bg: 'bg-green-50' },
    { label: 'Teachers Observed', value: uniqueTeachers, Icon: Users, color: 'text-purple-600', bg: 'bg-purple-50' },
    { label: 'Completed', value: completed.length, Icon: CheckCircle, color: 'text-emerald-600', bg: 'bg-emerald-50' },
  ];

  if (observations.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <Award className="w-10 h-10 text-muted-foreground mb-3" />
        <h3 className="font-semibold text-foreground mb-1">No observations yet</h3>
        <p className="text-sm text-muted-foreground">
          Schedule your first visit to start tracking your coaching impact
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-5">
      <div>
        <h2 className="font-display text-lg font-semibold text-foreground">Overview</h2>
        <p className="text-sm text-muted-foreground">Your observation activity at a glance</p>
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {stats.map(({ label, value, Icon, color, bg }) => (
          <Card key={label} className="glass-card">
            <CardContent className="p-4">
              <div className={`w-8 h-8 rounded-lg ${bg} flex items-center justify-center mb-2`}>
                <Icon className={`w-4 h-4 ${color}`} />
              </div>
              <div className="text-2xl font-bold text-foreground">{value}</div>
              <div className="text-xs text-muted-foreground">{label}</div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Average score */}
      {avgProficiency && (
        <Card className={`glass-card border ${avgProficiency.borderColor}`}>
          <CardContent className={`p-4 rounded-lg ${avgProficiency.bgColor}`}>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <TrendingUp className={`w-5 h-5 ${avgProficiency.color}`} />
                <div>
                  <p className="text-sm font-semibold text-foreground">Avg. HOTs Score</p>
                  <p className="text-xs text-muted-foreground">
                    Across {completed.length} submitted observation
                    {completed.length !== 1 ? 's' : ''}
                  </p>
                </div>
              </div>
              <div className="text-right">
                <div className={`text-2xl font-bold ${avgProficiency.color}`}>{avgScore}/80</div>
                <div className={`text-xs font-medium ${avgProficiency.color}`}>
                  {avgProficiency.level}
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Status breakdown */}
      <Card className="glass-card">
        <CardHeader className="pt-4 pb-2 px-4">
          <CardTitle className="text-sm font-semibold">Status Breakdown</CardTitle>
        </CardHeader>
        <CardContent className="px-4 pb-4">
          <div className="grid grid-cols-2 gap-2">
            {(Object.entries(statusCounts) as [ObservationStatus, number][]).map(([status, count]) => (
              <div
                key={status}
                className="flex items-center justify-between rounded-md px-3 py-2 bg-muted/30"
              >
                <Badge variant="outline" className={`text-xs ${STATUS_BADGE[status]}`}>
                  {status}
                </Badge>
                <span className="font-bold text-foreground">{count}</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* All observations table */}
      <Card className="glass-card">
        <CardHeader className="pt-4 pb-2 px-4">
          <CardTitle className="text-sm font-semibold">All Observations</CardTitle>
        </CardHeader>
        <CardContent className="px-4 pb-4">
          <div className="space-y-0">
            {observations.map((obs, idx) => {
              const prof = obs.total_score > 0 ? getProficiencyLevel(obs.total_score) : null;
              return (
                <div
                  key={obs.id}
                  className={`flex items-center justify-between py-2.5 gap-3 ${
                    idx < observations.length - 1 ? 'border-b border-border' : ''
                  }`}
                >
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-foreground truncate">
                      {obs.teacher_name}
                    </p>
                    <p className="text-xs text-muted-foreground truncate">
                      {obs.school_name} · {obs.subject} · {obs.grade}
                    </p>
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    {prof && (
                      <span className={`text-xs font-medium ${prof.color}`}>
                        {obs.total_score}/80
                      </span>
                    )}
                    <Badge
                      variant="outline"
                      className={`text-xs ${STATUS_BADGE[obs.status]}`}
                    >
                      {obs.status}
                    </Badge>
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
