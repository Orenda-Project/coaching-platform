-- Seed DC teachers to production without requiring specific observer_id
-- This allows the data to exist regardless of which coach is logged in

INSERT INTO public.teacher_dc_scores (
  teacher_name, school_name, region, subject, grade, 
  framework, total_score, proficiency_level, scored_at, raw_results
) 
SELECT 
  teacher_name, school_name, region, subject, grade,
  framework, total_score, proficiency_level, scored_at, raw_results
FROM (VALUES
  ('Mehwish Rehman', 'IMSG(I-V)TAMMA', 'Nilore', 'Eng', '5', 'FICO', 7, 'Below Basic', '2026-01-21'::DATE, '{"subject_command": 0.0, "critical_thinking": 0.0, "effective_pedagogy": 0.0, "overall_percentage": 12.5, "inclusive_practices": 2.0, "technology_handling": 0.0, "verbal_communication": 0.0, "student_participation": 0.5, "effective_resource_use": 0.0, "technology_integration": 0.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 0.0, "non_verbal_communication": 4.0}'::JSONB),
  ('Rabia Ramzan', 'IMS(I-V) G-6/1-2', 'Urban-I', 'Maths', '5', 'FICO', 10, 'Below Basic', '2026-01-30'::DATE, '{"accurate_lesson_planning": 0.0, "timely_lesson_delivery": 0.0, "subject_command": 1.0, "effective_pedagogy": 0.8, "effective_resource_use": 0.0, "activity_based_learning": 0.0, "student_participation": 0.5, "critical_thinking": 0.0, "inclusive_practices": 1.0, "technology_integration": 0.0, "technology_handling": 0.0, "verbal_communication": 2.6666666666666665, "non_verbal_communication": 4.0, "overall_percentage": 19.166666666666668}'::JSONB),
  ('SHAHEEN AKHTAR', 'IMSG (I-V) Dhoke Suleman', 'Tarnol', 'Science', '5', 'FICO', 13, 'Below Basic', '2026-01-20'::DATE, '{"accurate_lesson_planning": 2.0, "timely_lesson_delivery": 0.0, "subject_command": 0.0, "effective_pedagogy": 0.8, "effective_resource_use": 2.0, "activity_based_learning": 0.0, "student_participation": 0.0, "critical_thinking": 0.0, "inclusive_practices": 0.0, "technology_integration": 4.0, "technology_handling": 4.0, "verbal_communication": 0.0, "non_verbal_communication": 0.0, "overall_percentage": 24.615384615384617}'::JSONB),
  ('Risfa Naveed', 'IMCG, F-7/4', 'Urban-I', 'Maths', '5', 'FICO', 15, 'Below Basic', '2025-12-17'::DATE, '{"accurate_lesson_planning": 2.0, "timely_lesson_delivery": 0.0, "subject_command": 0.0, "effective_pedagogy": 0.8, "effective_resource_use": 2.0, "activity_based_learning": 0.0, "student_participation": 0.0, "critical_thinking": 0.0, "inclusive_practices": 2.0, "technology_integration": 4.0, "technology_handling": 4.0, "verbal_communication": 0.0, "non_verbal_communication": 0.0, "overall_percentage": 28.46153846153846}'::JSONB),
  ('Samia Zakir', 'IMCB G-13/2', 'Tarnol', 'Urdu', '4', 'FICO', 22, 'Below Basic', '2026-01-21'::DATE, '{"accurate_lesson_planning": 3.0, "timely_lesson_delivery": 2.0, "subject_command": 1.0, "effective_pedagogy": 1.6, "effective_resource_use": 4.0, "activity_based_learning": 0.0, "student_participation": 0.0, "critical_thinking": 0.0, "inclusive_practices": 2.0, "technology_integration": 4.0, "technology_handling": 4.0, "verbal_communication": 0.0, "non_verbal_communication": 0.0, "overall_percentage": 41.53846153846154}'::JSONB)
) AS t(teacher_name, school_name, region, subject, grade, framework, total_score, proficiency_level, scored_at, raw_results)
WHERE NOT EXISTS (SELECT 1 FROM public.teacher_dc_scores LIMIT 1)
ON CONFLICT DO NOTHING;
