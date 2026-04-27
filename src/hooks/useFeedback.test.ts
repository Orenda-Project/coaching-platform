import { renderHook, act } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useFeedback } from './useFeedback';

// Mocks
const insertMock = vi.fn();
vi.mock('@/integrations/supabase/client', () => ({
  supabase: {
    from: () => ({ insert: insertMock }),
  },
}));

const useAuthMock = vi.fn();
vi.mock('@/contexts/AuthContext', () => ({
  useAuth: () => useAuthMock(),
}));

describe('useFeedback', () => {
  beforeEach(() => {
    insertMock.mockReset();
    useAuthMock.mockReset();
  });

  it('returns ok:false when user is not authenticated', async () => {
    useAuthMock.mockReturnValue({ user: null, profile: null });
    const { result } = renderHook(() => useFeedback());

    let outcome: { ok: boolean; error?: string } = { ok: false };
    await act(async () => {
      outcome = await result.current.submit({
        category: 'platform',
        rating: 5,
        context_page: '/dashboard',
      });
    });

    expect(outcome.ok).toBe(false);
    expect(insertMock).not.toHaveBeenCalled();
  });

  it('inserts a feedback row with auth context and returns ok:true', async () => {
    useAuthMock.mockReturnValue({
      user: { id: 'user-123' },
      profile: { persona: 'B' },
    });
    insertMock.mockResolvedValue({ error: null });

    const { result } = renderHook(() => useFeedback());

    let outcome: { ok: boolean; error?: string } = { ok: false };
    await act(async () => {
      outcome = await result.current.submit({
        category: 'bug',
        rating: 2,
        positive_feedback: '  good thing  ',
        improvement_feedback: '',
        context_page: '/training/abc',
        training_id: 'train-1',
      });
    });

    expect(outcome.ok).toBe(true);
    expect(insertMock).toHaveBeenCalledTimes(1);
    const payload = insertMock.mock.calls[0][0];
    expect(payload.user_id).toBe('user-123');
    expect(payload.persona).toBe('B');
    expect(payload.category).toBe('bug');
    expect(payload.rating).toBe(2);
    expect(payload.positive_feedback).toBe('good thing'); // trimmed
    expect(payload.improvement_feedback).toBe(null); // empty → null
    expect(payload.training_id).toBe('train-1');
    expect(payload.module_id).toBe(null);
    expect(typeof payload.user_agent).toBe('string');
  });

  it('returns ok:false with error message on supabase failure', async () => {
    useAuthMock.mockReturnValue({
      user: { id: 'user-123' },
      profile: { persona: 'A' },
    });
    insertMock.mockResolvedValue({ error: { message: 'permission denied' } });

    const { result } = renderHook(() => useFeedback());

    let outcome: { ok: boolean; error?: string } = { ok: true };
    await act(async () => {
      outcome = await result.current.submit({
        category: 'other',
        rating: 4,
        context_page: '/profile',
      });
    });

    expect(outcome.ok).toBe(false);
    if (!outcome.ok) {
      expect(outcome.error).toBe('permission denied');
    }
  });
});
