import { useState } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { ArrowLeft, Loader2 } from 'lucide-react';
import { toast } from 'sonner';
import { DCAnalysis } from './DCAnalysis';
import { NeoAnalysis } from './NeoAnalysis';
import { getFicoProficiency } from '@/lib/fico-utils';
import { getProficiencyLevel } from '@/lib/observation-utils';
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
    } catch (err) {
      toast.error('Failed to save');
      setSaving(false);
    }
  };

  const submitObservation = async () => {
    setSaving(true);
    try {
      const { error } = await (supabase as any)
        .from('cot_observations')
        .update({
          status: 'Submitted',
          submitted_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq('id', current.id);

      if (error) {
        toast.error('Failed to submit observation');
        setSaving(false);
        return;
      }

      toast.success('Observation submitted!');
      setSaving(false);
      onSaveToDraft(); // Closes panel and refreshes
    } catch (err) {
      toast.error('Failed to submit');
      setSaving(false);
    }
  };

  const isFico = current.framework === 'FICO';
  const proficiency = isFico
    ? current.total_score > 0
      ? getFicoProficiency(current.total_score)
      : null
    : current.total_score > 0
      ? getProficiencyLevel(current.total_score)
      : null;

  return (
    <div className="fixed inset-0 z-50 bg-background overflow-y-auto">
      {/* Header */}
      <div className="sticky top-0 z-10 border-b border-border bg-background/95 backdrop-blur">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <Button
              size="icon"
              variant="ghost"
              onClick={onClose}
              className="shrink-0"
            >
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
      <div className="max-w-4xl mx-auto px-4 py-8">
        <div className="space-y-6">
          <div>
            <h3 className="font-semibold text-foreground mb-4">
              {current.dc_status === 'completed' ? 'Debrief Conversation' : 'Record Classroom Session'}
            </h3>
            {current.dc_status !== 'completed' ? (
              <DCAnalysis observation={current} onSaved={handleUpdate} />
            ) : (
              <NeoAnalysis observation={current} onSaved={handleUpdate} />
            )}
          </div>

          {/* DC Score display */}
          {current.dc_status === 'completed' && proficiency && (
            <div className="rounded-lg border border-border p-4 bg-muted/30">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-foreground">DC Score</p>
                  <p className="text-xs text-muted-foreground">
                    {isFico ? 'FICO auto-scored' : 'HOTS auto-scored'}
                  </p>
                </div>
                <div className="text-right">
                  <div className={`text-2xl font-bold ${proficiency.color}`}>
                    {current.total_score}/{isFico ? '100' : '80'}
                  </div>
                  <div className={`text-xs font-medium ${proficiency.color}`}>
                    {proficiency.level}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Neo Status */}
          {current.dc_status === 'completed' && (
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
                  {current.neo_status === null && (
                    <p className="text-xs text-muted-foreground">Ready to record</p>
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
      </div>

      {/* Footer */}
      <div className="sticky bottom-0 z-10 border-t border-border bg-background/95 backdrop-blur">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center justify-between gap-2">
          <Button
            variant="ghost"
            onClick={onClose}
            disabled={saving}
            className="text-muted-foreground hover:text-foreground"
          >
            Close — save to draft
          </Button>
          <div className="flex gap-2">
            {current.neo_status !== 'completed' && (
              <Button
                variant="outline"
                onClick={saveToDraft}
                disabled={saving || current.dc_status !== 'completed'}
                className="gap-2"
              >
                {saving && <Loader2 className="w-4 h-4 animate-spin" />}
                Save to Draft
              </Button>
            )}
            <Button
              onClick={submitObservation}
              disabled={saving || current.neo_status !== 'completed'}
              className="gap-2"
            >
              {saving && <Loader2 className="w-4 h-4 animate-spin" />}
              Submit Observation
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
