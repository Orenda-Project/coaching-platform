import { useState, useMemo } from 'react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Clock, CheckCircle2, Trash2, Mic, Check, FileText, ChevronDown, MessageSquare, AlertTriangle } from 'lucide-react';
import { TeacherAbsentModal } from './TeacherAbsentModal';
import type { CotObservation } from '@/types/observation';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';

interface VisitsDashboardTabProps {
  observations: CotObservation[];
  onStartDebrief: (observation: CotObservation) => void;
  onRefresh: () => void;
  onNavigateToScheduler?: () => void;
}

export function VisitsDashboardTab({
  observations,
  onStartDebrief,
  onRefresh,
  onNavigateToScheduler,
}: VisitsDashboardTabProps) {
  const [deleting, setDeleting] = useState<string | null>(null);
  const [absentObsId, setAbsentObsId] = useState<string | null>(null);

  const scheduledVisits = observations.filter(
    (o) => o.status === 'Scheduled'
  );

  const draftVisits = observations.filter(
    (o) => o.status === 'Draft'
  );

  const completedVisits = observations.filter(
    (o) => o.status === 'Submitted' || o.status === 'Approved'
  );

  // Compute teacher history for pre-visit brief
  const teacherHistory = useMemo(() => {
    const map = new Map<string, { lastScore: number | null; lastDate: string; weakIndicators: string[]; scoreTrend: string }>();
    const byTeacher = new Map<string, CotObservation[]>();

    completedVisits.forEach((obs) => {
      if (!byTeacher.has(obs.teacher_name)) byTeacher.set(obs.teacher_name, []);
      byTeacher.get(obs.teacher_name)!.push(obs);
    });

    for (const [teacher, obs] of byTeacher.entries()) {
      obs.sort((a, b) => new Date(b.submitted_at || 0).getTime() - new Date(a.submitted_at || 0).getTime());
      const latest = obs[0];
      const prev = obs[1];

      let scoreTrend = '';
      if (latest.total_score && prev?.total_score) {
        if (latest.total_score < prev.total_score - 5) scoreTrend = '↓ Falling';
        else if (latest.total_score > prev.total_score + 5) scoreTrend = '↑ Improving';
      }

      const weak: string[] = [];
      if (latest.dc_results?.section_b) {
        const indicators = latest.dc_results.section_b as Record<string, any>;
        Object.entries(indicators).forEach(([key, val]: [string, any]) => {
          if (val?.score === 'no' || val?.score === 'partial') {
            weak.push(key.replace(/_/g, ' '));
          }
        });
      }

      map.set(teacher, {
        lastScore: latest.total_score ?? null,
        lastDate: latest.submitted_at ? new Date(latest.submitted_at).toLocaleDateString('en-GB', { day: 'numeric', month: 'short' }) : 'unknown',
        weakIndicators: weak.slice(0, 2),
        scoreTrend,
      });
    }

    return map;
  }, [completedVisits]);

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

  const handleSaveDraft = async (id: string) => {
    try {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const typedSupabase = supabase as any;
      const { error } = await typedSupabase
        .from('cot_observations')
        .update({
          status: 'Draft',
          updated_at: new Date().toISOString(),
        })
        .eq('id', id);

      if (error) throw error;

      toast.success('Visit saved to draft');
      onRefresh();
    } catch (err) {
      console.error('Failed to save draft:', err);
      toast.error('Failed to save draft');
    }
  };

  const handleMarkComplete = async (id: string) => {
    try {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const typedSupabase = supabase as any;
      const { error } = await typedSupabase
        .from('cot_observations')
        .update({
          status: 'Submitted',
          updated_at: new Date().toISOString(),
        })
        .eq('id', id);

      if (error) throw error;

      toast.success('Visit marked complete');
      onRefresh();
    } catch (err) {
      console.error('Failed to mark visit complete:', err);
      toast.error('Failed to mark visit complete');
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

  const ScheduledVisitCard = ({ obs }: { obs: CotObservation }) => {
    const [expanded, setExpanded] = useState(false);
    const history = teacherHistory.get(obs.teacher_name);
    const isDraft = obs.status === 'Draft';

    return (
    <Card className={`hover:shadow-md transition-shadow ${isDraft ? 'border-2 border-dashed border-amber-300 bg-amber-50/30' : ''}`}>
      <CardContent className="p-5">
        <div className="space-y-3">
          <div className="flex items-start justify-between">
            <div>
              <h3 className="font-semibold text-foreground">{obs.teacher_name}</h3>
              <p className="text-sm text-muted-foreground">{obs.school_name}</p>
            </div>
            {isDraft && (
              <span className="inline-block bg-amber-100 border border-amber-300 text-amber-800 text-xs px-2 py-1 rounded font-medium">
                Draft
              </span>
            )}
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

          {history && (
            <div className="border-t pt-3 mt-3">
              <button
                onClick={() => setExpanded(!expanded)}
                className="w-full flex items-center justify-between text-sm font-medium text-foreground hover:text-primary transition-colors"
              >
                <span>Pre-Visit Brief</span>
                <ChevronDown className={`w-4 h-4 transition-transform ${expanded ? 'rotate-180' : ''}`} />
              </button>
              {expanded && (
                <div className="mt-3 space-y-2 text-sm">
                  <div className="flex justify-between items-start">
                    <span className="text-muted-foreground">Last Score:</span>
                    <span className="font-medium">{history.lastScore?.toFixed(1) || '—'}</span>
                  </div>
                  {history.lastDate && (
                    <div className="flex justify-between items-start">
                      <span className="text-muted-foreground">Last Visited:</span>
                      <span className="text-foreground">{history.lastDate}</span>
                    </div>
                  )}
                  {history.scoreTrend && (
                    <div className="flex justify-between items-start">
                      <span className="text-muted-foreground">Trend:</span>
                      <span className={history.scoreTrend.includes('↓') ? 'text-red-600 font-medium' : 'text-green-600 font-medium'}>
                        {history.scoreTrend}
                      </span>
                    </div>
                  )}
                  {history.weakIndicators.length > 0 && (
                    <div>
                      <p className="text-muted-foreground mb-1">Focus Areas:</p>
                      <div className="flex flex-wrap gap-1">
                        {history.weakIndicators.map((indicator) => (
                          <span key={indicator} className="inline-block bg-amber-50 border border-amber-200 text-amber-900 text-xs px-2 py-1 rounded">
                            {indicator}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>
          )}

          <div className="flex gap-3 pt-2 justify-end">
            <div className="flex flex-col items-center gap-1">
              <Button
                size="sm"
                variant="ghost"
                onClick={() => setAbsentObsId(obs.id)}
                title="Teacher absent or unavailable"
                className="h-8 w-8 p-0"
              >
                <AlertTriangle className="w-3.5 h-3.5" />
              </Button>
              <span className="text-xs text-muted-foreground">Absent</span>
            </div>
            <div className="flex flex-col items-center gap-1">
              <Button
                size="sm"
                variant="ghost"
                onClick={() => {
                  const date = new Date(obs.date).toLocaleDateString('en-US', { day: 'numeric', month: 'short' });
                  const time = obs.arrival_time?.slice(0, 5) || '—';
                  const message = `Hi ${obs.teacher_name}, I have a scheduled observation visit on ${date} at ${time} for ${obs.visit_type || 'HOTS'} at ${obs.school_name}. See you then! 👋`;
                  const encodedMsg = encodeURIComponent(message);
                  window.open(`https://wa.me/?text=${encodedMsg}`, '_blank');
                }}
                title="Notify teacher on WhatsApp"
                className="h-8 w-8 p-0"
              >
                <MessageSquare className="w-3.5 h-3.5" />
              </Button>
              <span className="text-xs text-muted-foreground">WhatsApp</span>
            </div>
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
                onClick={() => handleSaveDraft(obs.id)}
                title="Save as draft"
                className="h-8 w-8 p-0"
              >
                <FileText className="w-3.5 h-3.5" />
              </Button>
              <span className="text-xs text-muted-foreground">Draft</span>
            </div>
            <div className="flex flex-col items-center gap-1">
              <Button
                size="sm"
                variant="outline"
                onClick={() => handleMarkComplete(obs.id)}
                title="Mark as complete"
                className="h-8 w-8 p-0"
              >
                <Check className="w-3.5 h-3.5" />
              </Button>
              <span className="text-xs text-muted-foreground">Complete</span>
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
  };

  const CompletedVisitCard = ({ obs }: { obs: CotObservation }) => {
    const [expanded, setExpanded] = useState(false);

    return (
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

          <Button
            variant="ghost"
            size="sm"
            onClick={() => setExpanded(!expanded)}
            className="w-full justify-between text-xs"
          >
            <span>{expanded ? 'Hide' : 'View'} Details</span>
            <ChevronDown className={`w-3.5 h-3.5 transition-transform ${expanded ? 'rotate-180' : ''}`} />
          </Button>

          {expanded && (
            <div className="border-t pt-3 space-y-3 text-sm">
              {obs.neo_results?.section_scores && (
                <div>
                  <p className="font-medium text-foreground mb-1">NEO Section Scores</p>
                  <div className="grid grid-cols-2 gap-2">
                    {Object.entries(obs.neo_results.section_scores).map(([section, score]: [string, any]) => (
                      <div key={section} className="bg-muted p-2 rounded">
                        <span className="text-xs text-muted-foreground">{section}</span>
                        <p className="font-semibold">{score}</p>
                      </div>
                    ))}
                  </div>
                </div>
              )}
              {obs.neo_results?.readiness_level && (
                <div className="bg-blue-50 border border-blue-200 rounded p-2">
                  <p className="text-xs text-muted-foreground">Readiness Level</p>
                  <p className="font-semibold text-blue-900">{obs.neo_results.readiness_level}</p>
                </div>
              )}
              {obs.notes_for_teacher && (
                <div>
                  <p className="font-medium text-foreground mb-1">Coach Notes</p>
                  <p className="text-foreground bg-amber-50 border border-amber-200 rounded p-2">{obs.notes_for_teacher}</p>
                </div>
              )}
              {obs.hots_notes && (
                <div>
                  <p className="font-medium text-foreground mb-1">HOTS Notes</p>
                  <p className="text-foreground bg-amber-50 border border-amber-200 rounded p-2">{obs.hots_notes}</p>
                </div>
              )}
            </div>
          )}
        </div>
      </CardContent>
    </Card>
    );
  };

  return (
    <Tabs defaultValue="scheduled" className="w-full">
      <TabsList className="grid w-full grid-cols-3 mb-6">
        <TabsTrigger value="scheduled" className="gap-1.5">
          <span>Scheduled</span>
          {scheduledVisits.length > 0 && (
            <span className="ml-1.5 bg-primary text-primary-foreground text-xs rounded-full w-5 h-5 flex items-center justify-center font-medium">
              {scheduledVisits.length}
            </span>
          )}
        </TabsTrigger>

        <TabsTrigger value="draft" className="gap-1.5">
          <span>Draft</span>
          {draftVisits.length > 0 && (
            <span className="ml-1.5 bg-amber-600 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center font-medium">
              {draftVisits.length}
            </span>
          )}
        </TabsTrigger>

        <TabsTrigger value="completed" className="gap-1.5">
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

      <TabsContent value="draft">
        {draftVisits.length === 0 ? (
          <Card className="border-dashed">
            <CardContent className="p-12 text-center">
              <FileText className="w-12 h-12 text-muted-foreground mx-auto mb-3 opacity-50" />
              <p className="text-muted-foreground">No draft visits yet</p>
              <p className="text-sm text-muted-foreground mt-1">
                Save visits as draft to continue working on them later
              </p>
            </CardContent>
          </Card>
        ) : (
          <div className="grid gap-4">
            {draftVisits.map((obs) => (
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

      {absentObsId && (
        <TeacherAbsentModal
          observation={observations.find(o => o.id === absentObsId)!}
          onConfirm={() => {
            setAbsentObsId(null);
            onRefresh();
          }}
          onClose={() => setAbsentObsId(null)}
          onNavigateToScheduler={() => onNavigateToScheduler?.()}
        />
      )}
    </Tabs>
  );
}
