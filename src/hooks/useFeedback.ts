import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';

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

    // The `feedback` table isn't yet in the generated types.ts, so the
    // typed `from` overload rejects the literal. Runtime is correct —
    // matches migration `20260506000000_feedback_chatbot.sql`.
    // @ts-expect-error feedback table not yet present in generated types
    const { error } = await supabase.from('feedback').insert(payload);

    if (error) {
      console.error('[feedback] insert failed', error);
      return { ok: false, error: error.message };
    }
    return { ok: true };
  };

  return { submit };
}
