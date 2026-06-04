import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { ScheduleVisitModal } from './ScheduleVisitModal';
import type { DCTeacher } from '@/types/teacher';

const mockTeacher: DCTeacher = {
  user_id: 'test-teacher-1',
  teacher_name: 'Ahmed Khan',
  school: 'Government School #5',
  sector: 'ICT',
  overall_percentage: 75,
  total_score: 60,
  created_date: '2026-05-01',
  grade: '5',
  subject: 'Mathematics',
  accurate_lesson_planning: 3,
  timely_lesson_delivery: 3,
  subject_command: 3,
  effective_pedagogy: 3,
  effective_resource_use: 3,
  activity_based_learning: 3,
  student_participation: 3,
  critical_thinking: 3,
  inclusive_practices: 3,
  technology_integration: 3,
  technology_handling: 3,
  verbal_communication: 3,
  non_verbal_communication: 3,
};

describe('ScheduleVisitModal', () => {
  const mockOnConfirm = vi.fn();
  const mockOnClose = vi.fn();

  beforeEach(() => {
    mockOnConfirm.mockClear();
    mockOnClose.mockClear();
  });

  it('renders with auto-filled teacher information', () => {
    render(
      <ScheduleVisitModal
        teacher={mockTeacher}
        coachName="Fatima Ali"
        subRegion="Islamabad"
        onConfirm={mockOnConfirm}
        onClose={mockOnClose}
      />
    );

    expect(screen.getByText('Ahmed Khan')).toBeInTheDocument();
    expect(screen.getByText('Government School #5')).toBeInTheDocument();
  });

  it('prevents selecting past dates', () => {
    render(
      <ScheduleVisitModal
        teacher={mockTeacher}
        coachName="Fatima Ali"
        subRegion="Islamabad"
        onConfirm={mockOnConfirm}
        onClose={mockOnClose}
      />
    );

    const dateInput = screen.getByLabelText(/Visit Date/i) as HTMLInputElement;
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, '0');
    const day = String(today.getDate()).padStart(2, '0');
    const todayStr = `${year}-${month}-${day}`;

    expect(dateInput.min).toBe(todayStr);
  });

  it('calls onClose when cancel button is clicked', () => {
    render(
      <ScheduleVisitModal
        teacher={mockTeacher}
        coachName="Fatima Ali"
        subRegion="Islamabad"
        onConfirm={mockOnConfirm}
        onClose={mockOnClose}
      />
    );

    const cancelButton = screen.getByRole('button', { name: /Cancel/i });
    fireEvent.click(cancelButton);

    expect(mockOnClose).toHaveBeenCalled();
  });

  it('calls onClose when X button is clicked', () => {
    const { container } = render(
      <ScheduleVisitModal
        teacher={mockTeacher}
        coachName="Fatima Ali"
        subRegion="Islamabad"
        onConfirm={mockOnConfirm}
        onClose={mockOnClose}
      />
    );

    const closeButton = container.querySelector('button[type="button"]');
    if (closeButton) {
      fireEvent.click(closeButton);
    }

    expect(mockOnClose).toHaveBeenCalled();
  });
});
