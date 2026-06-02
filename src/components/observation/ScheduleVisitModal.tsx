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

const VISIT_TYPES = ['FICO', 'Head-Co Observation', 'M&H', 'General Visit', 'RM Visit'] as const;

export function ScheduleVisitModal({
  teacher,
  coachName,
  subRegion,
  onConfirm,
  onClose,
}: ScheduleVisitModalProps) {
  const [week, setWeek] = useState('');
  const [visitType, setVisitType] = useState<'FICO' | 'Head-Co Observation' | 'M&H' | 'General Visit' | 'RM Visit'>('FICO');
  const [plannedDate, setPlannedDate] = useState('');
  const [visitDate, setVisitDate] = useState('');
  const [arrivalTime, setArrivalTime] = useState('');
  const [departureTime, setDepartureTime] = useState('');

  const today = (() => {
    const d = new Date();
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  })();

  const isFormValid = Boolean(visitType && plannedDate && visitDate && arrivalTime && departureTime);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (isFormValid) {
      onConfirm({
        week: week || undefined,
        visit_type: visitType,
        planned_date: plannedDate,
        date: visitDate,
        arrival_time: arrivalTime,
        departure_time: departureTime,
      });
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 overflow-y-auto">
      <Card className="w-full max-w-2xl my-auto">
        <CardContent className="p-6">
          {/* Header */}
          <div className="flex items-start justify-between mb-6">
            <div>
              <h2 className="text-lg font-semibold text-foreground">Schedule School Visit</h2>
              <p className="text-sm text-muted-foreground mt-1">Plan your coaching observation</p>
            </div>
            <button
              type="button"
              onClick={onClose}
              className="p-1 hover:bg-muted rounded-md transition-colors"
            >
              <X className="w-5 h-5 text-muted-foreground" />
            </button>
          </div>

          {/* Teacher info card */}
          <div className="bg-muted/40 border border-muted rounded-lg p-4 mb-6 space-y-3">
            <div>
              <p className="text-xs font-medium text-muted-foreground">Teacher</p>
              <p className="text-sm font-medium text-foreground">{teacher.teacher_name}</p>
            </div>
            <div className="grid grid-cols-3 gap-4">
              <div>
                <p className="text-xs font-medium text-muted-foreground">School</p>
                <p className="text-sm text-foreground truncate">{teacher.school}</p>
              </div>
              <div>
                <p className="text-xs font-medium text-muted-foreground">Subject & Grade</p>
                <p className="text-sm text-foreground">{teacher.subject} · {teacher.grade}</p>
              </div>
              <div>
                <p className="text-xs font-medium text-muted-foreground">Coach</p>
                <p className="text-sm text-foreground">{coachName}</p>
              </div>
            </div>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Week */}
            <div>
              <label htmlFor="week" className="text-sm font-medium text-foreground block mb-1.5">
                Week
              </label>
              <input
                id="week"
                type="text"
                value={week}
                onChange={(e) => setWeek(e.target.value)}
                placeholder="e.g., Week 1, Week 2..."
                className="w-full px-3 py-2 border border-input rounded-md bg-background text-foreground text-sm placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>

            {/* Visit Type */}
            <div>
              <label htmlFor="visit-type" className="text-sm font-medium text-foreground block mb-1.5">
                Visit Type <span className="text-red-500">*</span>
              </label>
              <select
                id="visit-type"
                value={visitType}
                onChange={(e) => setVisitType(e.target.value as typeof visitType)}
                className="w-full px-3 py-2 border border-input rounded-md bg-background text-foreground text-sm focus:outline-none focus:ring-2 focus:ring-primary"
              >
                {VISIT_TYPES.map((type) => (
                  <option key={type} value={type}>
                    {type}
                  </option>
                ))}
              </select>
            </div>

            {/* Planned Date */}
            <div>
              <label htmlFor="planned-date" className="text-sm font-medium text-foreground block mb-1.5">
                Planned Date <span className="text-red-500">*</span>
              </label>
              <input
                id="planned-date"
                type="date"
                value={plannedDate}
                onChange={(e) => setPlannedDate(e.target.value)}
                min={today}
                className="w-full px-3 py-2 border border-input rounded-md bg-background text-foreground text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                required
              />
            </div>

            {/* Visit Date */}
            <div>
              <label htmlFor="visit-date" className="text-sm font-medium text-foreground block mb-1.5">
                Visit Date <span className="text-red-500">*</span>
              </label>
              <input
                id="visit-date"
                type="date"
                value={visitDate}
                onChange={(e) => setVisitDate(e.target.value)}
                min={today}
                className="w-full px-3 py-2 border border-input rounded-md bg-background text-foreground text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                required
              />
            </div>

            {/* Arrival & Departure Times */}
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="text-sm font-medium text-foreground block mb-1.5">
                  Arrival Time <span className="text-red-500">*</span>
                </label>
                <div className="flex gap-2">
                  <select
                    value={arrivalTime.split(':')[0] || '09'}
                    onChange={(e) => {
                      const m = arrivalTime.split(':')[1] || '00';
                      setArrivalTime(`${e.target.value}:${m}`);
                    }}
                    className="flex-1 px-3 py-2 border border-input rounded-md bg-background text-foreground text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                  >
                    {Array.from({ length: 24 }, (_, i) => String(i).padStart(2, '0')).map((h) => (
                      <option key={h} value={h}>{h}:00</option>
                    ))}
                  </select>
                </div>
              </div>

              <div>
                <label className="text-sm font-medium text-foreground block mb-1.5">
                  Departure Time <span className="text-red-500">*</span>
                </label>
                <div className="flex gap-2">
                  <select
                    value={departureTime.split(':')[0] || '14'}
                    onChange={(e) => {
                      const m = departureTime.split(':')[1] || '00';
                      setDepartureTime(`${e.target.value}:${m}`);
                    }}
                    className="flex-1 px-3 py-2 border border-input rounded-md bg-background text-foreground text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                  >
                    {Array.from({ length: 24 }, (_, i) => String(i).padStart(2, '0')).map((h) => (
                      <option key={h} value={h}>{h}:00</option>
                    ))}
                  </select>
                </div>
              </div>
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
                Schedule Visit
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
