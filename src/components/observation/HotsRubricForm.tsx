import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { Button } from '@/components/ui/button';
import { Slider } from '@/components/ui/slider';
import { toast } from 'sonner';
import {
  HOTS_DIMENSIONS,
  DEFAULT_HOTS_SCORES,
  calculateTotalScore,
  getProficiencyLevel,
} from '@/lib/observation-utils';
import type { CotObservation, HotsScores } from '@/types/observation';
import { Save, TrendingUp } from 'lucide-react';

interface Props {
  observation: CotObservation;
  onSaved: (updated: CotObservation) => void;
}

export function HotsRubricForm({ observation, onSaved }: Props) {
  const existingScores =
    observation.hots_rubric && Object.keys(observation.hots_rubric).length > 0
      ? (observation.hots_rubric as HotsScores)
      : { ...DEFAULT_HOTS_SCORES };

  const [scores, setScores] = useState<HotsScores>(existingScores);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const s =
      observation.hots_rubric && Object.keys(observation.hots_rubric).length > 0
        ? (observation.hots_rubric as HotsScores)
        : { ...DEFAULT_HOTS_SCORES };
    setScores(s);
  }, [observation.id]);

  const total = calculateTotalScore(scores);
  const proficiency = getProficiencyLevel(total);

  const handleSave = async () => {
    setSaving(true);
    const { data, error } = await (supabase as any)
      .from('cot_observations')
      .update({
        hots_rubric: scores,
        total_score: total,
        proficiency_level: proficiency.level,
        updated_at: new Date().toISOString(),
      })
      .eq('id', observation.id)
      .select()
      .single();

    setSaving(false);

    if (error) {
      toast.error('Failed to save scores');
      return;
    }

    toast.success('HOTs scores saved!');
    onSaved(data as CotObservation);
  };

  return (
    <div className="space-y-5">
      {/* Score Summary Banner */}
      <div className={`rounded-lg border p-4 ${proficiency.bgColor} ${proficiency.borderColor}`}>
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2">
            <TrendingUp className={`w-4 h-4 ${proficiency.color}`} />
            <span className="text-sm font-semibold text-foreground">Total Score</span>
          </div>
          <div className="text-right">
            <span className={`text-2xl font-bold ${proficiency.color}`}>{total}</span>
            <span className="text-muted-foreground text-sm">/80</span>
            <div className={`text-xs font-medium ${proficiency.color}`}>
              {proficiency.level} · {proficiency.percentage}%
            </div>
          </div>
        </div>
        <div className="h-1.5 bg-white/60 rounded-full overflow-hidden">
          <div
            className={`h-full rounded-full transition-all duration-300 ${proficiency.barColor}`}
            style={{ width: `${(total / 80) * 100}%` }}
          />
        </div>
        <div className="flex justify-between text-xs text-muted-foreground mt-1">
          <span>0 — Below Basic</span>
          <span>40 — Basic</span>
          <span>60 — Proficient</span>
          <span>80 — Advanced</span>
        </div>
      </div>

      {/* Dimension Sliders */}
      <div className="space-y-5">
        {HOTS_DIMENSIONS.map(dim => {
          const value = scores[dim.key];
          const pct = (value / dim.max) * 100;
          const scoreColor =
            pct >= 70 ? 'text-green-600' : pct >= 50 ? 'text-yellow-600' : 'text-red-500';

          return (
            <div key={dim.key} className="space-y-2">
              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <p className="text-sm font-medium text-foreground">{dim.label}</p>
                  <p className="text-xs text-muted-foreground">{dim.description}</p>
                </div>
                <div className="shrink-0 text-right">
                  <span className={`text-lg font-bold ${scoreColor}`}>{value}</span>
                  <span className="text-xs text-muted-foreground">/{dim.max}</span>
                </div>
              </div>
              <Slider
                min={0}
                max={dim.max}
                step={1}
                value={[value]}
                onValueChange={([v]) =>
                  setScores(prev => ({ ...prev, [dim.key]: v }))
                }
              />
            </div>
          );
        })}
      </div>

      <Button onClick={handleSave} disabled={saving} className="w-full">
        <Save className="w-4 h-4 mr-2" />
        {saving ? 'Saving...' : 'Save HOTs Scores'}
      </Button>
    </div>
  );
}
