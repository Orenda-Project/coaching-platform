import { ScheduledVisit, PriorityTier } from '@/lib/scheduler-utils';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';

const tierColors: Record<PriorityTier, string> = {
  CRITICAL: 'bg-red-100 text-red-800 border-red-200',
  HIGH: 'bg-yellow-100 text-yellow-800 border-yellow-200',
  MEDIUM: 'bg-blue-100 text-blue-800 border-blue-200',
  LOW: 'bg-green-100 text-green-800 border-green-200',
};

const tierBorder: Record<PriorityTier, string> = {
  CRITICAL: 'border-l-red-500',
  HIGH: 'border-l-yellow-500',
  MEDIUM: 'border-l-blue-500',
  LOW: 'border-l-green-500',
};

interface Props {
  plan: ScheduledVisit[];
}

export default function FourWeekOverview({ plan }: Props) {
  if (plan.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-muted-foreground">No visits planned. Add DC scores to generate a 4-week plan.</p>
      </div>
    );
  }

  // Group by week number (relative to first visit date)
  const firstDate = plan[0].date;
  const firstMonday = new Date(firstDate);
  const dow = firstMonday.getDay();
  firstMonday.setDate(firstMonday.getDate() - ((dow + 6) % 7));

  const weeks = new Map<number, ScheduledVisit[]>();
  for (const visit of plan) {
    const diffDays = Math.floor((visit.date.getTime() - firstMonday.getTime()) / 86400000);
    const weekNum = Math.floor(diffDays / 7);
    if (!weeks.has(weekNum)) weeks.set(weekNum, []);
    weeks.get(weekNum)!.push(visit);
  }

  const sortedWeeks = Array.from(weeks.entries()).sort(([a], [b]) => a - b);

  return (
    <div className="space-y-6">
      {sortedWeeks.map(([weekIdx, visits]) => {
        const weekStart = new Date(firstMonday);
        weekStart.setDate(weekStart.getDate() + weekIdx * 7);
        const weekEnd = new Date(weekStart);
        weekEnd.setDate(weekEnd.getDate() + 4);

        const criticalCount = visits.filter(v => v.tier === 'CRITICAL').length;

        return (
          <div key={weekIdx}>
            <div className="flex items-center justify-between mb-3">
              <div>
                <h3 className="font-semibold text-foreground">Week {weekIdx + 1}</h3>
                <p className="text-xs text-muted-foreground">
                  {weekStart.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })} —{' '}
                  {weekEnd.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                </p>
              </div>
              <div className="flex gap-2 text-xs">
                <span className="text-muted-foreground">{visits.length} visits</span>
                {criticalCount > 0 && (
                  <span className="text-red-600 font-medium">{criticalCount} critical</span>
                )}
              </div>
            </div>

            <div className="space-y-2">
              {visits.map((visit, idx) => (
                <Card
                  key={idx}
                  className={`p-3 border-l-4 ${tierBorder[visit.tier]}`}
                >
                  <div className="flex items-center justify-between gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-medium text-muted-foreground w-16 shrink-0">
                          {visit.dayOfWeek.slice(0, 3)}
                        </span>
                        <span className="font-medium text-sm text-foreground truncate">
                          {visit.teacher_name}
                        </span>
                      </div>
                      <p className="text-xs text-muted-foreground ml-16 mt-0.5">
                        {visit.school_name} · {visit.purpose}
                      </p>
                    </div>
                    <Badge variant="outline" className={`text-xs shrink-0 ${tierColors[visit.tier]}`}>
                      {visit.tier}
                    </Badge>
                  </div>
                </Card>
              ))}
            </div>
          </div>
        );
      })}

      <div className="p-4 bg-muted/30 rounded-lg border border-border">
        <p className="text-sm text-muted-foreground">
          <strong>{plan.length}</strong> total visits across 4 weeks ·{' '}
          <strong>{plan.filter(v => v.tier === 'CRITICAL').length}</strong> critical ·{' '}
          <strong>{new Set(plan.map(v => v.school_name)).size}</strong> schools
        </p>
      </div>
    </div>
  );
}
