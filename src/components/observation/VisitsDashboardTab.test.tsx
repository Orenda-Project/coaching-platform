/**
 * Tests for VisitsDashboardTab — Complete button gate during Neo analysis.
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import type { CotObservation } from '@/types/observation';

vi.mock('sonner', () => ({
  toast: { success: vi.fn(), error: vi.fn(), info: vi.fn() },
}));

vi.mock('@/data/observations', () => ({
  deleteObservation: vi.fn(),
  updateObservationStatus: vi.fn(),
}));

vi.mock('@/lib/audioQueue', () => ({
  getSavedAudio: vi.fn().mockResolvedValue(null),
}));

import { VisitsDashboardTab } from './VisitsDashboardTab';

function makeObs(overrides: Partial<CotObservation> = {}): CotObservation {
  return {
    id: 'obs-1',
    observer_id: 'coach-1',
    teacher_name: 'Rehana Aftab',
    school_name: 'GPS Test School',
    subject: 'Math',
    grade: '3',
    topic: null,
    framework: 'FICO',
    date: '2026-06-25',
    planned_date: '2026-06-25',
    arrival_time: '09:00',
    departure_time: '14:00',
    visit_purpose: 'Classroom Observation',
    visit_type: 'FICO',
    status: 'Scheduled',
    region: 'Urban-II',
    total_score: 0,
    hots_rubric: {},
    created_at: '2026-06-19T09:00:00Z',
    updated_at: '2026-06-19T09:00:00Z',
    ...overrides,
  };
}

function renderAndOpenMenu(observations: CotObservation[]) {
  render(
    <VisitsDashboardTab
      observations={observations}
      onStartDebrief={vi.fn()}
      onRefresh={vi.fn()}
    />,
  );
  // Complete button is inside a Popover — open it first
  const trigger = screen.getByRole('button', { name: '' });
  fireEvent.click(trigger);
}

describe('VisitsDashboardTab – Complete button Neo gate', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('Complete button is disabled when neo_status is processing', () => {
    render(
      <VisitsDashboardTab
        observations={[makeObs({ neo_status: 'processing' })]}
        onStartDebrief={vi.fn()}
        onRefresh={vi.fn()}
      />,
    );
    // Open the popover
    const triggers = screen.getAllByRole('button');
    const menuTrigger = triggers.find(b => b.querySelector('svg'));
    if (menuTrigger) fireEvent.click(menuTrigger);

    const button = screen.queryByTitle(/Neo is analyzing/i);
    expect(button).not.toBeNull();
    expect(button).toBeDisabled();
  });

  it('Complete button shows "Analyzing…" label when neo_status is processing', () => {
    render(
      <VisitsDashboardTab
        observations={[makeObs({ neo_status: 'processing' })]}
        onStartDebrief={vi.fn()}
        onRefresh={vi.fn()}
      />,
    );
    const triggers = screen.getAllByRole('button');
    const menuTrigger = triggers.find(b => b.querySelector('svg'));
    if (menuTrigger) fireEvent.click(menuTrigger);

    expect(screen.queryByText('Analyzing…')).not.toBeNull();
  });

  it('Complete button is enabled when neo_status is completed', () => {
    render(
      <VisitsDashboardTab
        observations={[makeObs({ neo_status: 'completed' })]}
        onStartDebrief={vi.fn()}
        onRefresh={vi.fn()}
      />,
    );
    const triggers = screen.getAllByRole('button');
    const menuTrigger = triggers.find(b => b.querySelector('svg'));
    if (menuTrigger) fireEvent.click(menuTrigger);

    const button = screen.queryByTitle(/Mark as complete/i);
    expect(button).not.toBeNull();
    expect(button).not.toBeDisabled();
  });

  it('Complete button is enabled when neo_status is null', () => {
    render(
      <VisitsDashboardTab
        observations={[makeObs({ neo_status: null })]}
        onStartDebrief={vi.fn()}
        onRefresh={vi.fn()}
      />,
    );
    const triggers = screen.getAllByRole('button');
    const menuTrigger = triggers.find(b => b.querySelector('svg'));
    if (menuTrigger) fireEvent.click(menuTrigger);

    const button = screen.queryByTitle(/Mark as complete/i);
    expect(button).not.toBeNull();
    expect(button).not.toBeDisabled();
  });
});
