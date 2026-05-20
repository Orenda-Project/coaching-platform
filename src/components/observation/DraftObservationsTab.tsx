/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  User,
  MapPin,
  BookOpen,
  Calendar,
  ChevronRight,
  ChevronDown,
  Send,
  PenSquare,
  Trash2,
} from 'lucide-react';
import { toast } from 'sonner';
import { NeoAnalysis } from './NeoAnalysis';
import type { CotObservation } from '@/types/observation';
import { getSavedAudio, deleteSavedAudio } from '@/lib/audioQueue';
import { updateObservationStatus } from '@/data/observations';

interface Props {
  observations: CotObservation[];
  onRefresh: () => void;
}

export function DraftObservationsTab({ observations, onRefresh }: Props) {
  const [expanded, setExpanded] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState<string | null>(null);
  const [localOverrides, setLocalOverrides] = useState<Record<string, CotObservation>>({});
  const [confirmDeleteId, setConfirmDeleteId] = useState<string | null>(null);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const handleDelete = async (id: string) => {
    setDeletingId(id);
    const { error } = await (supabase as any)
      .from('cot_observations')
      .delete()
      .eq('id', id);
    setDeletingId(null);
    setConfirmDeleteId(null);
    if (error) {
      toast.error('Failed to delete observation');
      return;
    }
    toast.success('Observation deleted');
    setExpanded(null);
    onRefresh();
  };

  const drafts = observations.filter(o => o.status === 'Draft' || o.status === 'Scheduled');
  const resolve = (obs: CotObservation) => localOverrides[obs.id] ?? obs;

  const handleObsUpdate = (updated: CotObservation) => {
    setLocalOverrides(prev => ({ ...prev, [updated.id]: updated }));
  };

  const handleSubmit = async (obs: CotObservation) => {
    setSubmitting(obs.id);

    try {
      // Check for saved audio and upload to Neo if found
      const savedAudio = await getSavedAudio(obs.id);
      if (savedAudio) {
        const token = (await supabase.auth.getSession()).data.session?.access_token;
        if (token) {
          const formData = new FormData();
          formData.append('file', savedAudio.blob);
          formData.append('observation_id', obs.id);

          const response = await fetch(
            `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/neo-start`,
            {
              method: 'POST',
              headers: { Authorization: `Bearer ${token}` },
              body: formData,
            }
          );

          if (response.ok) {
            await deleteSavedAudio(obs.id);
            toast.success('Audio uploaded to Neo for analysis');
          } else {
            toast.error('Failed to upload audio to Neo');
            setSubmitting(null);
            return;
          }
        }
      }

      // Update observation status
      await updateObservationStatus(obs.id, 'Submitted');

      setSubmitting(null);

      toast.success('Observation submitted successfully!');
      setExpanded(null);
      onRefresh();
    } catch (err) {
      setSubmitting(null);
      toast.error('Error submitting observation');
    }
  };

  if (drafts.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <PenSquare className="w-10 h-10 text-muted-foreground mb-3" />
        <h3 className="font-semibold text-foreground mb-1">No draft observations</h3>
        <p className="text-sm text-muted-foreground">
          Start an observation from the &ldquo;Smart Plan&rdquo; tab to see it here
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      <div>
        <h2 className="font-display text-lg font-semibold text-foreground">Draft Observations</h2>
        <p className="text-sm text-muted-foreground">
          {drafts.length} observation{drafts.length !== 1 ? 's' : ''} in progress
        </p>
      </div>

      {drafts.map(obs => {
        const current = resolve(obs);
        const isExpanded = expanded === obs.id;
        const isFico = current.framework === 'FICO';

        return (
          <Card key={obs.id} className="glass-card overflow-hidden">
            <button
              className="w-full text-left focus:outline-none"
              onClick={() => setExpanded(isExpanded ? null : obs.id)}
            >
              <CardContent className="p-4">
                <div className="flex items-start justify-between gap-3">
                  <div className="flex-1 space-y-2">
                    <div className="flex items-center gap-2 flex-wrap">
                      <Badge
                        variant="outline"
                        className="text-orange-600 border-orange-200 bg-orange-50 text-xs"
                      >
                        Draft
                      </Badge>
                      <Badge variant="outline" className="text-xs">
                        {isFico ? 'FICO' : 'HOTS'}
                      </Badge>
                      {current.neo_status === 'completed' && (
                        <Badge
                          variant="outline"
                          className="text-xs text-green-700 border-green-200 bg-green-50"
                        >
                          Debrief Done
                        </Badge>
                      )}
                      {current.neo_status === 'processing' && (
                        <Badge
                          variant="outline"
                          className="text-xs text-blue-700 border-blue-200 bg-blue-50"
                        >
                          Debrief Processing…
                        </Badge>
                      )}
                    </div>

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
                      <div className="flex items-center gap-1.5 text-muted-foreground">
                        <Calendar className="w-3.5 h-3.5 shrink-0" />
                        <span>
                          {new Date(obs.date).toLocaleDateString('en-US', {
                            month: 'short',
                            day: 'numeric',
                          })}
                        </span>
                      </div>
                    </div>
                  </div>

                  {isExpanded ? (
                    <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0 mt-1" />
                  ) : (
                    <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0 mt-1" />
                  )}
                </div>
              </CardContent>
            </button>

            {isExpanded && (
              <div className="border-t border-border px-4 pb-5">
                <div className="mt-4">
                  <NeoAnalysis observation={current} onSaved={handleObsUpdate} />
                </div>

                <div className="mt-5 pt-4 border-t border-border space-y-2">
                  <Button
                    onClick={() => handleSubmit(current)}
                    disabled={submitting === obs.id || current.neo_status !== 'completed'}
                    className="w-full"
                  >
                    <Send className="w-4 h-4 mr-2" />
                    {submitting === obs.id ? 'Submitting...' : 'Mark Visit Complete'}
                  </Button>
                  {current.neo_status !== 'completed' && (
                    <p className="text-xs text-muted-foreground text-center">
                      Record debrief conversation to complete the visit
                    </p>
                  )}

                  {confirmDeleteId === obs.id ? (
                    <div className="flex items-center justify-center gap-2 pt-1">
                      <span className="text-xs text-muted-foreground">Delete this observation?</span>
                      <Button
                        size="sm"
                        variant="destructive"
                        className="h-7 px-3 text-xs"
                        onClick={() => handleDelete(obs.id)}
                        disabled={deletingId === obs.id}
                      >
                        {deletingId === obs.id ? '…' : 'Yes, delete'}
                      </Button>
                      <Button
                        size="sm"
                        variant="ghost"
                        className="h-7 px-3 text-xs"
                        onClick={() => setConfirmDeleteId(null)}
                      >
                        Cancel
                      </Button>
                    </div>
                  ) : (
                    <Button
                      variant="ghost"
                      className="w-full text-xs text-muted-foreground hover:text-destructive"
                      onClick={() => setConfirmDeleteId(obs.id)}
                    >
                      <Trash2 className="w-3.5 h-3.5 mr-1.5" /> Delete Observation
                    </Button>
                  )}
                </div>
              </div>
            )}
          </Card>
        );
      })}
    </div>
  );
}
