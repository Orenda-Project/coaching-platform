import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { X, AlertCircle, Calendar } from 'lucide-react';
import type { CotObservation } from '@/types/observation';

interface TeacherAbsentModalProps {
  observation: CotObservation;
  onConfirm: () => void;
  onClose: () => void;
  onNavigateToScheduler: () => void;
}

export function TeacherAbsentModal({
  observation,
  onConfirm,
  onClose,
  onNavigateToScheduler,
}: TeacherAbsentModalProps) {
  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <CardContent className="p-6">
          <div className="flex items-start justify-between mb-4">
            <h2 className="text-lg font-semibold text-foreground">Teacher Absent?</h2>
            <button
              onClick={onClose}
              className="p-1 hover:bg-muted rounded-md transition-colors"
            >
              <X className="w-5 h-5 text-muted-foreground" />
            </button>
          </div>

          <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 mb-4 space-y-3">
            <div className="flex gap-2">
              <AlertCircle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
              <div>
                <p className="text-lg font-bold text-amber-900">
                  {observation.teacher_name}
                </p>
                <p className="text-sm text-amber-800 mt-1">
                  is unavailable on {new Date(observation.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })} at {observation.school_name}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
            <h3 className="font-medium text-blue-900 mb-2">Next Steps</h3>
            <ol className="text-sm text-blue-900 space-y-2 list-decimal list-inside">
              <li>Go to Smart Plan tab</li>
              <li>Find 1–3 overdue teachers from {observation.school_name} or nearby</li>
              <li>Schedule a visit with them instead</li>
            </ol>
            <p className="text-xs text-blue-800 mt-3">
              Teachers are ranked by coaching priority. Start with the top one.
            </p>
          </div>

          <div className="flex gap-3">
            <Button
              type="button"
              variant="outline"
              onClick={onClose}
              className="flex-1"
            >
              Cancel
            </Button>
            <Button
              type="button"
              onClick={() => {
                onNavigateToScheduler();
                onClose();
              }}
              className="flex-1 gap-1.5"
            >
              <Calendar className="w-4 h-4" />
              Go to Smart Plan
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
