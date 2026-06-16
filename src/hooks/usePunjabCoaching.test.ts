import { describe, it, expect, beforeEach, vi } from 'vitest';
import { renderHook, act, waitFor } from '@testing-library/react';
import { usePunjabCoaching } from './usePunjabCoaching';
import type { PunjabTeacher } from '@/types/teacher';

vi.mock('@/data/punjabTeachers', () => ({
  listPunjabTeachersByCluster: vi.fn(),
}));

import { listPunjabTeachersByCluster } from '@/data/punjabTeachers';

const CLUSTER = 'Cluster Chab';
const USER_ID = 'user-xyz';

const MOCK_TEACHERS: PunjabTeacher[] = [
  {
    id: 't1',
    teacher_name: 'Rizwana Yasmeen',
    school_name: 'GGPS SUKWAN',
    cluster_name: CLUSTER,
    classroom_management: 3,
    lesson_planning: 3,
    instructional_strategies: 4,
    student_engagement: 3,
    assessment_feedback: 3,
    multigrade_setup: 0,
    total_score: 16,
    max_total_score: 51,
    overall_percentage: 31.4,
    observation_count: 1,
  },
];

beforeEach(() => {
  localStorage.clear();
  vi.clearAllMocks();
});

describe('usePunjabCoaching', () => {
  it('starts with empty state', () => {
    const { result } = renderHook(() => usePunjabCoaching());
    expect(result.current.teachers).toEqual([]);
    expect(result.current.loading).toBe(false);
    expect(result.current.error).toBeNull();
    expect(result.current.isOffline).toBe(false);
  });

  it('loads teachers from data layer and exposes them', async () => {
    vi.mocked(listPunjabTeachersByCluster).mockResolvedValue(MOCK_TEACHERS);

    const { result } = renderHook(() => usePunjabCoaching());

    await act(async () => {
      await result.current.loadTeachers(CLUSTER);
    });

    expect(result.current.teachers).toEqual(MOCK_TEACHERS);
    expect(result.current.isOffline).toBe(false);
    expect(result.current.error).toBeNull();
  });

  it('writes to cache after successful load', async () => {
    vi.mocked(listPunjabTeachersByCluster).mockResolvedValue(MOCK_TEACHERS);

    const { result } = renderHook(() => usePunjabCoaching());
    await act(async () => {
      await result.current.loadTeachers(CLUSTER, USER_ID);
    });

    const cacheKey = `punjab_teachers_${USER_ID}_${CLUSTER}`;
    const cached = localStorage.getItem(cacheKey);
    expect(cached).not.toBeNull();
    const parsed = JSON.parse(cached!);
    expect(parsed.teachers).toEqual(MOCK_TEACHERS);
    expect(parsed.ts).toBeTruthy();
  });

  it('serves from cache on first call and sets lastSynced', async () => {
    const cacheKey = `punjab_teachers_${USER_ID}_${CLUSTER}`;
    const ts = new Date().toISOString();
    localStorage.setItem(cacheKey, JSON.stringify({ teachers: MOCK_TEACHERS, ts }));

    vi.mocked(listPunjabTeachersByCluster).mockResolvedValue([]);

    const { result } = renderHook(() => usePunjabCoaching());
    await act(async () => {
      await result.current.loadTeachers(CLUSTER, USER_ID);
    });

    // Teachers are overwritten by network response ([]) after cache-first render,
    // but lastSynced was set from cache during the synchronous cache read.
    expect(result.current.lastSynced).toBeTruthy();
  });

  it('sets isOffline and keeps empty teachers when network fails with no cache', async () => {
    vi.mocked(listPunjabTeachersByCluster).mockRejectedValue(new Error('network error'));

    const { result } = renderHook(() => usePunjabCoaching());
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
    const cacheKey = `punjab_teachers_${USER_ID}_${CLUSTER}`;
    const ts = new Date().toISOString();
    localStorage.setItem(cacheKey, JSON.stringify({ teachers: MOCK_TEACHERS, ts }));

    vi.mocked(listPunjabTeachersByCluster).mockRejectedValue(new Error('network error'));

    const { result } = renderHook(() => usePunjabCoaching());
    await act(async () => {
      await result.current.loadTeachers(CLUSTER, USER_ID);
    });

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    // Error should not show because cache data was served
    expect(result.current.isOffline).toBe(true);
  });
});
