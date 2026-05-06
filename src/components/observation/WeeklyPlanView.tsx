import { ScheduledVisit } from '@/lib/scheduler-utils';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';

const tierColors: Record<string, string> = {
  CRITICAL: 'bg-red-100 text-red-800',
  HIGH: 'bg-yellow-100 text-yellow-800',
  MEDIUM: 'bg-blue-100 text-blue-800',
  LOW: 'bg-green-100 text-green-800',
};

interface WeeklyPlanViewProps {
  schedule: ScheduledVisit[];
  onAddToSchedule: (visit: ScheduledVisit) => void;
}

export default function WeeklyPlanView({
  schedule,
  onAddToSchedule,
}: WeeklyPlanViewProps) {
  if (schedule.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-600">
          No visits scheduled for this week. All teachers are covered in future weeks.
        </p>
      </div>
    );
  }

  // Group by day
  const byDay = new Map<string, ScheduledVisit[]>();
  schedule.forEach((visit) => {
    const key = visit.dayOfWeek;
    if (!byDay.has(key)) byDay.set(key, []);
    byDay.get(key)!.push(visit);
  });

  const dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  const sortedDays = dayOrder.filter((day) => byDay.has(day));

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {sortedDays.map((day) => (
          <Card key={day} className="p-4 border-l-4 border-l-blue-400">
            <h3 className="font-semibold text-gray-900 mb-3">{day}</h3>
            <div className="space-y-2">
              {byDay.get(day)!.map((visit, idx) => (
                <div
                  key={idx}
                  className="bg-gray-50 p-3 rounded border border-gray-200"
                >
                  <div className="flex justify-between items-start mb-1">
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">
                        {visit.teacher_name}
                      </p>
                      <p className="text-sm text-gray-600">{visit.school_name}</p>
                      <p className="text-xs text-gray-500 mt-1">{visit.purpose}</p>
                    </div>
                    <Badge className={tierColors[visit.tier]}>
                      {visit.tier}
                    </Badge>
                  </div>
                  <Button
                    variant="outline"
                    size="sm"
                    className="mt-2 w-full"
                    onClick={() => onAddToSchedule(visit)}
                  >
                    Add to Schedule
                  </Button>
                </div>
              ))}
            </div>
          </Card>
        ))}
      </div>

      <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
        <p className="text-sm text-blue-900">
          <strong>Weekly Capacity:</strong> {schedule.length} visits scheduled out of 8
          available slots. {schedule.length < 8 && `${8 - schedule.length} slot(s) available.`}
        </p>
      </div>
    </div>
  );
}
