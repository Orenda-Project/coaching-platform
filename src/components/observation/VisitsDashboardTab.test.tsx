/**
 * Tests for VisitsDashboardTab — action buttons on scheduled visit cards.
 * Buttons are now always-visible labeled icons (no popover required).
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
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

function renderTab(observations: CotObservation[]) {
  render(
    <VisitsDashboardTab
      observations={observations}
      onStartDebrief={vi.fn()}
      onRefresh={vi.fn()}
    />,
  );
}

describe('VisitsDashboardTab – Debrief button', () => {
  beforeEach(() => vi.clearAllMocks());

  it('shows "Analyzing…" and is disabled when neo_status is processing', () => {
    renderTab([makeObs({ neo_status: 'processing' })]);
    const btn = screen.getByText('Analyzing…').closest('button');
    expect(btn).not.toBeNull();
    expect(btn).toBeDisabled();
  });

  it('shows "Debrief" and is enabled when neo_status is null', () => {
    renderTab([makeObs({ neo_status: null })]);
    const btn = screen.getByText('Debrief').closest('button');
    expect(btn).not.toBeNull();
    expect(btn).not.toBeDisabled();
  });

  it('shows "Debriefed" when neo_status is completed', () => {
    renderTab([makeObs({ neo_status: 'completed' })]);
    expect(screen.getByText('Debriefed')).toBeTruthy();
  });
});

describe('VisitsDashboardTab – Done button', () => {
  beforeEach(() => vi.clearAllMocks());

  it('is disabled when neo_status is processing', () => {
    renderTab([makeObs({ neo_status: 'processing' })]);
    const btn = screen.getByText('Done').closest('button');
    expect(btn).not.toBeNull();
    expect(btn).toBeDisabled();
  });

  it('is enabled when neo_status is completed', () => {
    renderTab([makeObs({ neo_status: 'completed' })]);
    const btn = screen.getByText('Done').closest('button');
    expect(btn).not.toBeNull();
    expect(btn).not.toBeDisabled();
  });

  it('is enabled when neo_status is null', () => {
    renderTab([makeObs({ neo_status: null })]);
    const btn = screen.getByText('Done').closest('button');
    expect(btn).not.toBeNull();
    expect(btn).not.toBeDisabled();
  });
});
