/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { AlertCircle } from 'lucide-react';
import { toast } from 'sonner';

export default function ReportIssueButton() {
  const { user, profile } = useAuth();
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [subRegion, setSubRegion] = useState<string>('Unknown');
  const [formData, setFormData] = useState({
    issue_type: 'app_bug',
    description: '',
  });

  useEffect(() => {
    const fetchSubRegion = async () => {
      if (!user) return;
      const { data } = await (supabase as any)
        .from('coach_assignments')
        .select('sub_region')
        .eq('coach_id', user.id)
        .single();
      if (data) {
        setSubRegion(data.sub_region);
      }
    };
    fetchSubRegion();
  }, [user]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user || !formData.description.trim()) {
      toast.error('Please describe the issue');
      return;
    }

    setLoading(true);
    try {
      const { error } = await (supabase as any)
        .from('field_issues')
        .insert({
          coach_id: user.id,
          coach_name: profile?.full_name || user.email || 'Coach',
          sub_region: subRegion,
          issue_type: formData.issue_type,
          description: formData.description.trim(),
          status: 'open',
        });

      if (error) {
        toast.error('Failed to report issue');
        console.error(error);
        return;
      }

      toast.success('Issue reported! Team has been notified.');
      setFormData({ issue_type: 'app_bug', description: '' });
      setOpen(false);
    } catch (err) {
      toast.error('Error reporting issue');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  if (!user) return null;

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button
          variant="outline"
          size="sm"
          className="fixed bottom-6 right-6 gap-2 z-40 shadow-lg"
        >
          <AlertCircle className="w-4 h-4" />
          Report Issue
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Report Field Issue</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Issue Type</label>
            <select
              value={formData.issue_type}
              onChange={(e) => setFormData({ ...formData, issue_type: e.target.value })}
              className="w-full px-3 py-2 border rounded-md bg-background text-foreground"
            >
              <option value="app_bug">App Bug</option>
              <option value="data_issue">Data Issue</option>
              <option value="connectivity">Connectivity Problem</option>
              <option value="other">Other</option>
            </select>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium">Description</label>
            <textarea
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              placeholder="Describe the issue you're experiencing..."
              className="w-full px-3 py-2 border rounded-md bg-background text-foreground resize-none h-32"
            />
          </div>

          <div className="flex gap-2 justify-end">
            <Button type="button" variant="outline" onClick={() => setOpen(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? 'Submitting...' : 'Submit Issue'}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
