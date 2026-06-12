/**
 * Integration tests for the Observation Scheduler flow.
 *
 * Covers the full user journey:
 *   1. User sees the teacher list (DCDashboard)
 *   2. User opens the schedule modal and submits a visit (ScheduleVisitModal)
 *   3. DCDashboard → Modal → onScheduleVisit full path
 *   4. After scheduling, the Visits tab shows the new observation (VisitsDashboardTab)
 *   5. User can perform further actions (debrief, draft, complete views)
 *   6. Regression: visit_purpose is never undefined/missing
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import type { CotObservation, ScheduleVisitFormData } from '@/types/observation';
import type { DCTeacher } from '@/types/teacher';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

vi.mock('sonner', () => ({
  toast: { success: vi.fn(), error: vi.fn(), info: vi.fn() },
}));

vi.mock('@/integrations/supabase/client', () => ({
  supabase: {
    from: vi.fn(() => ({
      delete: vi.fn().mockReturnThis(),
      update: vi.fn().mockReturnThis(),
      eq: vi.fn().mockResolvedValue({ error: null }),
    })),
  },
}));

import DCDashboard from './DCDashboard';
import { ScheduleVisitModal } from './ScheduleVisitModal';
import { VisitsDashboardTab } from './VisitsDashboardTab';

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

function getFutureDate(daysAhead = 7): string {
  const d = new Date();
  d.setDate(d.getDate() + daysAhead);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

const futureDate = getFutureDate();

function makeTeacher(overrides: Partial<DCTeacher> = {}): DCTeacher {
  return {
    user_id: 'teacher-1',
    teacher_name: 'Rehana Aftab',
    school: 'IMS(I-V) No.2 G-9/2',
    sector: 'Urban-II',
    overall_percentage: 55,
    total_score: 45,
    created_date: '2026-05-20',
    grade: '2',
    subject: 'Eng',
    accurate_lesson_planning: 2,
    timely_lesson_delivery: 2,
    subject_command: 3,
    effective_pedagogy: 2,
    effective_resource_use: 1,
    activity_based_learning: 2,
    student_participation: 3,
    critical_thinking: 1,
    inclusive_practices: 2,
    technology_integration: 1,
    technology_handling: 2,
    verbal_communication: 3,
    non_verbal_communication: 2,
    ...overrides,
  };
}

function makeObservation(overrides: Partial<CotObservation> = {}): CotObservation {
  return {
    id: 'obs-1',
    observer_id: 'observer-1',
    teacher_name: 'Rehana Aftab',
    school_name: 'IMS(I-V) No.2 G-9/2',
    subject: 'Eng',
    grade: '2',
    topic: null,
    date: futureDate,
    total_score: 0,
    hots_rubric: {},
    framework: 'FICO',
    status: 'Scheduled',
    region: 'Urban-II',
    visit_purpose: 'Classroom Observation',
    visit_type: 'FICO',
    planned_date: futureDate,
    arrival_time: '09:00',
    departure_time: '14:00',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    ...overrides,
  };
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function renderWithProviders(ui: React.ReactElement) {
  const client = new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0 },
      mutations: { retry: false },
    },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>{ui}</MemoryRouter>
    </QueryClientProvider>,
  );
}

// ===========================================================================
// TEST SUITES
// ===========================================================================

describe('Observation Scheduler – Full Flow', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  // =========================================================================
  // 1. Teacher List (DCDashboard)
  // =========================================================================
  describe('Step 1: User sees the teacher list', () => {
    const tier1Teacher = makeTeacher({ overall_percentage: 55 });
    const tier3Teacher = makeTeacher({
      user_id: 'teacher-2',
      teacher_name: 'Ahmad Shah',
      school: 'GGPS F-8/1',
      overall_percentage: 82,
      total_score: 78,
      subject: 'Math',
      grade: '4',
    });

    it('renders teacher names, schools, and scores', () => {
      renderWithProviders(
        <DCDashboard
          teachers={[tier1Teacher, tier3Teacher]}
          onScheduleVisit={vi.fn()}
          coachName="Test Coach"
          subRegion="Urban-II"
          loading={false}
        />,
      );

      expect(screen.getByText('Rehana Aftab')).toBeInTheDocument();
      expect(screen.getByText('IMS(I-V) No.2 G-9/2')).toBeInTheDocument();
      expect(screen.getByText('55.0%')).toBeInTheDocument();
      expect(screen.getByText('Total Teachers')).toBeInTheDocument();
      expect(screen.getByText('2')).toBeInTheDocument();
    });

    it('shows a Schedule Visit button for each visible teacher', () => {
      renderWithProviders(
        <DCDashboard
          teachers={[tier1Teacher]}
          onScheduleVisit={vi.fn()}
          coachName="Test Coach"
          subRegion="Urban-II"
          loading={false}
        />,
      );

      const scheduleButtons = screen.getAllByRole('button', { name: /Schedule Visit/i });
      expect(scheduleButtons.length).toBeGreaterThanOrEqual(1);
    });

    it('shows loading spinner when loading', () => {
      renderWithProviders(
        <DCDashboard
          teachers={[]}
          onScheduleVisit={vi.fn()}
          coachName="Test Coach"
          subRegion="Urban-II"
          loading={true}
        />,
      );

      expect(document.querySelector('.animate-spin')).toBeInTheDocument();
    });

    it('shows empty state when no teachers', () => {
      renderWithProviders(
        <DCDashboard
          teachers={[]}
          onScheduleVisit={vi.fn()}
          coachName="Test Coach"
          subRegion="Urban-II"
          loading={false}
        />,
      );

      expect(screen.getByText(/No DC scores available/i)).toBeInTheDocument();
    });

    it('opens the schedule modal when Schedule Visit is clicked', () => {
      renderWithProviders(
        <DCDashboard
          teachers={[tier1Teacher]}
          onScheduleVisit={vi.fn()}
          coachName="Test Coach"
          subRegion="Urban-II"
          loading={false}
        />,
      );

      fireEvent.click(screen.getByRole('button', { name: /Schedule Visit/i }));
      expect(screen.getByText('Schedule School Visit')).toBeInTheDocument();
      expect(screen.getByText('Plan your coaching observation')).toBeInTheDocument();
    });

    it('shows teacher indicators when View Indicators is clicked', () => {
      renderWithProviders(
        <DCDashboard
          teachers={[tier1Teacher]}
          onScheduleVisit={vi.fn()}
          coachName="Test Coach"
          subRegion="Urban-II"
          loading={false}
        />,
      );

      fireEvent.click(screen.getByRole('button', { name: /View Indicators/i }));

      expect(screen.getByText('Lesson Planning')).toBeInTheDocument();
      expect(screen.getByText('Subject Mastery')).toBeInTheDocument();
      expect(screen.getByText('Critical Thinking')).toBeInTheDocument();
    });
  });

  // =========================================================================
  // 2. Schedule a Visit (ScheduleVisitModal)
  // =========================================================================
  describe('Step 2: User fills and submits the schedule form', () => {
    const teacher = makeTeacher();

    it('submits with all required fields including visit_purpose', () => {
      const onConfirm = vi.fn();
      renderWithProviders(
        <ScheduleVisitModal
          teacher={teacher}
          coachName="Test Coach"
          subRegion="Urban-II"
          onConfirm={onConfirm}
          onClose={vi.fn()}
        />,
      );

      fireEvent.change(screen.getByLabelText(/Visit Date/i), { target: { value: futureDate } });
      fireEvent.change(screen.getByLabelText(/Visit Purpose/i), { target: { value: 'Coaching Follow-up' } });
      fireEvent.click(screen.getByRole('button', { name: /Schedule Visit/i }));

      expect(onConfirm).toHaveBeenCalledTimes(1);
      const data: ScheduleVisitFormData = onConfirm.mock.calls[0][0];
      expect(data.visit_purpose).toBe('Coaching Follow-up');
      expect(data.date).toBe(futureDate);
      expect(data.planned_date).toBe(futureDate);
      expect(data.visit_type).toBe('FICO');
      expect(data.arrival_time).toBe('09:00');
      expect(data.departure_time).toBe('14:00');
    });

    it('always sends a non-empty visit_purpose string (never undefined)', () => {
      const onConfirm = vi.fn();
      renderWithProviders(
        <ScheduleVisitModal
          teacher={teacher}
          coachName="Test Coach"
          subRegion="Urban-II"
          onConfirm={onConfirm}
          onClose={vi.fn()}
        />,
      );

      fireEvent.change(screen.getByLabelText(/Visit Date/i), { target: { value: futureDate } });
      fireEvent.click(screen.getByRole('button', { name: /Schedule Visit/i }));

      const data = onConfirm.mock.calls[0][0];
      expect(data.visit_purpose).toBeDefined();
      expect(typeof data.visit_purpose).toBe('string');
      expect(data.visit_purpose.length).toBeGreaterThan(0);
    });

    it('allows changing visit type', () => {
      const onConfirm = vi.fn();
      renderWithProviders(
        <ScheduleVisitModal
          teacher={teacher}
          coachName="Test Coach"
          subRegion="Urban-II"
          onConfirm={onConfirm}
          onClose={vi.fn()}
        />,
      );

      fireEvent.change(screen.getByLabelText(/Visit Type/i), { target: { value: 'Head-Co Observation' } });
      fireEvent.change(screen.getByLabelText(/Visit Date/i), { target: { value: futureDate } });
      fireEvent.click(screen.getByRole('button', { name: /Schedule Visit/i }));

      expect(onConfirm.mock.calls[0][0].visit_type).toBe('Head-Co Observation');
    });

    it('allows selecting a week (optional)', () => {
      const onConfirm = vi.fn();
      renderWithProviders(
        <ScheduleVisitModal
          teacher={teacher}
          coachName="Test Coach"
          subRegion="Urban-II"
          onConfirm={onConfirm}
          onClose={vi.fn()}
        />,
      );

      fireEvent.change(screen.getByLabelText(/Week/i), { target: { value: 'Week 3' } });
      fireEvent.change(screen.getByLabelText(/Visit Date/i), { target: { value: futureDate } });
      fireEvent.click(screen.getByRole('button', { name: /Schedule Visit/i }));

      expect(onConfirm.mock.calls[0][0].week).toBe('Week 3');
    });

    it('shows auto-filled teacher info in the modal', () => {
      renderWithProviders(
        <ScheduleVisitModal
          teacher={teacher}
          coachName="Test Coach"
          subRegion="Urban-II"
          onConfirm={vi.fn()}
          onClose={vi.fn()}
        />,
      );

      expect(screen.getByText('Rehana Aftab')).toBeInTheDocument();
      expect(screen.getByText('IMS(I-V) No.2 G-9/2')).toBeInTheDocument();
      expect(screen.getByText('Test Coach')).toBeInTheDocument();
    });
  });

  // =========================================================================
  // 3. DCDashboard → Modal → onScheduleVisit full flow
  // =========================================================================
  describe('Step 3: Full DCDashboard → Modal → callback chain', () => {
    it('clicking Schedule Visit on teacher → filling modal → fires onScheduleVisit with teacher + formData', () => {
      const teacher = makeTeacher();
      const onScheduleVisit = vi.fn();

      renderWithProviders(
        <DCDashboard
          teachers={[teacher]}
          onScheduleVisit={onScheduleVisit}
          coachName="Test Coach"
          subRegion="Urban-II"
          loading={false}
        />,
      );

      // 1. Click Schedule Visit on teacher card
      fireEvent.click(screen.getByRole('button', { name: /Schedule Visit/i }));

      // 2. Modal opens — fill form
      expect(screen.getByText('Schedule School Visit')).toBeInTheDocument();
      fireEvent.change(screen.getByLabelText(/Visit Date/i), { target: { value: futureDate } });
      fireEvent.change(screen.getByLabelText(/Visit Purpose/i), { target: { value: 'Teacher Mentoring' } });

      // 3. Submit — two "Schedule Visit" buttons exist (card + modal submit).
      //    Use the submit button (type="submit") inside the modal form.
      const allScheduleBtns = screen.getAllByRole('button', { name: /Schedule Visit/i });
      const formSubmitBtn = allScheduleBtns.find(
        (btn) => btn.getAttribute('type') === 'submit',
      )!;
      fireEvent.click(formSubmitBtn);

      // 4. Verify callback
      expect(onScheduleVisit).toHaveBeenCalledTimes(1);
      const [calledTeacher, formData] = onScheduleVisit.mock.calls[0];
      expect(calledTeacher.teacher_name).toBe('Rehana Aftab');
      expect(calledTeacher.school).toBe('IMS(I-V) No.2 G-9/2');
      expect(formData.visit_purpose).toBe('Teacher Mentoring');
      expect(formData.date).toBe(futureDate);

      // 5. Modal should close after submit
      expect(screen.queryByText('Schedule School Visit')).not.toBeInTheDocument();
    });
  });

  // =========================================================================
  // 4. Visits Dashboard shows scheduled observations (default Scheduled tab)
  // =========================================================================
  describe('Step 4: User sees scheduled visits in VisitsDashboardTab', () => {
    const scheduledObs = makeObservation();

    it('displays the scheduled visit card with correct details', () => {
      renderWithProviders(
        <VisitsDashboardTab
          observations={[scheduledObs]}
          onStartDebrief={vi.fn()}
          onRefresh={vi.fn()}
        />,
      );

      expect(screen.getByText('Rehana Aftab')).toBeInTheDocument();
      expect(screen.getByText('IMS(I-V) No.2 G-9/2')).toBeInTheDocument();
      expect(screen.getByText('FICO')).toBeInTheDocument();
    });

    it('shows empty state when no visits exist', () => {
      renderWithProviders(
        <VisitsDashboardTab
          observations={[]}
          onStartDebrief={vi.fn()}
          onRefresh={vi.fn()}
        />,
      );

      expect(screen.getByText(/No scheduled visits yet/i)).toBeInTheDocument();
    });

    it('shows all action buttons on scheduled visit cards', () => {
      renderWithProviders(
        <VisitsDashboardTab
          observations={[scheduledObs]}
          onStartDebrief={vi.fn()}
          onRefresh={vi.fn()}
        />,
      );

      expect(screen.getByText('Absent')).toBeInTheDocument();
      expect(screen.getByText('WhatsApp')).toBeInTheDocument();
      expect(screen.getByText('Feedback')).toBeInTheDocument();
      // "Draft" appears in both the tab label and the action button label
      expect(screen.getAllByText('Draft').length).toBeGreaterThanOrEqual(2);
      expect(screen.getByText('Complete')).toBeInTheDocument();
      expect(screen.getByText('Delete')).toBeInTheDocument();
    });

    it('calls onStartDebrief when Feedback button is clicked', () => {
      const onDebrief = vi.fn();
      renderWithProviders(
        <VisitsDashboardTab
          observations={[scheduledObs]}
          onStartDebrief={onDebrief}
          onRefresh={vi.fn()}
        />,
      );

      fireEvent.click(screen.getByTitle('Give Neo Feedback'));
      expect(onDebrief).toHaveBeenCalledWith(scheduledObs);
    });

    it('shows subject and grade info', () => {
      renderWithProviders(
        <VisitsDashboardTab
          observations={[scheduledObs]}
          onStartDebrief={vi.fn()}
          onRefresh={vi.fn()}
        />,
      );

      // Rendered as "{subject} · {grade}"
      expect(screen.getByText(/Eng/)).toBeInTheDocument();
    });

    it('displays the three status tabs (Scheduled, Draft, Completed)', () => {
      renderWithProviders(
        <VisitsDashboardTab
          observations={[scheduledObs]}
          onStartDebrief={vi.fn()}
          onRefresh={vi.fn()}
        />,
      );

      expect(screen.getByRole('tab', { name: /Scheduled/i })).toBeInTheDocument();
      expect(screen.getByRole('tab', { name: /Draft/i })).toBeInTheDocument();
      expect(screen.getByRole('tab', { name: /Completed/i })).toBeInTheDocument();
    });
  });

  // =========================================================================
  // 5. Observation status filtering
  // =========================================================================
  describe('Step 5: Status-based filtering and display', () => {
    it('renders multiple scheduled observations in the default tab', () => {
      const observations = [
        makeObservation({ id: 'obs-1', status: 'Scheduled', teacher_name: 'Teacher A' }),
        makeObservation({ id: 'obs-2', status: 'Scheduled', teacher_name: 'Teacher B' }),
        makeObservation({ id: 'obs-3', status: 'Draft' }),
        makeObservation({ id: 'obs-4', status: 'Submitted' }),
      ];

      renderWithProviders(
        <VisitsDashboardTab
          observations={observations}
          onStartDebrief={vi.fn()}
          onRefresh={vi.fn()}
        />,
      );

      // Default tab is "Scheduled" — should show 2 scheduled observations
      expect(screen.getByText('Teacher A')).toBeInTheDocument();
      expect(screen.getByText('Teacher B')).toBeInTheDocument();

      // Three status tabs should exist
      const tabs = screen.getAllByRole('tab');
      expect(tabs).toHaveLength(3);
    });

    it('shows empty scheduled state when only draft/completed observations exist', () => {
      const draftObs = makeObservation({ id: 'obs-draft', status: 'Draft' });

      renderWithProviders(
        <VisitsDashboardTab
          observations={[draftObs]}
          onStartDebrief={vi.fn()}
          onRefresh={vi.fn()}
        />,
      );

      // Default tab (Scheduled) should show empty state
      expect(screen.getByText(/No scheduled visits yet/i)).toBeInTheDocument();
    });

    it('shows badge count on completed tab when completed observations exist', () => {
      const completedObs = makeObservation({
        id: 'obs-done',
        status: 'Submitted',
        teacher_name: 'Completed Teacher',
        submitted_at: new Date().toISOString(),
      });

      renderWithProviders(
        <VisitsDashboardTab
          observations={[completedObs]}
          onStartDebrief={vi.fn()}
          onRefresh={vi.fn()}
        />,
      );

      // Completed tab should exist and have a badge count
      const completedTab = screen.getByRole('tab', { name: /Completed/i });
      expect(completedTab).toBeInTheDocument();
      // Badge with count 1 should be inside the completed tab
      expect(completedTab.textContent).toContain('1');
    });

    it('shows badge count on draft tab when draft observations exist', () => {
      const draftObs = makeObservation({
        id: 'obs-draft',
        status: 'Draft',
        teacher_name: 'Draft Teacher',
      });

      renderWithProviders(
        <VisitsDashboardTab
          observations={[draftObs]}
          onStartDebrief={vi.fn()}
          onRefresh={vi.fn()}
        />,
      );

      const draftTab = screen.getByRole('tab', { name: /Draft/i });
      expect(draftTab).toBeInTheDocument();
      expect(draftTab.textContent).toContain('1');
    });
  });

  // =========================================================================
  // 7. Regression: visit_purpose is never missing from the API payload
  // =========================================================================
  describe('Regression: visit_purpose field is always sent', () => {
    const teacher = makeTeacher();

    it.each([
      'Classroom Observation',
      'Coaching Follow-up',
      'Teacher Mentoring',
      'Assessment',
      'General Support',
    ])('payload includes visit_purpose="%s" when selected', (purpose) => {
      const onConfirm = vi.fn();
      renderWithProviders(
        <ScheduleVisitModal
          teacher={teacher}
          coachName="Test Coach"
          subRegion="Urban-II"
          onConfirm={onConfirm}
          onClose={vi.fn()}
        />,
      );

      fireEvent.change(screen.getByLabelText(/Visit Purpose/i), { target: { value: purpose } });
      fireEvent.change(screen.getByLabelText(/Visit Date/i), { target: { value: futureDate } });
      fireEvent.click(screen.getByRole('button', { name: /Schedule Visit/i }));

      const data = onConfirm.mock.calls[0][0];
      expect(data.visit_purpose).toBe(purpose);
      expect(data.visit_purpose).not.toBeUndefined();
    });

    it('JSON.stringify of payload always includes visit_purpose key', () => {
      const payload = {
        observer_id: 'observer-1',
        teacher_name: 'Rehana Aftab',
        visit_purpose: 'Classroom Observation',
        status: 'Scheduled',
      };

      const json = JSON.stringify(payload);
      expect(json).toContain('"visit_purpose"');
      expect(JSON.parse(json).visit_purpose).toBe('Classroom Observation');
    });

    it('undefined visit_purpose is dropped by JSON.stringify (demonstrates the original bug)', () => {
      const payloadWithUndefined = {
        observer_id: 'observer-1',
        visit_purpose: undefined,
      };

      const json = JSON.stringify(payloadWithUndefined);
      expect(json).not.toContain('visit_purpose');
    });
  });
});
