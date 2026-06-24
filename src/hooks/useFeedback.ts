import { useAuth } from '@/contexts/AuthContext';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

export type FeedbackCategory = 'module' | 'platform' | 'bug' | 'other';

export type SubmitFeedbackInput = {
  category: FeedbackCategory;
  rating: number; // 1-5
  positive_feedback?: string;
  improvement_feedback?: string;
  context_page: string;
  module_id?: string | null;
  training_id?: string | null;
};

export type SubmitFeedbackResult =
  | { ok: true }
  | { ok: false; error: string };

export function useFeedback() {
  const { user, profile } = useAuth();

  const submit = async (
    input: SubmitFeedbackInput,
  ): Promise<SubmitFeedbackResult> => {
    if (!user) return { ok: false, error: 'Not authenticated' };

    const payload = {
      user_id: user.id,
      category: input.category,
      rating: input.rating,
      positive_feedback: input.positive_feedback?.trim() || null,
      improvement_feedback: input.improvement_feedback?.trim() || null,
      context_page: input.context_page,
      module_id: input.module_id ?? null,
      training_id: input.training_id ?? null,
      persona: profile?.persona ?? null,
      user_agent: (typeof navigator !== 'undefined' ? navigator.userAgent : '').slice(0, 500),
    };

    try {
      const res = await fetch(`${API_URL}/api/admin/feedback`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!res.ok) {
        const errData = await res.text();
        console.error('[feedback] insert failed', res.status, errData);
        return { ok: false, error: `Failed to submit feedback (${res.status})` };
      }
      return { ok: true };
    } catch (err) {
      console.error('[feedback] network error', err);
      return { ok: false, error: 'Network error submitting feedback' };
    }
  };

  return { submit };
}
