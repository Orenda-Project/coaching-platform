import { describe, it, expect, beforeEach, vi } from 'vitest';
import {
  queueVisit,
  getPendingVisits,
  markSynced,
  syncPendingVisits,
  makePseudoObservation,
} from './rawalpindiOfflineQueue';
import type { ScheduleVisitPayload } from '@/data/observations';

vi.mock('@/data/observations', () => ({
  scheduleVisit: vi.fn(),
}));

import { scheduleVisit } from '@/data/observations';

const USER_ID = 'user-abc';
const PAYLOAD: ScheduleVisitPayload = {
  observer_id: USER_ID,
  teacher_name: 'Abdul Qadoos',
  school_name: 'GPS DHALA',
  subject: 'Math',
  grade: 'Grade 4',
  topic: null,
  framework: 'HOTS',
  date: '2026-06-20',
  visit_purpose: 'Coaching',
  status: 'Scheduled',
  region: 'Adyala',
};

beforeEach(() => {
  localStorage.clear();
  vi.clearAllMocks();
});

describe('queueVisit', () => {
  it('adds a pending visit to localStorage', () => {
    const pending = queueVisit(USER_ID, PAYLOAD);
    expect(pending.localId).toMatch(/^local_/);
    expect(pending.payload).toEqual(PAYLOAD);
    const queue = getPendingVisits(USER_ID);
    expect(queue).toHaveLength(1);
    expect(queue[0].localId).toBe(pending.localId);
  });

  it('appends without overwriting existing items', () => {
    queueVisit(USER_ID, PAYLOAD);
    queueVisit(USER_ID, { ...PAYLOAD, teacher_name: 'Second Teacher' });
    expect(getPendingVisits(USER_ID)).toHaveLength(2);
  });
});

describe('getPendingVisits', () => {
  it('returns empty array when queue is empty', () => {
    expect(getPendingVisits(USER_ID)).toEqual([]);
  });

  it('returns empty array when localStorage is malformed', () => {
    localStorage.setItem(`rawalpindi_offline_queue_${USER_ID}`, 'not-json');
    expect(getPendingVisits(USER_ID)).toEqual([]);
  });
});

describe('markSynced', () => {
  it('removes the item with the matching localId', () => {
    const p1 = queueVisit(USER_ID, PAYLOAD);
    const p2 = queueVisit(USER_ID, { ...PAYLOAD, teacher_name: 'Second' });
    markSynced(USER_ID, p1.localId);
    const remaining = getPendingVisits(USER_ID);
    expect(remaining).toHaveLength(1);
    expect(remaining[0].localId).toBe(p2.localId);
  });

  it('is a no-op for an unknown localId', () => {
    queueVisit(USER_ID, PAYLOAD);
    markSynced(USER_ID, 'does-not-exist');
    expect(getPendingVisits(USER_ID)).toHaveLength(1);
  });
});

describe('syncPendingVisits', () => {
  it('returns { synced: 0, failed: 0 } when queue is empty', async () => {
    const result = await syncPendingVisits(USER_ID);
    expect(result).toEqual({ synced: 0, failed: 0 });
  });

  it('calls scheduleVisit for each pending item and removes them on success', async () => {
    vi.mocked(scheduleVisit).mockResolvedValue({} as never);
    queueVisit(USER_ID, PAYLOAD);
    queueVisit(USER_ID, { ...PAYLOAD, teacher_name: 'Second' });

    const result = await syncPendingVisits(USER_ID);
    expect(result.synced).toBe(2);
    expect(result.failed).toBe(0);
    expect(getPendingVisits(USER_ID)).toHaveLength(0);
  });

  it('counts failures and leaves failed items in queue', async () => {
    vi.mocked(scheduleVisit).mockRejectedValue(new Error('network'));
    queueVisit(USER_ID, PAYLOAD);

    const result = await syncPendingVisits(USER_ID);
    expect(result.synced).toBe(0);
    expect(result.failed).toBe(1);
    expect(getPendingVisits(USER_ID)).toHaveLength(1);
  });

  it('handles partial success (first succeeds, second fails)', async () => {
    vi.mocked(scheduleVisit)
      .mockResolvedValueOnce({} as never)
      .mockRejectedValueOnce(new Error('network'));

    queueVisit(USER_ID, PAYLOAD);
    queueVisit(USER_ID, { ...PAYLOAD, teacher_name: 'Second' });

    const result = await syncPendingVisits(USER_ID);
    expect(result.synced).toBe(1);
    expect(result.failed).toBe(1);
    expect(getPendingVisits(USER_ID)).toHaveLength(1);
  });
});

describe('makePseudoObservation', () => {
  it('returns a CotObservation with the pending visit data', () => {
    const pending = queueVisit(USER_ID, PAYLOAD);
    const obs = makePseudoObservation(pending);

    expect(obs.id).toBe(pending.localId);
    expect(obs.teacher_name).toBe(PAYLOAD.teacher_name);
    expect(obs.school_name).toBe(PAYLOAD.school_name);
    expect(obs.status).toBe('Scheduled');
    expect(obs.observer_id).toBe(USER_ID);
  });

  it('sets null for optional fields when not in payload', () => {
    const pending = queueVisit(USER_ID, PAYLOAD);
    const obs = makePseudoObservation(pending);
    expect(obs.topic).toBeNull();
    expect(obs.visit_type).toBeNull();
  });
});
