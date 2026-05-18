-- First, ensure all sub-regions exist in profiles (if sub_region column exists)
-- These are the unique sub-regions from the teacher data

INSERT INTO public.teacher_dc_scores (
  teacher_name, school_name, region, subject, grade, 
  framework, total_score, proficiency_level, scored_at, raw_results
) VALUES
  -- BK region teachers
  ('Nadeema bibi', 'IMSG (I-VIII), BOBRI', 'B.K', 'Maths', '2', 'FICO', 38, 'Proficient', '2026-01-27'::DATE, '{"accurate_lesson_planning": 3.0, "timely_lesson_delivery": 2.0, "subject_command": 3.0, "effective_pedagogy": 3.2, "effective_resource_use": 4.0, "activity_based_learning": 2.0, "student_participation": 3.5, "critical_thinking": 0.0, "inclusive_practices": 3.0, "technology_integration": 4.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "non_verbal_communication": 4.0, "overall_percentage": 73.78205128205128}'::JSONB),
  
  -- Urban-II region teachers
  ('Rehana Aftab', 'IMS(I-V) No.2 G-9/2', 'Urban-II', 'Eng', '2', 'FICO', 38, 'Proficient', '2025-12-17'::DATE, '{"accurate_lesson_planning": 4.0, "timely_lesson_delivery": 3.0, "subject_command": 3.0, "effective_pedagogy": 3.2, "effective_resource_use": 4.0, "activity_based_learning": 2.0, "student_participation": 1.5, "critical_thinking": 0.0, "inclusive_practices": 3.0, "technology_integration": 4.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "non_verbal_communication": 4.0, "overall_percentage": 73.78205128205128}'::JSONB),
  ('Benazir', 'IMSG (I-VIII) I-9/4', 'Urban-II', 'Urdu', '1', 'FICO', 39, 'Proficient', '2026-01-20'::DATE, '{"accurate_lesson_planning": 4.0, "timely_lesson_delivery": 4.0, "subject_command": 3.0, "effective_pedagogy": 3.2, "effective_resource_use": 4.0, "activity_based_learning": 2.0, "student_participation": 1.5, "critical_thinking": 0.0, "inclusive_practices": 3.0, "technology_integration": 4.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "non_verbal_communication": 4.0, "overall_percentage": 75.7051282051282}'::JSONB),
  ('Samina Sheikh', 'IMSG (I-VIII) I-9/4', 'Urban-II', 'Maths', '5', 'FICO', 41, 'Proficient', '2026-02-10'::DATE, '{"accurate_lesson_planning": 4.0, "timely_lesson_delivery": 4.0, "subject_command": 3.0, "effective_pedagogy": 3.2, "effective_resource_use": 4.0, "activity_based_learning": 2.0, "student_participation": 1.5, "critical_thinking": 1.3333333333333333, "inclusive_practices": 3.0, "technology_integration": 4.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "non_verbal_communication": 4.0, "overall_percentage": 78.26923076923076}'::JSONB)
ON CONFLICT DO NOTHING;
