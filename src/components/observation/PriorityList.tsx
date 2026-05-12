import { RankedTeacher, ScheduledVisit } from '@/lib/scheduler-utils';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card } from '@/components/ui/card';

const tierColors: Record<string, { bg: string; text: string; badge: string }> = {
  CRITICAL: { bg: 'bg-red-50', text: 'text-red-700', badge: 'bg-red-100 text-red-800' },
  HIGH: { bg: 'bg-red-50', text: 'text-red-700', badge: 'bg-red-100 text-red-800' },
  MEDIUM: { bg: 'bg-yellow-50', text: 'text-yellow-700', badge: 'bg-yellow-100 text-yellow-800' },
  LOW: { bg: 'bg-green-50', text: 'text-green-700', badge: 'bg-green-100 text-green-800' },
};

const tierLabel: Record<string, string> = {
  CRITICAL: 'Priority Tier 1',
  HIGH: 'Priority Tier 1',
  MEDIUM: 'Priority Tier 2',
  LOW: 'Priority Tier 3',
};

interface PriorityListProps {
  rankedTeachers: RankedTeacher[];
  onRemoveTeacher: (teacherName: string, schoolName: string) => void;
  onAddToSchedule: (visit: ScheduledVisit) => void;
}

export default function PriorityList({
  rankedTeachers,
  onRemoveTeacher,
  onAddToSchedule,
}: PriorityListProps) {
  if (rankedTeachers.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-600">No teachers in priority list.</p>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {rankedTeachers.map((teacher, idx) => {
        const colors = tierColors[teacher.tier];
        const scoreDisplay = teacher.latestScore !== null
          ? `${teacher.latestScore}%`
          : 'Never observed';

        return (
          <Card
            key={`${teacher.teacher_name}-${teacher.school_name}-${idx}`}
            className={`p-4 ${colors.bg} border-l-4 ${
              teacher.tier === 'CRITICAL'
                ? 'border-l-red-500'
                : teacher.tier === 'HIGH'
                ? 'border-l-yellow-500'
                : teacher.tier === 'MEDIUM'
                ? 'border-l-blue-500'
                : 'border-l-green-500'
            }`}
          >
            <div className="flex justify-between items-start">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="font-semibold text-gray-900">
                    {teacher.teacher_name}
                  </h3>
                  <Badge className={colors.badge}>{tierLabel[teacher.tier]}</Badge>
                </div>
                <p className="text-sm text-gray-700 mb-2">
                  {teacher.school_name}
                </p>
                <div className="flex gap-4 text-xs text-gray-600">
                  <span>Score: <strong>{scoreDisplay}</strong></span>
                  {teacher.lastVisitDate && (
                    <span>
                      Last visit:{' '}
                      <strong>
                        {teacher.lastVisitDate.toLocaleDateString('en-US', {
                          month: 'short',
                          day: 'numeric',
                        })}
                      </strong>
                    </span>
                  )}
                  {teacher.scoreTrend && (
                    <span>
                      Trend: <strong>{teacher.scoreTrend}</strong>
                    </span>
                  )}
                </div>
              </div>

              <div className="flex gap-2 ml-4">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() =>
                    onAddToSchedule({
                      teacher_name: teacher.teacher_name,
                      school_name: teacher.school_name,
                      date: new Date(),
                      dayOfWeek: '',
                      tier: teacher.tier,
                      purpose: `Visit ${teacher.teacher_name} (${teacher.tier})`,
                      urgency: teacher.urgency,
                    })
                  }
                >
                  Schedule
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() =>
                    onRemoveTeacher(teacher.teacher_name, teacher.school_name)
                  }
                  className="text-red-600 hover:text-red-700 hover:bg-red-50"
                >
                  Remove
                </Button>
              </div>
            </div>
          </Card>
        );
      })}
    </div>
  );
}
