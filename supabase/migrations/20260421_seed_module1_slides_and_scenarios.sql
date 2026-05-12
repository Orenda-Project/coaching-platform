-- ─────────────────────────────────────────────────────────────────────────────
-- Seed Module 1 Slides Links and Scenario Data
-- ─────────────────────────────────────────────────────────────────────────────

-- Update slide links with real Google Slides IDs (these are placeholders — replace with production IDs)
WITH module1 AS (
  SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1
)
UPDATE public.training_content
SET content_url = CASE
  WHEN format_type = 'slide' AND training_id IN (
    SELECT t.id FROM public.trainings t, module1
    WHERE t.module_id = module1.id AND t.order_number = 1
  ) THEN 'https://docs.google.com/presentation/d/1mV2dC3fR7kL9pQ4xN8vA2bD5jE6sF4mG9tH1uI3wJ5/edit?usp=sharing'

  WHEN format_type = 'slide' AND training_id IN (
    SELECT t.id FROM public.trainings t, module1
    WHERE t.module_id = module1.id AND t.order_number = 2
  ) THEN 'https://docs.google.com/presentation/d/1nW3eD4gS8lM0rR5yO9wC3eE7kF8vG5nH0uI2xJ6zK4/edit?usp=sharing'

  WHEN format_type = 'slide' AND training_id IN (
    SELECT t.id FROM public.trainings t, module1
    WHERE t.module_id = module1.id AND t.order_number = 3
  ) THEN 'https://docs.google.com/presentation/d/1oX4fE5hT9mN1sS6zP0xD4eF8lG9wH6oI1vJ3yK7aL5/edit?usp=sharing'

  WHEN format_type = 'slide' AND training_id IN (
    SELECT t.id FROM public.trainings t, module1
    WHERE t.module_id = module1.id AND t.order_number = 4
  ) THEN 'https://docs.google.com/presentation/d/1pY5gF6iU0nO2tT7aQ1yE5fG9mH0xI7pJ2wK4zL8bM6/edit?usp=sharing'

  WHEN format_type = 'slide' AND training_id IN (
    SELECT t.id FROM public.trainings t, module1
    WHERE t.module_id = module1.id AND t.order_number = 5
  ) THEN 'https://docs.google.com/presentation/d/1qZ6hG7jV1oP3uU8bR2zF6gH0nI8qK3xL5yM9cN0dO7/edit?usp=sharing'

  WHEN format_type = 'slide' AND training_id IN (
    SELECT t.id FROM public.trainings t, module1
    WHERE t.module_id = module1.id AND t.order_number = 6
  ) THEN 'https://docs.google.com/presentation/d/1ra7iH8kW2pQ4vV9cS3aG7hI1oJ9rL4yM6zN0eO1fP8/edit?usp=sharing'

  WHEN format_type = 'slide' AND training_id IN (
    SELECT t.id FROM public.trainings t, module1
    WHERE t.module_id = module1.id AND t.order_number = 7
  ) THEN 'https://docs.google.com/presentation/d/1sb8jI9lX3qR5wW0dT4bH8iJ2pK0sM5zN7aO1fP2gQ9/edit?usp=sharing'

  ELSE content_url
END
WHERE training_id IN (
  SELECT t.id FROM public.trainings t, module1
  WHERE t.module_id = module1.id
);

-- Add scenario-based content for each Unit
-- Unit 1.0: The Impact Cycle Overview
WITH module1 AS (
  SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1
)
INSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)
SELECT
  t.id,
  'scenario',
  'scenario://module1/unit0/observation',
  jsonb_build_object(
    'title', 'Coaching Conversation: A Real Classroom Visit',
    'context', 'You are observing a Grade 2 English class. The teacher wanted to focus on student engagement during reading comprehension.',
    'scenario', 'During your observation, you notice: 50% of students are actively participating in discussions, while others are disengaged. Some students raise hands but rarely get called on. When called on, they often say "I don''t know" without attempting to answer.',
    'task', 'How would you start the post-observation conversation? What data would you present first?',
    'coaching_focus', 'Partnership and data-driven dialogue',
    'time_estimate_minutes', 45
  )
FROM public.trainings t, module1 m
WHERE t.module_id = m.id
AND t.order_number = 1
AND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario');

-- Unit 1.1: Observation & Data Collection
WITH module1 AS (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
INSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)
SELECT t.id, 'scenario', 'scenario://module1/unit1/data-collection',
  jsonb_build_object('title', 'Capturing Objective Data', 'context', 'You''re observing a math lesson on multi-digit addition. The teacher claims students "understand the concept."', 'scenario', 'As you observe: 3 students solve correctly on first attempt. 5 students solve with calculation errors. 4 students are unable to start. When you ask "How many students mastered this?", the teacher says "Most of them got it."', 'task', 'What specific, low-inference data points would you document? How does this differ from the teacher''s perception?', 'coaching_focus', 'Objective observation without judgment', 'time_estimate_minutes', 50)
FROM public.trainings t, module1 m WHERE t.module_id = m.id AND t.order_number = 2 AND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario');

-- Unit 1.2: The Calibration Process
WITH module1 AS (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
INSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)
SELECT t.id, 'scenario', 'scenario://module1/unit2/calibration',
  jsonb_build_object('title', 'When Coach and Teacher See Different Data', 'context', 'Post-observation debrief. You present data: "I counted 8 students who didn''t participate in discussion."', 'scenario', 'Teacher responds: "That''s not right. They were thinking. One of them always needs time to process." You see the teacher is defensive.', 'task', 'How do you shift from debate to shared understanding? What questions would help the teacher own the data?', 'coaching_focus', 'Calibration and building shared reality', 'time_estimate_minutes', 55)
FROM public.trainings t, module1 m WHERE t.module_id = m.id AND t.order_number = 3 AND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario');

-- Unit 1.3: Feedback with Empathy
WITH module1 AS (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
INSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)
SELECT t.id, 'scenario', 'scenario://module1/unit3/feedback-empathy',
  jsonb_build_object('title', 'Feedback That Builds Trust', 'context', 'A teacher has spent weeks planning a lesson but the execution was weak: unclear instructions, little student engagement, minimal checking for understanding.', 'scenario', 'The teacher is nervous and somewhat defensive. You have strong observational data showing learning didn''t happen. But you also see the teacher cares deeply and tried hard.', 'task', 'How do you deliver honest, data-backed feedback while preserving the teacher''s agency and motivation?', 'coaching_focus', 'Empathy-driven feedback that motivates change', 'time_estimate_minutes', 60)
FROM public.trainings t, module1 m WHERE t.module_id = m.id AND t.order_number = 4 AND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario');

-- Unit 1.4: Co-Designing Action Steps
WITH module1 AS (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
INSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)
SELECT t.id, 'scenario', 'scenario://module1/unit4/action-steps',
  jsonb_build_object('title', 'Co-Designing a Real Action Step', 'context', 'After discussing the data, the teacher says: "I guess I need to ask more questions." But this is vague and doesn''t feel owned.', 'scenario', 'You can see the teacher is complying, not choosing. You want to move to a concrete, measurable action step they actually want to try.', 'task', 'What questions would you ask to help the teacher co-design a specific, achievable action step? How do you shift from "I should" to "I will"?', 'coaching_focus', 'Teacher agency and SMART goal-setting', 'time_estimate_minutes', 45)
FROM public.trainings t, module1 m WHERE t.module_id = m.id AND t.order_number = 5 AND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario');

-- Unit 1.5: Documentation & Follow-up
WITH module1 AS (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
INSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)
SELECT t.id, 'scenario', 'scenario://module1/unit5/loop-closure',
  jsonb_build_object('title', 'Verifying Implementation', 'context', 'You agreed with a teacher 2 weeks ago that they would "increase cold-call opportunities during reading comprehension."', 'scenario', 'On your follow-up visit, you observe the same patterns as before: limited student participation, teacher calls on the same volunteers. The teacher looks embarrassed.', 'task', 'How do you address this loop closure? What went wrong? How do you maintain partnership while requiring accountability?', 'coaching_focus', 'Loop closure and sustained behavior change', 'time_estimate_minutes', 50)
FROM public.trainings t, module1 m WHERE t.module_id = m.id AND t.order_number = 6 AND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario');

-- Unit 1.6: Building Habits & Mastery
WITH module1 AS (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
INSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)
SELECT t.id, 'scenario', 'scenario://module1/unit6/habit-mastery',
  jsonb_build_object('title', 'From One-Time Change to Sustainable Habit', 'context', 'After 3 coaching cycles, the teacher has improved their cold-calling. But you notice they revert to old patterns under stress or time pressure.', 'scenario', 'They say: "I did it for a few weeks but it''s hard to remember every day. I fall back into old habits."', 'task', 'How do you support habit formation and mastery? What does sustained practice look like in real classrooms?', 'coaching_focus', 'Deliberate practice and habit sustainability', 'time_estimate_minutes', 55)
FROM public.trainings t, module1 m WHERE t.module_id = m.id AND t.order_number = 7 AND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario');
