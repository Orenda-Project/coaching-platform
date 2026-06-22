import { useState, useMemo, useEffect } from 'react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { Clock, CheckCircle2, Trash2, Mic, Check, FileText, ChevronDown, MessageSquare, AlertTriangle, MoreVertical } from 'lucide-react';
import { TeacherAbsentModal } from './TeacherAbsentModal';
import type { CotObservation } from '@/types/observation';
import { deleteObservation, updateObservationStatus } from '@/data/observations';
import { getSavedAudio } from '@/lib/audioQueue';
import { toast } from 'sonner';

function DraftAudioBadge({ obsId }: { obsId: string }) {
  const [hasAudio, setHasAudio] = useState(false);
  useEffect(() => {
    getSavedAudio(obsId).then(r => setHasAudio(!!r));
  }, [obsId]);
  if (!hasAudio) return null;
  return (
    <span className="inline-flex items-center gap-1 text-xs text-blue-700 bg-blue-50 border border-blue-200 px-2 py-0.5 rounded">
      <Mic className="w-3 h-3" /> Audio saved
    </span>
  );
}

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
  const [deleteConfirmId, setDeleteConfirmId] = useState<string | null>(null);

  const scheduledVisits = observations.filter(
    (o) => o.status === 'Scheduled'
  );

  const draftVisits = observations.filter(
    (o) => o.status === 'Draft'
  );

  const completedVisits = observations.filter(
    (o) => o.status === 'Submitted' || o.status === 'Approved'
  );

  const lastVisitedByTeacher = useMemo(() => {
    const map = new Map<string, string>();
    completedVisits.forEach((obs) => {
      if (!obs.submitted_at) return;
      const date = new Date(obs.submitted_at).toLocaleDateString('en-GB', { day: 'numeric', month: 'short' });
      const existing = map.get(obs.teacher_name);
      if (!existing || new Date(obs.submitted_at) > new Date(existing)) {
        map.set(obs.teacher_name, date);
      }
    });
    return map;
  }, [completedVisits]);

  const handleDelete = async (id: string) => {
    setDeleting(id);
    try {
      await deleteObservation(id);
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
      await updateObservationStatus(id, 'Draft');
      toast.success('Visit saved to draft');
      setTimeout(() => onRefresh(), 800);
    } catch (err) {
      console.error('Failed to save draft:', err);
      toast.error('Failed to save draft');
    }
  };

  const handleMarkComplete = async (id: string) => {
    try {
      await updateObservationStatus(id, 'Submitted');
      toast.success('Visit marked complete');
      setTimeout(() => onRefresh(), 800);
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
    const isDraft = obs.status === 'Draft';
    const lastVisited = lastVisitedByTeacher.get(obs.teacher_name);

    return (
    <Card className={`hover:shadow-lg transition-all duration-200 ${isDraft ? 'border-2 border-dashed border-amber-300 bg-amber-50/30' : ''}`}>
      <CardContent className="p-5">
        <div className="space-y-3">
          <div className="flex items-start justify-between">
            <div className="flex-1 min-w-0">
              <h3 className="text-lg font-bold text-foreground truncate">{obs.teacher_name}</h3>
              <p className="text-sm text-muted-foreground truncate">{obs.school_name}</p>
            </div>
            {isDraft && (
              <div className="flex flex-col items-end gap-1">
                <span className="inline-block bg-amber-100 border border-amber-300 text-amber-800 text-xs px-2 py-1 rounded font-medium">
                  Draft
                </span>
                <DraftAudioBadge obsId={obs.id} />
              </div>
            )}
          </div>

          <div className="grid grid-cols-2 gap-3 text-sm">
            <div>
              <p className="text-xs font-medium text-muted-foreground">Visit Type</p>
              <p className="text-foreground">{obs.visit_type || obs.framework || '—'}</p>
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
            {lastVisited && (
              <div>
                <p className="text-xs font-medium text-muted-foreground">Last Visited</p>
                <p className="text-foreground">{lastVisited}</p>
              </div>
            )}
          </div>

          <div className="flex items-center justify-between pt-2">
            <div />
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  size="sm"
                  variant="ghost"
                  className="h-8 w-8 p-0"
                >
                  <MoreVertical className="w-4 h-4" />
                </Button>
              </PopoverTrigger>
              <PopoverContent align="end" className="w-48 p-2">
                <div className="space-y-1">
                  <button
                    onClick={() => setAbsentObsId(obs.id)}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-accent rounded-md flex items-center gap-2"
                    title="Teacher absent or unavailable"
                  >
                    <AlertTriangle className="w-4 h-4" />
                    <span>Absent</span>
                  </button>
                  <button
                    onClick={() => {
                      const date = new Date(obs.date).toLocaleDateString('en-US', { day: 'numeric', month: 'short' });
                      const time = obs.arrival_time?.slice(0, 5) || '—';
                      const message = `Assalam o Alaikum ${obs.teacher_name}! Aap ko batana tha ke main ${date} ko ${time} baje ${obs.school_name} mein aap ki class visit ke liye aaon ga/gi. Visit type: ${obs.visit_type || 'FICO'}. Shukria! 🙏`;
                      const encodedMsg = encodeURIComponent(message);
                      window.open(`https://wa.me/?text=${encodedMsg}`, '_blank');
                    }}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-accent rounded-md flex items-center gap-2"
                    title="Notify teacher on WhatsApp"
                  >
                    <MessageSquare className="w-4 h-4" />
                    <span>WhatsApp</span>
                  </button>
                  <button
                    onClick={() => onStartDebrief(obs)}
                    disabled={obs.status === 'Draft' && obs.neo_status === 'processing'}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-accent rounded-md flex items-center gap-2 disabled:opacity-50"
                    title="Give Neo Feedback"
                  >
                    <Mic className="w-4 h-4" />
                    <span>Feedback</span>
                  </button>
                  <button
                    onClick={() => handleSaveDraft(obs.id)}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-accent rounded-md flex items-center gap-2"
                    title="Save as draft"
                  >
                    <FileText className="w-4 h-4" />
                    <span>Draft</span>
                  </button>
                  <button
                    onClick={() => handleMarkComplete(obs.id)}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-accent rounded-md flex items-center gap-2"
                    title="Mark as complete"
                  >
                    <Check className="w-4 h-4" />
                    <span>Complete</span>
                  </button>
                  <button
                    onClick={() => setDeleteConfirmId(obs.id)}
                    disabled={deleting === obs.id}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-accent rounded-md flex items-center gap-2 text-red-600 hover:bg-red-50 disabled:opacity-50"
                    title="Delete visit"
                  >
                    <Trash2 className="w-4 h-4" />
                    <span>Delete</span>
                  </button>
                </div>
              </PopoverContent>
            </Popover>
          </div>

        </div>
      </CardContent>
    </Card>
    );
  };

  const CompletedVisitCard = ({ obs }: { obs: CotObservation }) => {
    const history = lastVisitedByTeacher.get(obs.teacher_name);
    const [expanded, setExpanded] = useState(false);

    const score = obs.neo_results?.overall_score ?? obs.total_score ?? null;
    const scoreBand = score === null ? null : score >= 2.8 ? 'green' : score >= 2.0 ? 'yellow' : 'red';
    const scoreLabel = scoreBand === 'green' ? 'On track' : scoreBand === 'yellow' ? 'Needs support' : 'Urgent support needed';
    const scoreLabelColor = scoreBand === 'green' ? 'text-green-700 bg-green-50 border-green-200' : scoreBand === 'yellow' ? 'text-amber-700 bg-amber-50 border-amber-200' : 'text-red-700 bg-red-50 border-red-200';

    return (
    <Card className="hover:shadow-lg transition-all duration-200">
      <CardContent className="p-5">
        <div className="space-y-3">
          {/* Context first: who, what, when */}
          <div className="flex items-start justify-between gap-2">
            <div className="flex-1 min-w-0">
              <h3 className="text-lg font-bold text-foreground truncate">{obs.teacher_name}</h3>
              <p className="text-sm text-muted-foreground truncate">{obs.school_name}</p>
            </div>
            <div className="flex items-center gap-1 text-green-600 shrink-0">
              <CheckCircle2 className="w-4 h-4" />
              <span className="text-sm font-medium">Visited</span>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3 text-sm">
            <div>
              <p className="text-xs font-medium text-muted-foreground">Visit Type</p>
              <p className="text-foreground">{obs.visit_type || obs.framework || '—'}</p>
            </div>
            <div>
              <p className="text-xs font-medium text-muted-foreground">Date</p>
              <p className="text-foreground">{formatDate(obs.date)}</p>
            </div>
            {obs.notes_for_teacher && (
              <div className="col-span-2">
                <p className="text-xs font-medium text-muted-foreground">What was coached</p>
                <p className="text-foreground text-xs">{obs.notes_for_teacher}</p>
              </div>
            )}
          </div>

          {/* Score revealed after context, with reframed label */}
          {score !== null && (
            <div className={`border rounded-lg p-3 ${scoreLabelColor}`}>
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium">{scoreLabel}</span>
                <span className="text-lg font-bold">{score.toFixed(1)}<span className="text-xs font-normal">/4.0</span></span>
              </div>
              {obs.neo_results?.grade && (
                <p className="text-xs mt-1">Grade: {obs.neo_results.grade}</p>
              )}
            </div>
          )}


          <Button
            variant="ghost"
            size="sm"
            onClick={() => setExpanded(!expanded)}
            className="w-full justify-between text-xs"
          >
            <span>{expanded ? 'Hide' : 'View'} Full Details</span>
            <ChevronDown className={`w-3.5 h-3.5 transition-transform ${expanded ? 'rotate-180' : ''}`} />
          </Button>

          {expanded && (
            <div className="border-t pt-3 space-y-3 text-sm">
              {obs.neo_results?.section_scores && (
                <div>
                  <p className="font-medium text-foreground mb-1">NEO Section Scores</p>
                  <div className="grid grid-cols-2 gap-2">
                    {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
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
          onConfirm={() => { setAbsentObsId(null); onRefresh(); }}
          onClose={() => setAbsentObsId(null)}
          onNavigateToScheduler={() => onNavigateToScheduler?.()}
        />
      )}

      {deleteConfirmId && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-card rounded-lg p-6 w-full max-w-sm shadow-xl space-y-4">
            <h3 className="font-semibold text-foreground">Delete this visit?</h3>
            <p className="text-sm text-muted-foreground">This action cannot be undone.</p>
            <div className="flex gap-3">
              <button
                onClick={() => setDeleteConfirmId(null)}
                className="flex-1 px-4 py-2 border border-input rounded-md text-sm font-medium hover:bg-muted transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={() => { handleDelete(deleteConfirmId); setDeleteConfirmId(null); }}
                className="flex-1 px-4 py-2 bg-red-600 text-white rounded-md text-sm font-medium hover:bg-red-700 transition-colors"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </Tabs>
  );
}
