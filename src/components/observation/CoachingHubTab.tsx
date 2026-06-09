import { useState } from 'react';
import { useObservation } from '@/hooks/useObservation';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  CalendarDays,
  MapPin,
  User,
  BookOpen,
  Play,
  Plus,
  Clock,
  Trash2,
} from 'lucide-react';
import { toast } from 'sonner';
import { ScheduleDialog } from './ScheduleDialog';
import { formatObservationDate, formatObservationTime } from '@/lib/observation-utils';
import type { CotObservation } from '@/types/observation';

interface Props {
  observations: CotObservation[];
  onRefresh: () => void;
  onStarted: (obs: CotObservation) => void;
  onNewObservation?: (obs: CotObservation) => void;
}

export function CoachingHubTab({ observations, onRefresh, onStarted }: Props) {
  const { updateObservation, deleteObservation } = useObservation();
  const [scheduleOpen, setScheduleOpen] = useState(false);
  const [startingId, setStartingId] = useState<string | null>(null);
  const [confirmDeleteId, setConfirmDeleteId] = useState<string | null>(null);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const handleDelete = async (id: string) => {
    setDeletingId(id);
    try {
      await deleteObservation(id);
      setDeletingId(null);
      setConfirmDeleteId(null);
      toast.success('Observation deleted');
      onRefresh();
    } catch {
      toast.error('Failed to delete observation');
      setDeletingId(null);
    }
  };

  const scheduled = observations.filter(o => o.status === 'Scheduled');

  const handleStart = async (obs: CotObservation) => {
    setStartingId(obs.id);
    try {
      await updateObservation(obs.id, { status: 'Draft' } as never);
      setStartingId(null);
      toast.success('Observation started — go to Draft Observations to complete it');
      onRefresh();
      onStarted({ ...obs, status: 'Draft' });
    } catch {
      toast.error('Failed to start observation');
      setStartingId(null);
    }
  };

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-display text-lg font-semibold text-foreground">Scheduled Visits</h2>
          <p className="text-sm text-muted-foreground">
            {scheduled.length} upcoming visit{scheduled.length !== 1 ? 's' : ''}
          </p>
        </div>
        <Button size="sm" onClick={() => setScheduleOpen(true)}>
          <Plus className="w-4 h-4 mr-1" /> Schedule New Visit
        </Button>
      </div>

      {/* Empty state */}
      {scheduled.length === 0 && (
        <Card className="glass-card">
          <CardContent className="flex flex-col items-center justify-center py-14 text-center">
            <CalendarDays className="w-10 h-10 text-muted-foreground mb-3" />
            <h3 className="font-semibold text-foreground mb-1">No upcoming visits</h3>
            <p className="text-sm text-muted-foreground mb-4">
              Schedule your first school observation visit to get started
            </p>
            <Button size="sm" onClick={() => setScheduleOpen(true)}>
              <Plus className="w-4 h-4 mr-1" /> Schedule New Visit
            </Button>
          </CardContent>
        </Card>
      )}

      {/* Scheduled cards */}
      {scheduled.length > 0 && (
        <div className="space-y-3">
          {scheduled.map(obs => (
            <Card key={obs.id} className="glass-card">
              <CardContent className="p-4">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1 space-y-2">
                    {/* Status + date row */}
                    <div className="flex items-center gap-2 flex-wrap">
                      <Badge
                        variant="outline"
                        className="text-blue-600 border-blue-200 bg-blue-50 text-xs"
                      >
                        <Clock className="w-3 h-3 mr-1" /> Scheduled
                      </Badge>
                      <span className="text-xs text-muted-foreground">
                        {formatObservationDate(obs.date)} at {formatObservationTime(obs.date)}
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

                  {/* Actions */}
                  <div className="flex flex-col items-end gap-2 shrink-0">
                    <Button
                      size="sm"
                      onClick={() => handleStart(obs)}
                      disabled={startingId === obs.id}
                    >
                      <Play className="w-3.5 h-3.5 mr-1" />
                      {startingId === obs.id ? 'Starting...' : 'Start'}
                    </Button>

                    {confirmDeleteId === obs.id ? (
                      <div className="flex items-center gap-1.5">
                        <span className="text-xs text-muted-foreground">Delete?</span>
                        <Button
                          size="sm"
                          variant="destructive"
                          className="h-7 px-2 text-xs"
                          onClick={() => handleDelete(obs.id)}
                          disabled={deletingId === obs.id}
                        >
                          {deletingId === obs.id ? '…' : 'Yes'}
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          className="h-7 px-2 text-xs"
                          onClick={() => setConfirmDeleteId(null)}
                        >
                          No
                        </Button>
                      </div>
                    ) : (
                      <Button
                        size="sm"
                        variant="ghost"
                        className="h-7 px-2 text-xs text-muted-foreground hover:text-destructive"
                        onClick={() => setConfirmDeleteId(obs.id)}
                      >
                        <Trash2 className="w-3.5 h-3.5 mr-1" /> Delete
                      </Button>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      <ScheduleDialog
        open={scheduleOpen}
        onClose={() => setScheduleOpen(false)}
         
        onScheduled={(obs: any) => { onRefresh(); (window as any).onNewObservation?.(obs); }}
      />
    </div>
  );
}
