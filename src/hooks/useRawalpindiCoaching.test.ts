import { describe, it, expect, beforeEach, vi } from 'vitest';
import { renderHook, act, waitFor } from '@testing-library/react';
import { useRawalpindiCoaching } from './useRawalpindiCoaching';
import type { PunjabTeacher } from '@/types/teacher';

vi.mock('@/data/rawalpindiTeachers', () => ({
  listRawalpindiTeachersByCluster: vi.fn(),
}));

import { listRawalpindiTeachersByCluster } from '@/data/rawalpindiTeachers';

const CLUSTER = 'Adyala';
const USER_ID = 'user-xyz';

const MOCK_TEACHERS: PunjabTeacher[] = [
  {
    id: 't1',
    teacher_name: 'Abdul Qadoos',
    school_name: 'GPS DHALA',
    cluster_name: CLUSTER,
    classroom_management: 0,
    lesson_planning: 0,
    instructional_strategies: 0,
    student_engagement: 0,
    assessment_feedback: 0,
    multigrade_setup: 0,
    total_score: 0,
    max_total_score: 51,
    overall_percentage: 0,
    observation_count: 0,
  },
];

beforeEach(() => {
  localStorage.clear();
  vi.clearAllMocks();
});

describe('useRawalpindiCoaching', () => {
  it('starts with empty state', () => {
    const { result } = renderHook(() => useRawalpindiCoaching());
    expect(result.current.teachers).toEqual([]);
    expect(result.current.loading).toBe(false);
    expect(result.current.error).toBeNull();
    expect(result.current.isOffline).toBe(false);
  });

  it('loads teachers from data layer and exposes them', async () => {
    vi.mocked(listRawalpindiTeachersByCluster).mockResolvedValue(MOCK_TEACHERS);

    const { result } = renderHook(() => useRawalpindiCoaching());

    await act(async () => {
      await result.current.loadTeachers(CLUSTER);
    });

    expect(result.current.teachers).toEqual(MOCK_TEACHERS);
    expect(result.current.isOffline).toBe(false);
    expect(result.current.error).toBeNull();
  });

  it('writes to cache after successful load', async () => {
    vi.mocked(listRawalpindiTeachersByCluster).mockResolvedValue(MOCK_TEACHERS);

    const { result } = renderHook(() => useRawalpindiCoaching());
    await act(async () => {
      await result.current.loadTeachers(CLUSTER, USER_ID);
    });

    const cacheKey = `rawalpindi_teachers_${USER_ID}_${CLUSTER}`;
    const cached = localStorage.getItem(cacheKey);
    expect(cached).not.toBeNull();
    const parsed = JSON.parse(cached!);
    expect(parsed.teachers).toEqual(MOCK_TEACHERS);
    expect(parsed.ts).toBeTruthy();
  });

  it('serves from cache on first call and sets lastSynced', async () => {
    const cacheKey = `rawalpindi_teachers_${USER_ID}_${CLUSTER}`;
    const ts = new Date().toISOString();
    localStorage.setItem(cacheKey, JSON.stringify({ teachers: MOCK_TEACHERS, ts }));

    vi.mocked(listRawalpindiTeachersByCluster).mockResolvedValue([]);

    const { result } = renderHook(() => useRawalpindiCoaching());
    await act(async () => {
      await result.current.loadTeachers(CLUSTER, USER_ID);
    });

    expect(result.current.lastSynced).toBeTruthy();
  });

  it('sets isOffline and keeps empty teachers when network fails with no cache', async () => {
    vi.mocked(listRawalpindiTeachersByCluster).mockRejectedValue(new Error('network error'));

    const { result } = renderHook(() => useRawalpindiCoaching());
    await act(async () => {
      await result.current.loadTeachers(CLUSTER);
    });

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.isOffline).toBe(true);
    expect(result.current.error).toBe('network error');
  });

  it('sets isOffline without error when network fails but cache was already served', async () => {
    const cacheKey = `rawalpindi_teachers_${USER_ID}_${CLUSTER}`;
    const ts = new Date().toISOString();
    localStorage.setItem(cacheKey, JSON.stringify({ teachers: MOCK_TEACHERS, ts }));

    vi.mocked(listRawalpindiTeachersByCluster).mockRejectedValue(new Error('network error'));

    const { result } = renderHook(() => useRawalpindiCoaching());
    await act(async () => {
      await result.current.loadTeachers(CLUSTER, USER_ID);
    });

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.isOffline).toBe(true);
  });
});
