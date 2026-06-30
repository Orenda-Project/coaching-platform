import { useState, useMemo, useEffect } from 'react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Clock, CheckCircle2, Trash2, Mic, Check, FileText, ChevronDown } from 'lucide-react';

function WhatsAppIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor" className={className}>
      <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
    </svg>
  );
}
import { TeacherAbsentModal } from './TeacherAbsentModal';
import type { CotObservation, NeoObserverFeedback, NeoResults } from '@/types/observation';
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

  const NeoFeedbackSection = ({ results }: { results: NeoResults }) => {
    const fb = results.observer_feedback as NeoObserverFeedback | undefined;
    return (
      <div className="space-y-3 pt-1">
        {/* Score + grade */}
        <div className="flex items-center justify-between bg-muted/50 rounded-lg px-3 py-2">
          <div>
            <p className="text-xs text-muted-foreground">Overall Score</p>
            <p className="text-xl font-bold text-foreground">{results.overall_score}</p>
          </div>
          {results.grade && (
            <span className="text-sm font-bold px-3 py-1 rounded-full border bg-background">{results.grade}</span>
          )}
        </div>

        {/* Readiness level */}
        {results.readiness_level && (
          <div className="bg-blue-50 border border-blue-200 rounded p-2">
            <p className="text-xs text-muted-foreground mb-0.5">Readiness Level</p>
            <p className="text-xs font-medium text-blue-900">{results.readiness_level}</p>
          </div>
        )}

        {/* Section scores */}
        {results.section_scores && Object.keys(results.section_scores).length > 0 && (
          <div>
            <p className="text-xs font-semibold text-foreground mb-1">Section Scores</p>
            <div className="grid grid-cols-3 gap-1.5">
              {Object.entries(results.section_scores).map(([k, v]) => (
                <div key={k} className="bg-muted rounded p-1.5 text-center">
                  <p className="text-[10px] text-muted-foreground">{k}</p>
                  <p className="text-sm font-bold">{v as number}</p>
                </div>
              ))}
            </div>
          </div>
        )}

        {fb && (
          <>
            {fb.overall_summary && (
              <div className="bg-muted/40 rounded p-2 text-xs text-foreground leading-relaxed">
                {fb.overall_summary}
              </div>
            )}
            {fb.strengths && fb.strengths.length > 0 && (
              <div className="space-y-1">
                <p className="text-xs font-medium text-green-700">Strengths</p>
                {fb.strengths.map((s, i) => (
                  <div key={i} className="bg-green-50 border border-green-200 rounded p-2 text-xs text-green-900">{s}</div>
                ))}
              </div>
            )}
            {fb.next_steps && fb.next_steps.length > 0 && (
              <div className="space-y-1.5">
                <p className="text-xs font-medium text-blue-700">Next Steps for Growth</p>
                {fb.next_steps.map((step, i) => (
                  <div key={i} className="bg-blue-50 border border-blue-200 rounded p-2 text-xs text-blue-900">
                    <p className="font-medium">{step.growth_area}</p>
                    <p className="mt-0.5">{step.specific_behavior}</p>
                    {step.self_reflection_question && (
                      <p className="mt-1 italic opacity-80">🤔 {step.self_reflection_question}</p>
                    )}
                  </div>
                ))}
              </div>
            )}
            {fb.priority_growth_areas && fb.priority_growth_areas.length > 0 && (
              <div className="space-y-1">
                <p className="text-xs font-medium text-orange-700">Priority Areas</p>
                {fb.priority_growth_areas.map((area, i) => (
                  <div key={i} className="bg-orange-50 border border-orange-200 rounded p-2 text-xs text-orange-900">{area}</div>
                ))}
              </div>
            )}
            {fb.closing_encouragement && (
              <div className="bg-purple-50 border border-purple-200 rounded p-2 text-xs text-purple-900">
                <p className="font-medium mb-1">💪 Forward Momentum</p>
                <p>{fb.closing_encouragement}</p>
              </div>
            )}
          </>
        )}
      </div>
    );
  };

  const ScheduledVisitCard = ({ obs }: { obs: CotObservation }) => {
    const isDraft = obs.status === 'Draft';
    const lastVisited = lastVisitedByTeacher.get(obs.teacher_name);
    const [neoExpanded, setNeoExpanded] = useState(false);

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
                {[obs.subject, obs.grade].filter(Boolean).join(' · ') || '—'}
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

          {/* Action row — labeled icons so first-time coaches know what each button does */}
          <div className="flex items-center justify-between pt-3 border-t border-border">
            {/* WhatsApp — notify teacher */}
            <button
              className="flex flex-col items-center gap-1 px-2 py-1.5 rounded-lg hover:bg-green-50 text-[#25D366] transition-colors"
              onClick={() => {
                const date = new Date(obs.date).toLocaleDateString('en-US', { day: 'numeric', month: 'short' });
                const time = obs.arrival_time?.slice(0, 5) || '—';
                const message = `Assalam o Alaikum ${obs.teacher_name}! Aap ko batana tha ke main ${date} ko ${time} baje ${obs.school_name} mein aap ki class visit ke liye aaon ga/gi. Visit type: ${obs.visit_type || 'FICO'}. Shukria! 🙏`;
                window.open(`https://wa.me/?text=${encodeURIComponent(message)}`, '_blank');
              }}
            >
              <WhatsAppIcon className="w-5 h-5" />
              <span className="text-[10px] text-muted-foreground font-medium">Notify</span>
            </button>

            {/* Debrief — amber = pending, green = done */}
            <button
              className={`flex flex-col items-center gap-1 px-2 py-1.5 rounded-lg transition-colors disabled:opacity-40 ${
                obs.neo_status === 'completed'
                  ? 'text-green-600 hover:bg-green-50'
                  : 'text-amber-600 hover:bg-amber-50'
              }`}
              disabled={obs.neo_status === 'processing'}
              onClick={() => onStartDebrief(obs)}
            >
              <Mic className="w-5 h-5" />
              <span className="text-[10px] font-medium" style={{ color: 'inherit' }}>
                {obs.neo_status === 'completed' ? 'Debriefed' : obs.neo_status === 'processing' ? 'Analyzing…' : 'Debrief'}
              </span>
            </button>

            {/* Mark Done */}
            <button
              className="flex flex-col items-center gap-1 px-2 py-1.5 rounded-lg hover:bg-green-50 text-foreground transition-colors disabled:opacity-30"
              disabled={obs.neo_status === 'processing'}
              onClick={() => handleMarkComplete(obs.id)}
            >
              <Check className="w-5 h-5" />
              <span className="text-[10px] text-muted-foreground font-medium">Done</span>
            </button>

            {/* Draft */}
            <button
              className="flex flex-col items-center gap-1 px-2 py-1.5 rounded-lg hover:bg-muted text-muted-foreground transition-colors"
              onClick={() => handleSaveDraft(obs.id)}
            >
              <FileText className="w-5 h-5" />
              <span className="text-[10px] font-medium">Draft</span>
            </button>

            {/* Delete */}
            <button
              className="flex flex-col items-center gap-1 px-2 py-1.5 rounded-lg hover:bg-red-50 text-muted-foreground hover:text-red-600 transition-colors disabled:opacity-40"
              disabled={deleting === obs.id}
              onClick={() => setDeleteConfirmId(obs.id)}
            >
              <Trash2 className="w-5 h-5" />
              <span className="text-[10px] font-medium">Delete</span>
            </button>
          </div>

          {/* Neo feedback — shown when analysis is complete */}
          {obs.neo_results && (
            <>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setNeoExpanded(!neoExpanded)}
                className="w-full justify-between text-xs border-t pt-2 mt-1"
              >
                <span>{neoExpanded ? 'Hide' : 'View'} Neo Feedback</span>
                <ChevronDown className={`w-3.5 h-3.5 transition-transform ${neoExpanded ? 'rotate-180' : ''}`} />
              </Button>
              {neoExpanded && <NeoFeedbackSection results={obs.neo_results} />}
            </>
          )}

        </div>
      </CardContent>
    </Card>
    );
  };

  const CompletedVisitCard = ({ obs }: { obs: CotObservation }) => {
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
              {obs.neo_results && <NeoFeedbackSection results={obs.neo_results} />}
              {obs.notes_for_teacher && (
                <div>
                  <p className="font-medium text-foreground mb-1">Coach Notes</p>
                  <p className="text-foreground bg-amber-50 border border-amber-200 rounded p-2 text-xs">{obs.notes_for_teacher}</p>
                </div>
              )}
              {obs.hots_notes && (
                <div>
                  <p className="font-medium text-foreground mb-1">HOTS Notes</p>
                  <p className="text-foreground bg-amber-50 border border-amber-200 rounded p-2 text-xs">{obs.hots_notes}</p>
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
