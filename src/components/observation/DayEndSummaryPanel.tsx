import { useState } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { X, Copy, Check, TrendingUp, AlertCircle } from 'lucide-react';
import type { CotObservation } from '@/types/observation';
import { toast } from 'sonner';

interface DayEndSummaryPanelProps {
  observations: CotObservation[];
  coachName: string;
  subRegion: string;
  onClose: () => void;
}

export function DayEndSummaryPanel({
  observations,
  coachName,
  subRegion,
  onClose,
}: DayEndSummaryPanelProps) {
  const [copied, setCopied] = useState(false);

  const today = new Date().toISOString().split('T')[0];
  const todayCompletedVisits = observations.filter(
    (obs) => obs.status === 'Submitted' && obs.submitted_at?.startsWith(today)
  );

  const totalScore = todayCompletedVisits.reduce((sum, obs) => sum + (obs.total_score || 0), 0);
  const avgScore = todayCompletedVisits.length > 0 ? (totalScore / todayCompletedVisits.length).toFixed(2) : '—';

  const improvingTeachers = todayCompletedVisits.filter((obs) => {
    const pastObs = observations.find(
      (o) => o.teacher_name === obs.teacher_name && o.id !== obs.id && o.status === 'Submitted'
    );
    return pastObs && obs.total_score && pastObs.total_score && obs.total_score > pastObs.total_score;
  });

  const reportText = `📊 Aaj ki Coaching Report — ${new Date().toLocaleDateString('ur-PK', { weekday: 'long', day: 'numeric', month: 'long' })}

👨‍🏫 Coach: ${coachName}
🏘️ علاقہ: ${subRegion}

✅ Visits mukamal: ${todayCompletedVisits.length}
📈 Ausat score: ${avgScore}/4.0
🚀 Behtar ho rahe hain: ${improvingTeachers.length} teachers

📋 Aaj visit ki gayi teachers:
${todayCompletedVisits.map((obs) => {
  const score = obs.total_score?.toFixed(1) || '—';
  const grade = obs.neo_results?.grade || '—';
  const label = parseFloat(score) >= 2.8 ? 'Theek hai' : parseFloat(score) >= 2.0 ? 'Madad chahiye' : 'Fori madad chahiye';
  return `  • ${obs.teacher_name} (${obs.school_name})\n    Score: ${score}/4.0 — ${label}, Grade: ${grade}`;
}).join('\n')}

${improvingTeachers.length > 0 ? `\n🌟 Taraqqi kar rahe hain:\n${improvingTeachers.map((obs) => `  • ${obs.teacher_name}`).join('\n')}` : ''}

RABT Observation Scheduler ki taraf se`;

  const handleCopy = () => {
    navigator.clipboard.writeText(reportText);
    setCopied(true);
    toast.success('Report copied to clipboard');
    setTimeout(() => setCopied(false), 2000);
  };

  if (todayCompletedVisits.length === 0) {
    return (
      <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
        <Card className="w-full max-w-md">
          <CardContent className="p-6">
            <div className="flex items-start justify-between mb-4">
              <h2 className="text-lg font-semibold text-foreground">Day End Summary</h2>
              <button
                onClick={onClose}
                className="p-1 hover:bg-muted rounded-md transition-colors"
              >
                <X className="w-5 h-5 text-muted-foreground" />
              </button>
            </div>
            <div className="flex flex-col items-center justify-center py-8 text-center">
              <AlertCircle className="w-12 h-12 text-muted-foreground mx-auto mb-3 opacity-50" />
              <p className="text-muted-foreground">No visits completed today</p>
              <p className="text-sm text-muted-foreground mt-1">
                Complete your first visit to see a summary
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 overflow-y-auto">
      <Card className="w-full max-w-2xl my-auto">
        <CardContent className="p-6">
          <div className="flex items-start justify-between mb-6">
            <div>
              <h2 className="text-lg font-semibold text-foreground">Day End Summary</h2>
              <p className="text-sm text-muted-foreground mt-1">
                {new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}
              </p>
            </div>
            <button
              onClick={onClose}
              className="p-1 hover:bg-muted rounded-md transition-colors"
            >
              <X className="w-5 h-5 text-muted-foreground" />
            </button>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-3 gap-3 mb-6">
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
              <p className="text-xs font-medium text-blue-900 mb-1">Visits Completed</p>
              <p className="text-2xl font-bold text-blue-900">{todayCompletedVisits.length}</p>
            </div>
            <div className="bg-purple-50 border border-purple-200 rounded-lg p-3">
              <p className="text-xs font-medium text-purple-900 mb-1">Average Score</p>
              <p className="text-2xl font-bold text-purple-900">{avgScore}</p>
              <p className="text-xs text-purple-800">/4.0</p>
            </div>
            <div className="bg-green-50 border border-green-200 rounded-lg p-3">
              <p className="text-xs font-medium text-green-900 mb-1">Improving</p>
              <div className="flex items-baseline gap-1">
                <p className="text-2xl font-bold text-green-900">{improvingTeachers.length}</p>
                <TrendingUp className="w-4 h-4 text-green-600" />
              </div>
            </div>
          </div>

          {/* Teachers visited */}
          <div className="mb-6">
            <h3 className="font-semibold text-foreground mb-3">Teachers Visited</h3>
            <div className="space-y-2">
              {todayCompletedVisits.map((obs) => (
                <div key={obs.id} className="bg-muted/40 rounded p-3 flex items-between justify-between">
                  <div>
                    <p className="font-medium text-foreground">{obs.teacher_name}</p>
                    <p className="text-xs text-muted-foreground">{obs.school_name}</p>
                  </div>
                  <div className="text-right">
                    <p className="font-semibold text-foreground">{obs.total_score?.toFixed(1) || '—'}</p>
                    <p className="text-xs text-muted-foreground">{obs.neo_results?.grade || '—'}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Export report */}
          <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 mb-6">
            <p className="text-xs font-medium text-amber-900 mb-3">📱 Export for WhatsApp</p>
            <pre className="text-xs bg-white border border-amber-100 rounded p-3 mb-3 overflow-auto max-h-48 whitespace-pre-wrap break-words font-mono">
              {reportText}
            </pre>
            <Button
              onClick={handleCopy}
              variant="outline"
              size="sm"
              className="w-full"
            >
              {copied ? (
                <>
                  <Check className="w-4 h-4 mr-2" />
                  Copied
                </>
              ) : (
                <>
                  <Copy className="w-4 h-4 mr-2" />
                  Copy Report
                </>
              )}
            </Button>
          </div>

          {/* Close button */}
          <Button
            onClick={onClose}
            variant="outline"
            className="w-full"
          >
            Close
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
