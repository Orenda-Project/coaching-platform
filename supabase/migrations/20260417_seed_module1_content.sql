-- Create Module 1: The Impact Cycle Foundation
INSERT INTO public.modules (title, description, is_mandatory, order_number, competencies, desired_outcomes)
VALUES (
  'Module 1: The Impact Cycle Foundation',
  'Master the fundamentals of the coaching cycle: observation, data collection, feedback, and action planning to drive teacher growth and student impact.',
  true,
  1,
  'Observation, Data Collection, Feedback, Action Planning',
  'Coaches will understand the complete coaching cycle and how each phase contributes to sustainable teacher development.'
)
ON CONFLICT DO NOTHING;

-- Create 7 training units for Module 1
INSERT INTO public.trainings (title, description, order_number, is_common)
SELECT
  units.title,
  units.description,
  units.order_num,
  true
FROM (
  SELECT 'Unit 1.0: The Impact Cycle Overview' AS title, 'Understand the 4-phase coaching cycle and its role in teacher development' AS description, 1 AS order_num
  UNION ALL SELECT 'Unit 1.1: Observation & Data Collection', 'Learn systematic observation techniques and how to capture objective classroom data', 2
  UNION ALL SELECT 'Unit 1.2: The Calibration Process', 'Develop shared understanding between coach and teacher through data-based dialogue', 3
  UNION ALL SELECT 'Unit 1.3: Feedback with Empathy', 'Master the art of delivering feedback that builds trust and motivates change', 4
  UNION ALL SELECT 'Unit 1.4: Co-Designing Action Steps', 'Partner with teachers to create realistic, actionable improvement plans', 5
  UNION ALL SELECT 'Unit 1.5: Documentation & Follow-up', 'Track progress and maintain continuity across coaching visits', 6
  UNION ALL SELECT 'Unit 1.6: Building Habits & Mastery', 'Support teachers in making new practices automatic through deliberate practice', 7
) AS units
ON CONFLICT DO NOTHING;

-- Add content slides for each training unit
INSERT INTO public.training_content (training_id, format_type, content_url)
SELECT
  t.id,
  'slide',
  'https://docs.google.com/presentation/d/' || CASE t.order_number
    WHEN 1 THEN '1impact_cycle_overview_slides'
    WHEN 2 THEN '1observation_data_collection_slides'
    WHEN 3 THEN '1calibration_process_slides'
    WHEN 4 THEN '1feedback_empathy_slides'
    WHEN 5 THEN '1codesign_action_steps_slides'
    WHEN 6 THEN '1documentation_followup_slides'
    WHEN 7 THEN '1building_habits_mastery_slides'
  END || '/edit?usp=sharing'
FROM public.trainings t
WHERE t.title LIKE 'Unit 1.%'
AND NOT EXISTS (
  SELECT 1 FROM public.training_content
  WHERE training_id = t.id
);
