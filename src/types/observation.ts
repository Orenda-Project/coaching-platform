/* eslint-disable @typescript-eslint/no-explicit-any */

export type ObservationStatus = 'Scheduled' | 'Draft' | 'Submitted' | 'Approved';

export interface DcIndicatorDetail {
  full_statement: string;
  is_lp_followed: boolean | null;
}
export interface DcSection {
  indicator_details: Record<string, DcIndicatorDetail>;
  scores: Record<string, 'yes' | 'partial' | 'no' | 'N/A' | 'UNABLE_TO_DETECT'>;
  feedback: { english: string };
}
export interface DcResults {
  section_b?: DcSection;
  section_c?: DcSection;
  section_d?: DcSection;
}

export interface NeoResults {
  overall_score: number;
  grade: 'A' | 'B' | 'C' | 'D' | 'F';
  readiness_level: string;
  section_scores: { A: number; B: number; C: number; D: number; E: number };
  conversation_metrics?: Record<string, any>;
  observer_feedback?: Record<string, any>;
}

export interface HotsScores {
  criticalThinking: number;
  studentEngagement: number;
  useOfResources: number;
  classroomManagement: number;
  communicationSkills: number;
  assessmentFeedback: number;
}

export interface CotObservation {
  id: string;
  observer_id: string;
  school_name: string;
  teacher_name: string;
  region: string;
  subject: string;
  grade: string;
  topic?: string | null;
  date: string;
  total_score: number;
  proficiency_level?: string | null;
  hots_rubric: HotsScores | Record<string, never>;
  fico_rubric?: Record<string, any>;
  framework?: 'HOTS' | 'FICO';
  dc_task_id?: string | null;
  dc_status?: 'processing' | 'completed' | 'failed' | null;
  dc_requested_at?: string | null;
  dc_completed_at?: string | null;
  dc_results?: DcResults | null;
  dc_error?: string | null;
  dc_audio_s3_key?: string | null;
  hots_notes?: string | null;
  notes_for_teacher?: string | null;
  neo_status?: 'processing' | 'completed' | 'failed' | null;
  neo_task_id?: string | null;
  neo_requested_at?: string | null;
  neo_completed_at?: string | null;
  neo_results?: NeoResults | null;
  neo_error?: string | null;
  status: ObservationStatus;
  submitted_at?: string | null;
  approved_at?: string | null;
  visit_purpose?: string | null;
  created_at: string;
  updated_at: string;
}

export interface TeacherDcScore {
  id: string;
  observer_id: string;
  teacher_name: string;
  school_name: string;
  region: string;
  subject?: string | null;
  grade?: string | null;
  framework: string;
  total_score: number;
  proficiency_level?: string | null;
  scored_at: string;
  raw_results?: Record<string, any> | null;
  created_at: string;
}

export interface ScheduleFormData {
  school_name: string;
  teacher_name: string;
  subject: string;
  grade: string;
  topic: string;
  date: string;
}

export interface ScheduleVisitFormData {
  date: string;
  visit_purpose: string;
  lesson_topic?: string;
}
