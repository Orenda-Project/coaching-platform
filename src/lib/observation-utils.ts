import type { HotsScores } from '@/types/observation';

export interface ProficiencyInfo {
  level: string;
  color: string;
  bgColor: string;
  borderColor: string;
  barColor: string;
  percentage: number;
}

export function getProficiencyLevel(score: number): ProficiencyInfo {
  const percentage = Math.round((score / 80) * 100);
  if (score <= 40) return {
    level: 'Below Basic',
    color: 'text-red-600',
    bgColor: 'bg-red-50',
    borderColor: 'border-red-200',
    barColor: 'bg-red-400',
    percentage,
  };
  if (score <= 60) return {
    level: 'Basic',
    color: 'text-yellow-600',
    bgColor: 'bg-yellow-50',
    borderColor: 'border-yellow-200',
    barColor: 'bg-yellow-400',
    percentage,
  };
  if (score <= 75) return {
    level: 'Proficient',
    color: 'text-green-600',
    bgColor: 'bg-green-50',
    borderColor: 'border-green-200',
    barColor: 'bg-green-500',
    percentage,
  };
  return {
    level: 'Advanced',
    color: 'text-emerald-700',
    bgColor: 'bg-emerald-50',
    borderColor: 'border-emerald-200',
    barColor: 'bg-emerald-500',
    percentage,
  };
}

export const HOTS_DIMENSIONS: {
  key: keyof HotsScores;
  label: string;
  max: number;
  description: string;
}[] = [
  {
    key: 'criticalThinking',
    label: 'Critical Thinking',
    max: 10,
    description: 'Teacher promotes analysis, evaluation and synthesis of ideas',
  },
  {
    key: 'studentEngagement',
    label: 'Student Engagement',
    max: 10,
    description: 'Level of student participation and active involvement',
  },
  {
    key: 'useOfResources',
    label: 'Use of Resources',
    max: 10,
    description: 'Effective use of teaching materials, technology and tools',
  },
  {
    key: 'classroomManagement',
    label: 'Classroom Management',
    max: 10,
    description: 'Maintaining a productive and supportive learning environment',
  },
  {
    key: 'communicationSkills',
    label: 'Communication Skills',
    max: 10,
    description: 'Clarity of instruction, questioning and effective communication',
  },
  {
    key: 'assessmentFeedback',
    label: 'Assessment & Feedback',
    max: 20,
    description: 'Quality and frequency of formative assessment and feedback',
  },
];

export const DEFAULT_HOTS_SCORES: HotsScores = {
  criticalThinking: 0,
  studentEngagement: 0,
  useOfResources: 0,
  classroomManagement: 0,
  communicationSkills: 0,
  assessmentFeedback: 0,
};

export function calculateTotalScore(scores: HotsScores): number {
  return Object.values(scores).reduce((a, b) => a + b, 0);
}

export const SUBJECTS = [
  'English',
  'Urdu',
  'Mathematics',
  'Science',
  'Social Studies',
  'Islamic Studies',
  'Computer Science',
  'General Knowledge',
  'Other',
];

export const GRADES = [
  'Nursery',
  'KG',
  'Class 1',
  'Class 2',
  'Class 3',
  'Class 4',
  'Class 5',
  'Class 6',
  'Class 7',
  'Class 8',
  'Class 9',
  'Class 10',
];

export function formatObservationDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString('en-US', {
    weekday: 'short',
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
}

export function formatObservationTime(dateStr: string): string {
  return new Date(dateStr).toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
  });
}
