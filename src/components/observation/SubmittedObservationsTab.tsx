import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import {
  User,
  MapPin,
  BookOpen,
  Calendar,
  CheckCircle2,
  Award,
} from 'lucide-react';
import { getProficiencyLevel } from '@/lib/observation-utils';
import { getFicoProficiency } from '@/lib/fico-utils';
import type { CotObservation } from '@/types/observation';

interface Props {
  observations: CotObservation[];
}

const STATUS_COLORS: Record<string, string> = {
  Submitted: 'text-green-700 border-green-200 bg-green-50',
  Approved: 'text-emerald-700 border-emerald-200 bg-emerald-50',
};

export function SubmittedObservationsTab({ observations }: Props) {
  const submitted = observations.filter(o => o.status === 'Submitted' || o.status === 'Approved');

  if (submitted.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <Award className="w-10 h-10 text-muted-foreground mb-3" />
        <h3 className="font-semibold text-foreground mb-1">No submitted observations yet</h3>
        <p className="text-sm text-muted-foreground">
          Complete observations appear here after submission
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-5">
      <div>
        <h2 className="font-display text-lg font-semibold text-foreground">Submitted Observations</h2>
        <p className="text-sm text-muted-foreground">
          {submitted.length} observation{submitted.length !== 1 ? 's' : ''} completed
        </p>
      </div>

      <div className="space-y-3">
        {submitted.map(obs => {
          const isFico = obs.framework === 'FICO';
          const proficiency = obs.total_score > 0
            ? isFico
              ? getFicoProficiency(obs.total_score)
              : getProficiencyLevel(obs.total_score)
            : null;

          return (
            <Card key={obs.id} className="glass-card">
              <CardContent className="p-4">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1 space-y-2">
                    {/* Status + date row */}
                    <div className="flex items-center gap-2 flex-wrap">
                      <Badge
                        variant="outline"
                        className={`text-xs ${STATUS_COLORS[obs.status]}`}
                      >
                        <CheckCircle2 className="w-3 h-3 mr-1" /> {obs.status}
                      </Badge>
                      <span className="text-xs text-muted-foreground">
                        {new Date(obs.submitted_at || obs.created_at).toLocaleDateString('en-US', {
                          month: 'short',
                          day: 'numeric',
                          year: 'numeric',
                        })}
                      </span>
                    </div>

                    {/* Details grid */}
                    <div className="grid grid-cols-2 gap-x-4 gap-y-1 text-sm">
                      <div className="flex items-center gap-1.5">
                        <User className="w-3.5 h-3.5 text-muted-foreground shrink-0" />
                        <span className="font-medium text-foreground truncate">
                          {obs.teacher_name}
                        </span>
                      </div>
                      <div className="flex items-center gap-1.5 text-muted-foreground">
                        <MapPin className="w-3.5 h-3.5 shrink-0" />
                        <span className="truncate">{obs.school_name}</span>
                      </div>
                      <div className="flex items-center gap-1.5 text-muted-foreground">
                        <BookOpen className="w-3.5 h-3.5 shrink-0" />
                        <span>
                          {obs.subject} · {obs.grade}
                        </span>
                      </div>
                      {obs.topic && (
                        <div className="text-xs text-muted-foreground col-span-2">
                          Topic: {obs.topic}
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Score badge */}
                  {proficiency && (
                    <div className="text-right shrink-0">
                      <div className={`text-2xl font-bold ${proficiency.color}`}>
                        {obs.total_score}/{isFico ? '100' : '80'}
                      </div>
                      <div className={`text-xs font-medium ${proficiency.color}`}>
                        {proficiency.level}
                      </div>
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
