import { useState } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { X } from 'lucide-react';
import type { DCTeacher } from '@/types/teacher';
import type { ScheduleVisitFormData } from '@/types/observation';

interface ScheduleVisitModalProps {
  teacher: DCTeacher;
  coachName: string;
  subRegion: string;
  onConfirm: (data: ScheduleVisitFormData) => void;
  onClose: () => void;
}

const VISIT_PURPOSE_OPTIONS = [
  'Classroom Observation',
  'Lesson Plan Review',
  'Coaching Follow-up',
  'Support Visit',
  'Assessment Check',
];

export function ScheduleVisitModal({
  teacher,
  coachName,
  subRegion,
  onConfirm,
  onClose,
}: ScheduleVisitModalProps) {
  const [date, setDate] = useState('');
  const [visitPurpose, setVisitPurpose] = useState('');
  const [lessonTopic, setLessonTopic] = useState('');

  // Compute today's date in local timezone (not UTC)
  const today = (() => {
    const d = new Date();
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  })();

  const isFormValid = Boolean(date && visitPurpose);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (isFormValid) {
      onConfirm({
        date,
        visit_purpose: visitPurpose,
        lesson_topic: lessonTopic || undefined,
      });
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 overflow-y-auto">
      <Card className="w-full max-w-xl my-auto">
        <CardContent className="p-6">
          {/* Header */}
          <div className="flex items-start justify-between mb-6">
            <div>
              <h2 className="text-lg font-semibold text-foreground">Schedule Visit</h2>
              <p className="text-sm text-muted-foreground mt-1">Plan your coaching visit</p>
            </div>
            <button
              type="button"
              onClick={onClose}
              className="p-1 hover:bg-muted rounded-md transition-colors"
            >
              <X className="w-5 h-5 text-muted-foreground" />
            </button>
          </div>

          {/* Auto-filled info card */}
          <div className="bg-muted/40 border border-muted rounded-lg p-4 mb-6 space-y-3">
            <div>
              <p className="text-xs font-medium text-muted-foreground">Teacher</p>
              <p className="text-sm font-medium text-foreground">{teacher.teacher_name}</p>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-xs font-medium text-muted-foreground">School</p>
                <p className="text-sm text-foreground truncate">{teacher.school}</p>
              </div>
              <div>
                <p className="text-xs font-medium text-muted-foreground">Subject & Grade</p>
                <p className="text-sm text-foreground">
                  {teacher.subject} · {teacher.grade}
                </p>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-xs font-medium text-muted-foreground">Coach</p>
                <p className="text-sm text-foreground">{coachName}</p>
              </div>
              <div>
                <p className="text-xs font-medium text-muted-foreground">Sub-region</p>
                <p className="text-sm text-foreground">{subRegion}</p>
              </div>
            </div>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Date picker */}
            <div>
              <label className="text-sm font-medium text-foreground block mb-1.5">
                Visit Date <span className="text-red-500">*</span>
              </label>
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                min={today}
                className="w-full px-3 py-2 border border-input rounded-md bg-background text-foreground text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                required
              />
              <p className="text-xs text-muted-foreground mt-1">Cannot be in the past</p>
            </div>

            {/* Purpose dropdown */}
            <div>
              <label className="text-sm font-medium text-foreground block mb-1.5">
                Purpose of Visit <span className="text-red-500">*</span>
              </label>
              <select
                value={visitPurpose}
                onChange={(e) => setVisitPurpose(e.target.value)}
                className="w-full px-3 py-2 border border-input rounded-md bg-background text-foreground text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                required
              >
                <option value="">Select a purpose...</option>
                {VISIT_PURPOSE_OPTIONS.map((purpose) => (
                  <option key={purpose} value={purpose}>
                    {purpose}
                  </option>
                ))}
              </select>
            </div>

            {/* Lesson topic text input */}
            <div>
              <label className="text-sm font-medium text-foreground block mb-1.5">
                Lesson Topic to Observe
              </label>
              <input
                type="text"
                value={lessonTopic}
                onChange={(e) => setLessonTopic(e.target.value)}
                placeholder="e.g., Fractions, Constitutional Rights..."
                className="w-full px-3 py-2 border border-input rounded-md bg-background text-foreground text-sm placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
              />
              <p className="text-xs text-muted-foreground mt-1">Optional</p>
            </div>

            {/* Buttons */}
            <div className="flex gap-3 pt-4">
              <Button
                type="button"
                variant="outline"
                onClick={onClose}
                className="flex-1"
              >
                Cancel
              </Button>
              <Button
                type="submit"
                disabled={!isFormValid}
                className="flex-1"
              >
                Confirm Visit
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
