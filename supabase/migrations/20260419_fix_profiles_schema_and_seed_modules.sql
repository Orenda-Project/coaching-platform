-- ─────────────────────────────────────────────────────────────────────────────
-- Fix: Add missing columns to profiles + seed Modules 2-6
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. Add missing columns to profiles table
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS weak_modules TEXT[] NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS school_id TEXT,
  ADD COLUMN IF NOT EXISTS region TEXT,
  ADD COLUMN IF NOT EXISTS teacher_ids TEXT[] DEFAULT '{}';

-- 2. Seed Modules 2-6 (with titles that match what Assessment.tsx expects in moduleBands keys)
-- Only insert if they don't already exist by checking order_number
INSERT INTO public.modules (title, description, is_mandatory, order_number, competencies, desired_outcomes)
SELECT * FROM (
  VALUES
    ('Module 2: The Partnership Foundation', 'Build trust and psychological safety in coaching relationships. Learn status threat dynamics, deep empathy, and co-created SMART goals.', false, 2, 'Trust & Status', 'Coaches establish partnership through equality, choice, and voice. Teachers own their growth goals.'),
    ('Module 3: The Mirror Specialist', 'Master low-inference observation and calibration. Learn artifact validation through photos/audio and neutral data presentation.', false, 3, 'Shared Reality', 'Coaches present objective data as mirrors. Teachers develop their own interpretations and solutions.'),
    ('Module 4: Digital & Data Intelligence', 'Leverage digital tools and dashboards as coaching accelerators. Understand WRER tracking and data-as-third-person principle.', false, 4, 'WRER & Data', 'Coaches integrate digital evidence into feedback. Teachers become data-literate about their practice.'),
    ('Module 5: The Instructional Catalyst', 'Master micro-skill isolation, pedagogical root-cause analysis, and side-by-side co-modeling. Apply the 3 Loops framework.', false, 5, 'Co-Design', 'Coaches facilitate teacher-owned instructional problem-solving. Teachers apply micro-skills to real classroom contexts.'),
    ('Module 6: The Excellence Loop', 'Complete the coaching cycle through loop closure, SOP adherence, and reciprocity. Build mastery via the Mastery Technique bank.', false, 6, 'Reciprocity & Praxis', 'Coaches verify implementation and celebrate teacher ownership. Teachers build sustainable instructional habits.')
) AS t(title, description, is_mandatory, order_number, competencies, desired_outcomes)
WHERE NOT EXISTS (
  SELECT 1 FROM public.modules WHERE order_number IN (2, 3, 4, 5, 6)
);
