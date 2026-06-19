import { describe, it, expect, vi, beforeEach } from 'vitest';
import type { PunjabTeacher } from '@/types/teacher';

vi.mock('@/integrations/supabase/client', () => ({
  supabase: {
    from: vi.fn(),
  },
}));

import { supabase } from '@/integrations/supabase/client';
import { listRawalpindiTeachersByCluster } from '../rawalpindiTeachers';

const CLUSTER = 'Adyala';

const MOCK_ROW: Partial<PunjabTeacher> = {
  id: 't1',
  teacher_name: 'GPS DHALA',
  school_name: 'GPS DHALA',
  cluster_name: CLUSTER,
  overall_percentage: 0,
  observation_count: 0,
  classroom_management: 0,
  lesson_planning: 0,
  instructional_strategies: 0,
  student_engagement: 0,
  assessment_feedback: 0,
  multigrade_setup: 0,
  total_score: 0,
  max_total_score: 51,
};

function makeChain(resolved: { data: unknown; error: unknown }) {
  const chain = {
    select: vi.fn().mockReturnThis(),
    eq: vi.fn().mockReturnThis(),
    order: vi.fn().mockResolvedValue(resolved),
  };
  return chain;
}

beforeEach(() => {
  vi.clearAllMocks();
});

describe('rawalpindi data layer', () => {
  it('returns teachers ordered by overall_percentage ascending for a cluster', async () => {
    const chain = makeChain({ data: [MOCK_ROW], error: null });
    vi.mocked(supabase.from).mockReturnValue(chain as never);

    const result = await listRawalpindiTeachersByCluster(CLUSTER);

    expect(supabase.from).toHaveBeenCalledWith('rawalpindi_teacher_scores');
    expect(chain.eq).toHaveBeenCalledWith('cluster_name', CLUSTER);
    expect(chain.order).toHaveBeenCalledWith('overall_percentage', { ascending: true });
    expect(result).toHaveLength(1);
    expect(result[0].cluster_name).toBe(CLUSTER);
  });

  it('returns empty array when cluster has no rows', async () => {
    const chain = makeChain({ data: [], error: null });
    vi.mocked(supabase.from).mockReturnValue(chain as never);

    const result = await listRawalpindiTeachersByCluster('NonExistentCluster');

    expect(result).toEqual([]);
  });

  it('throws when supabase returns an error (RLS-denial / anon session)', async () => {
    const chain = makeChain({ data: null, error: { message: 'permission denied', code: '42501' } });
    vi.mocked(supabase.from).mockReturnValue(chain as never);

    await expect(listRawalpindiTeachersByCluster(CLUSTER)).rejects.toMatchObject({
      message: 'permission denied',
    });
  });
});
