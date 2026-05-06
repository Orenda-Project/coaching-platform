import { useState } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Textarea } from '@/components/ui/textarea';
import { ArrowLeft, Loader2 } from 'lucide-react';
import { toast } from 'sonner';
import { NeoAnalysis } from './NeoAnalysis';
import type { CotObservation } from '@/types/observation';

interface Props {
  observation: CotObservation;
  onSaved: (obs: CotObservation) => void;
  onSaveToDraft: () => void;
  onClose: () => void;
}

export function QuickObservationPanel({
  observation: initialObs,
  onSaved,
  onSaveToDraft,
  onClose,
}: Props) {
  const [current, setCurrent] = useState(initialObs);
  const [saving, setSaving] = useState(false);
  const [visitNotes, setVisitNotes] = useState('');

  const handleUpdate = (updated: CotObservation) => {
    setCurrent(updated);
    onSaved(updated);
  };

  const saveToDraft = async () => {
    setSaving(true);
    try {
      const { error } = await (supabase as any)
        .from('cot_observations')
        .update({
          status: 'Draft',
          ...(visitNotes ? { notes_for_teacher: visitNotes } : {}),
          updated_at: new Date().toISOString(),
        })
        .eq('id', current.id);

      if (error) {
        toast.error('Failed to save to draft');
        setSaving(false);
        return;
      }

      toast.success('Saved to draft');
      setSaving(false);
      onSaveToDraft();
    } catch {
      toast.error('Failed to save');
      setSaving(false);
    }
  };

  const markVisitComplete = async () => {
    setSaving(true);
    try {
      const { error } = await (supabase as any)
        .from('cot_observations')
        .update({
          status: 'Submitted',
          submitted_at: new Date().toISOString(),
          ...(visitNotes ? { notes_for_teacher: visitNotes } : {}),
          updated_at: new Date().toISOString(),
        })
        .eq('id', current.id);

      if (error) {
        toast.error('Failed to complete visit');
        setSaving(false);
        return;
      }

      toast.success('Visit marked complete!');
      setSaving(false);
      onSaveToDraft();
    } catch {
      toast.error('Failed to complete visit');
      setSaving(false);
    }
  };

  const isFico = current.framework === 'FICO';

  return (
    <div className="fixed inset-0 z-50 bg-background overflow-y-auto">
      {/* Header */}
      <div className="sticky top-0 z-10 border-b border-border bg-background/95 backdrop-blur">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <Button size="icon" variant="ghost" onClick={onClose} className="shrink-0">
              <ArrowLeft className="w-4 h-4" />
            </Button>
            <div className="min-w-0">
              <h2 className="text-lg font-semibold text-foreground truncate">
                {current.teacher_name}
              </h2>
              <p className="text-sm text-muted-foreground truncate">
                {current.school_name} · {current.subject} · {current.grade}
              </p>
            </div>
          </div>
          <Badge variant="outline" className="shrink-0">
            {isFico ? 'FICO' : 'HOTS'}
          </Badge>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-4xl mx-auto px-4 py-8 space-y-6">
        {/* Visit notes */}
        <div className="space-y-2">
          <label className="text-sm font-medium text-foreground">Visit Notes (optional)</label>
          <Textarea
            placeholder="Notes for teacher, observations from the visit..."
            value={visitNotes}
            onChange={(e) => setVisitNotes(e.target.value)}
            className="min-h-[80px]"
          />
        </div>

        {/* Neo debrief */}
        <div>
          <h3 className="font-semibold text-foreground mb-4">Debrief Conversation</h3>
          <NeoAnalysis observation={current} onSaved={handleUpdate} />
        </div>

        {/* Neo status summary */}
        {current.neo_status && (
          <div className="rounded-lg border border-border p-4 bg-muted/30">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-foreground">Debrief Analysis</p>
                {current.neo_status === 'processing' && (
                  <p className="text-xs text-blue-600">Processing debrief...</p>
                )}
                {current.neo_status === 'completed' && (
                  <p className="text-xs text-green-600">Debrief analysed</p>
                )}
                {current.neo_status === 'failed' && (
                  <p className="text-xs text-red-600">Analysis failed</p>
                )}
              </div>
              {current.neo_status === 'completed' && (
                <Badge className="text-xs text-green-700 bg-green-50 border-green-200">
                  Done
                </Badge>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Footer */}
      <div className="sticky bottom-0 z-10 border-t border-border bg-background/95 backdrop-blur">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center justify-between gap-2">
          <Button
            variant="ghost"
            onClick={saveToDraft}
            disabled={saving}
            className="text-muted-foreground hover:text-foreground"
          >
            {saving && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
            Close — save to draft
          </Button>
          <Button
            onClick={markVisitComplete}
            disabled={saving || current.neo_status !== 'completed'}
            className="gap-2"
          >
            {saving && <Loader2 className="w-4 h-4 animate-spin" />}
            Mark Visit Complete
          </Button>
        </div>
      </div>
    </div>
  );
}
