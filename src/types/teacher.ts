export interface DCTeacher {
  user_id: string;
  teacher_name: string;
  school: string;
  sector: string;
  overall_percentage: number;
  total_score: number;
  created_date: string;
  grade: string;
  subject: string;
  accurate_lesson_planning: number;
  timely_lesson_delivery: number;
  subject_command: number;
  effective_pedagogy: number;
  effective_resource_use: number;
  activity_based_learning: number;
  student_participation: number;
  critical_thinking: number;
  inclusive_practices: number;
  technology_integration: number;
  technology_handling: number;
  verbal_communication: number;
  non_verbal_communication: number;
  // Visit priority signals
  lastVisitDate?: Date | null;
  daysOverdue?: number;
  scoreTrend?: 'falling' | 'flat' | 'improving' | null;
  neverObserved?: boolean;
  urgency?: number;
}
