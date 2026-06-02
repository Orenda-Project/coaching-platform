import { useState } from 'react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Clock, CheckCircle2, Trash2, Mic } from 'lucide-react';
import type { CotObservation } from '@/types/observation';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';

interface VisitsDashboardTabProps {
  observations: CotObservation[];
  onStartDebrief: (observation: CotObservation) => void;
  onRefresh: () => void;
}

export function VisitsDashboardTab({
  observations,
  onStartDebrief,
  onRefresh,
}: VisitsDashboardTabProps) {
  const [deleting, setDeleting] = useState<string | null>(null);

  const scheduledVisits = observations.filter(
    (o) => o.status === 'Scheduled' || o.status === 'Draft'
  );

  const completedVisits = observations.filter(
    (o) => o.status === 'Submitted' || o.status === 'Approved'
  );

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this visit?')) {
      return;
    }

    setDeleting(id);
    try {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const typedSupabase = supabase as any;
      const { error } = await typedSupabase
        .from('cot_observations')
        .delete()
        .eq('id', id);

      if (error) throw error;

      toast.success('Visit deleted');
      onRefresh();
    } catch (err) {
      console.error('Failed to delete visit:', err);
      toast.error('Failed to delete visit');
    } finally {
      setDeleting(null);
    }
  };

  const formatDate = (dateStr: string) => {
    try {
      return new Date(dateStr).toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
      });
    } catch {
      return dateStr;
    }
  };

  const ScheduledVisitCard = ({ obs }: { obs: CotObservation }) => (
    <Card className="hover:shadow-md transition-shadow">
      <CardContent className="p-5">
        <div className="space-y-3">
          <div>
            <h3 className="font-semibold text-foreground">{obs.teacher_name}</h3>
            <p className="text-sm text-muted-foreground">{obs.school_name}</p>
          </div>

          <div className="grid grid-cols-2 gap-3 text-sm">
            <div>
              <p className="text-xs font-medium text-muted-foreground">Visit Type</p>
              <p className="text-foreground">{obs.visit_type || 'HOTS'}</p>
            </div>
            <div>
              <p className="text-xs font-medium text-muted-foreground">Subject · Grade</p>
              <p className="text-foreground">
                {obs.subject} · {obs.grade}
              </p>
            </div>
            {obs.planned_date && (
              <div>
                <p className="text-xs font-medium text-muted-foreground">Planned Date</p>
                <p className="text-foreground">{formatDate(obs.planned_date)}</p>
              </div>
            )}
            <div>
              <p className="text-xs font-medium text-muted-foreground">Visit Date</p>
              <p className="text-foreground">{formatDate(obs.date)}</p>
            </div>
            {obs.arrival_time && (
              <div>
                <p className="text-xs font-medium text-muted-foreground">Arrival</p>
                <p className="text-foreground">{obs.arrival_time.slice(0, 5)}</p>
              </div>
            )}
            {obs.departure_time && (
              <div>
                <p className="text-xs font-medium text-muted-foreground">Departure</p>
                <p className="text-foreground">{obs.departure_time.slice(0, 5)}</p>
              </div>
            )}
          </div>

          <div className="flex gap-3 pt-2 justify-end">
            <div className="flex flex-col items-center gap-1">
              <Button
                size="sm"
                variant="ghost"
                onClick={() => onStartDebrief(obs)}
                disabled={obs.status === 'Draft' && obs.neo_status === 'processing'}
                title="Give Neo Feedback"
                className="h-8 w-8 p-0"
              >
                <Mic className="w-3.5 h-3.5" />
              </Button>
              <span className="text-xs text-muted-foreground">Feedback</span>
            </div>
            <div className="flex flex-col items-center gap-1">
              <Button
                size="sm"
                variant="outline"
                onClick={() => handleDelete(obs.id)}
                disabled={deleting === obs.id}
                className="h-8 w-8 p-0"
              >
                <Trash2 className="w-3.5 h-3.5" />
              </Button>
              <span className="text-xs text-muted-foreground">Delete</span>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );

  const CompletedVisitCard = ({ obs }: { obs: CotObservation }) => (
    <Card>
      <CardContent className="p-5">
        <div className="space-y-3">
          <div className="flex items-start justify-between">
            <div>
              <h3 className="font-semibold text-foreground">{obs.teacher_name}</h3>
              <p className="text-sm text-muted-foreground">{obs.school_name}</p>
            </div>
            <div className="flex items-center gap-1 text-green-600">
              <CheckCircle2 className="w-4 h-4" />
              <span className="text-sm font-medium">Completed</span>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3 text-sm">
            <div>
              <p className="text-xs font-medium text-muted-foreground">Visit Type</p>
              <p className="text-foreground">{obs.visit_type || 'HOTS'}</p>
            </div>
            <div>
              <p className="text-xs font-medium text-muted-foreground">Date</p>
              <p className="text-foreground">{formatDate(obs.date)}</p>
            </div>
            {obs.neo_results?.overall_score !== undefined && (
              <div>
                <p className="text-xs font-medium text-muted-foreground">Score</p>
                <p className="text-lg font-semibold text-foreground">
                  {obs.neo_results.overall_score.toFixed(1)}
                </p>
              </div>
            )}
            {obs.neo_results?.grade && (
              <div>
                <p className="text-xs font-medium text-muted-foreground">Grade</p>
                <p className="text-lg font-semibold text-foreground">
                  {obs.neo_results.grade}
                </p>
              </div>
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  );

  return (
    <Tabs defaultValue="scheduled" className="w-full">
      <TabsList className="grid w-full grid-cols-2 mb-6">
        <TabsTrigger value="scheduled" className="gap-1.5">
          <Clock className="w-3.5 h-3.5" />
          <span>Scheduled</span>
          {scheduledVisits.length > 0 && (
            <span className="ml-1.5 bg-primary text-primary-foreground text-xs rounded-full w-5 h-5 flex items-center justify-center font-medium">
              {scheduledVisits.length}
            </span>
          )}
        </TabsTrigger>

        <TabsTrigger value="completed" className="gap-1.5">
          <CheckCircle2 className="w-3.5 h-3.5" />
          <span>Completed</span>
          {completedVisits.length > 0 && (
            <span className="ml-1.5 bg-green-600 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center font-medium">
              {completedVisits.length}
            </span>
          )}
        </TabsTrigger>
      </TabsList>

      <TabsContent value="scheduled">
        {scheduledVisits.length === 0 ? (
          <Card className="border-dashed">
            <CardContent className="p-12 text-center">
              <Clock className="w-12 h-12 text-muted-foreground mx-auto mb-3 opacity-50" />
              <p className="text-muted-foreground">No scheduled visits yet</p>
              <p className="text-sm text-muted-foreground mt-1">
                Use the Smart Plan tab to schedule your first visit
              </p>
            </CardContent>
          </Card>
        ) : (
          <div className="grid gap-4">
            {scheduledVisits.map((obs) => (
              <ScheduledVisitCard key={obs.id} obs={obs} />
            ))}
          </div>
        )}
      </TabsContent>

      <TabsContent value="completed">
        {completedVisits.length === 0 ? (
          <Card className="border-dashed">
            <CardContent className="p-12 text-center">
              <CheckCircle2 className="w-12 h-12 text-muted-foreground mx-auto mb-3 opacity-50" />
              <p className="text-muted-foreground">No completed visits yet</p>
              <p className="text-sm text-muted-foreground mt-1">
                Complete and submit your first visit to see it here
              </p>
            </CardContent>
          </Card>
        ) : (
          <div className="grid gap-4">
            {completedVisits.map((obs) => (
              <CompletedVisitCard key={obs.id} obs={obs} />
            ))}
          </div>
        )}
      </TabsContent>
    </Tabs>
  );
}
