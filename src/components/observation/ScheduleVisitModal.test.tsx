import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
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
    expect(screen.getByText('Mathematics · 5')).toBeInTheDocument();
    expect(screen.getByText('Fatima Ali')).toBeInTheDocument();
    expect(screen.getByText('Islamabad')).toBeInTheDocument();
  });

  it('disables Confirm button until date and purpose are filled', async () => {
    const user = userEvent.setup();
    render(
      <ScheduleVisitModal
        teacher={mockTeacher}
        coachName="Fatima Ali"
        subRegion="Islamabad"
        onConfirm={mockOnConfirm}
        onClose={mockOnClose}
      />
    );

    const confirmButton = screen.getByRole('button', { name: /Confirm Visit/i });
    expect(confirmButton).toBeDisabled();

    // Fill only date
    const dateInput = screen.getByLabelText(/Visit Date/i) as HTMLInputElement;
    await user.click(dateInput);
    fireEvent.change(dateInput, { target: { value: '2026-05-20' } });
    expect(confirmButton).toBeDisabled();

    // Fill purpose
    const purposeSelect = screen.getByLabelText(/Purpose of Visit/i) as HTMLSelectElement;
    await user.selectOptions(purposeSelect, 'Classroom Observation');
    expect(confirmButton).not.toBeDisabled();
  });

  it('calls onConfirm with correct data including optional lesson_topic', async () => {
    const user = userEvent.setup();
    render(
      <ScheduleVisitModal
        teacher={mockTeacher}
        coachName="Fatima Ali"
        subRegion="Islamabad"
        onConfirm={mockOnConfirm}
        onClose={mockOnClose}
      />
    );

    const dateInput = screen.getByLabelText(/Visit Date/i);
    await user.click(dateInput);
    fireEvent.change(dateInput, { target: { value: '2026-05-20' } });

    const purposeSelect = screen.getByLabelText(/Purpose of Visit/i);
    await user.selectOptions(purposeSelect, 'Lesson Plan Review');

    const topicInput = screen.getByPlaceholderText(/e.g., Fractions/i);
    await user.type(topicInput, 'Fractions in Division');

    const confirmButton = screen.getByRole('button', { name: /Confirm Visit/i });
    await user.click(confirmButton);

    await waitFor(() => {
      expect(mockOnConfirm).toHaveBeenCalledWith({
        date: '2026-05-20',
        visit_purpose: 'Lesson Plan Review',
        lesson_topic: 'Fractions in Division',
      });
    });
  });

  it('calls onConfirm with undefined lesson_topic when topic is blank', async () => {
    const user = userEvent.setup();
    render(
      <ScheduleVisitModal
        teacher={mockTeacher}
        coachName="Fatima Ali"
        subRegion="Islamabad"
        onConfirm={mockOnConfirm}
        onClose={mockOnClose}
      />
    );

    const dateInput = screen.getByLabelText(/Visit Date/i);
    await user.click(dateInput);
    fireEvent.change(dateInput, { target: { value: '2026-05-20' } });

    const purposeSelect = screen.getByLabelText(/Purpose of Visit/i);
    await user.selectOptions(purposeSelect, 'Coaching Follow-up');

    const confirmButton = screen.getByRole('button', { name: /Confirm Visit/i });
    await user.click(confirmButton);

    await waitFor(() => {
      expect(mockOnConfirm).toHaveBeenCalledWith({
        date: '2026-05-20',
        visit_purpose: 'Coaching Follow-up',
        lesson_topic: undefined,
      });
    });
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

    // The min attribute should be set to today
    expect(dateInput.min).toBe(todayStr);
  });

  it('calls onClose when cancel button is clicked', async () => {
    const user = userEvent.setup();
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
    await user.click(cancelButton);

    expect(mockOnClose).toHaveBeenCalled();
  });

  it('calls onClose when X button is clicked', async () => {
    const user = userEvent.setup();
    render(
      <ScheduleVisitModal
        teacher={mockTeacher}
        coachName="Fatima Ali"
        subRegion="Islamabad"
        onConfirm={mockOnConfirm}
        onClose={mockOnClose}
      />
    );

    const closeButton = screen.getByRole('button', { name: '' }); // X button has no accessible name
    await user.click(closeButton);

    expect(mockOnClose).toHaveBeenCalled();
  });
});
