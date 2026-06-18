-- Migration 004: Create user_feedback table
-- This table stores user-submitted feedback (ratings, comments).
-- The existing "feedback" table in Supabase contains training data, not user feedback,
-- so we create a dedicated table here.

CREATE TABLE IF NOT EXISTS user_feedback (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category    VARCHAR(50) NOT NULL DEFAULT 'other',
    rating      INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    positive_feedback   TEXT,
    improvement_feedback TEXT,
    context_page VARCHAR(255),
    module_id   UUID,
    training_id UUID,
    persona     VARCHAR(10),
    user_agent  VARCHAR(500),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_feedback_user_id ON user_feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_user_feedback_category ON user_feedback(category);
CREATE INDEX IF NOT EXISTS idx_user_feedback_created_at ON user_feedback(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_feedback_rating ON user_feedback(rating);
