import { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';
import { SUBJECTS, GRADES } from '@/lib/observation-utils';
import { isRegionFico } from '@/lib/fico-utils';
import type { CotObservation } from '@/types/observation';
import { MapPin } from 'lucide-react';

interface Props {
  open: boolean;
  onClose: () => void;
  onScheduled: (obs: CotObservation) => void;
}

const EMPTY_FORM = {
  school_name: '',
  teacher_name: '',
  subject: '',
  grade: '',
  topic: '',
  date: '',
};

export function ScheduleDialog({ open, onClose, onScheduled }: Props) {
  const { user, profile } = useAuth();
  const [form, setForm] = useState(EMPTY_FORM);
  const [loading, setLoading] = useState(false);

  const region = (profile as any)?.region || '';

  const handleChange = (field: string, value: string) =>
    setForm(prev => ({ ...prev, [field]: value }));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user || !profile) return;
    if (!form.school_name.trim() || !form.teacher_name.trim() || !form.subject || !form.grade || !form.date) {
      toast.error('Please fill in all required fields');
      return;
    }

    const framework = isRegionFico(region) ? 'FICO' : 'HOTS';

    setLoading(true);
    const { data, error } = await (supabase as any)
      .from('cot_observations')
      .insert({
        observer_id: user.id,
        school_name: form.school_name.trim(),
        teacher_name: form.teacher_name.trim(),
        region: region || 'Not specified',
        subject: form.subject,
        grade: form.grade,
        topic: form.topic.trim() || null,
        date: new Date(form.date).toISOString(),
        status: 'Scheduled',
        framework,
        hots_rubric: {},
        fico_rubric: {},
        total_score: 0,
      })
      .select()
      .single();

    setLoading(false);

    if (error) {
      toast.error('Failed to schedule visit: ' + error.message);
      return;
    }

    toast.success('Visit scheduled!');
    onScheduled(data as CotObservation);
    onClose();
    setForm(EMPTY_FORM);
  };

  const selectClass =
    'w-full px-3 py-2 border border-input rounded-md bg-background text-foreground text-sm focus:outline-none focus:ring-2 focus:ring-primary';

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle className="font-display">Schedule New Visit</DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="space-y-4 mt-2">
          <div className="space-y-2">
            <Label htmlFor="sd-school">School Name *</Label>
            <Input
              id="sd-school"
              placeholder="Enter school name"
              value={form.school_name}
              onChange={e => handleChange('school_name', e.target.value)}
              required
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="sd-teacher">Teacher Name *</Label>
            <Input
              id="sd-teacher"
              placeholder="Enter teacher name"
              value={form.teacher_name}
              onChange={e => handleChange('teacher_name', e.target.value)}
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-2">
              <Label htmlFor="sd-subject">Subject *</Label>
              <select
                id="sd-subject"
                value={form.subject}
                onChange={e => handleChange('subject', e.target.value)}
                required
                className={selectClass}
              >
                <option value="">Select...</option>
                {SUBJECTS.map(s => (
                  <option key={s} value={s}>{s}</option>
                ))}
              </select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="sd-grade">Grade *</Label>
              <select
                id="sd-grade"
                value={form.grade}
                onChange={e => handleChange('grade', e.target.value)}
                required
                className={selectClass}
              >
                <option value="">Select...</option>
                {GRADES.map(g => (
                  <option key={g} value={g}>{g}</option>
                ))}
              </select>
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="sd-topic">Lesson Topic <span className="text-muted-foreground font-normal">(optional)</span></Label>
            <Input
              id="sd-topic"
              placeholder="E.g., Fractions, Reading comprehension..."
              value={form.topic}
              onChange={e => handleChange('topic', e.target.value)}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="sd-date">Observation Date & Time *</Label>
            <Input
              id="sd-date"
              type="datetime-local"
              value={form.date}
              onChange={e => handleChange('date', e.target.value)}
              required
            />
          </div>

          {region && (
            <div className="flex items-center gap-2 text-sm bg-muted/40 px-3 py-2 rounded-md">
              <MapPin className="w-3.5 h-3.5 text-muted-foreground shrink-0" />
              <span className="text-muted-foreground">Region:</span>
              <span className="font-medium text-foreground capitalize">{region}</span>
              <span className="ml-auto text-xs font-semibold px-2 py-0.5 rounded-full border bg-background">
                {isRegionFico(region) ? 'FICO Framework' : 'HOTS Framework'}
              </span>
            </div>
          )}

          <DialogFooter>
            <Button type="button" variant="ghost" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? 'Scheduling...' : 'Schedule Visit'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
