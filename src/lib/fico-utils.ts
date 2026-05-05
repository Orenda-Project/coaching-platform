export type FicoScore = 'yes' | 'partial' | 'no' | 'na';
export type MathType = 'C' | 'PA';

export const SCORE_VALUE: Record<FicoScore, number | null> = {
  yes: 1,
  partial: 0.5,
  no: 0,
  na: null,
};

// ── Section B ────────────────────────────────────────────────────────────────
export const SECTION_B = [
  {
    code: 'SI4',
    label: 'Effective Resource Use',
    desc: 'Teacher uses a variety of materials that actively support student learning — not just materials present in the classroom.',
  },
  {
    code: 'SI5',
    label: 'Productive Learning Time',
    desc: 'Teacher manages lesson time efficiently — transitions smooth, instructions clear, minimal idle time.',
  },
  {
    code: 'SI6',
    label: 'Classroom Management',
    desc: 'Teacher proactively manages student behavior and handles disruptions respectfully, maintaining productive learning.',
  },
  {
    code: 'PIC6',
    label: 'Positive & Supportive Disposition',
    desc: 'Teacher uses positive, encouraging language and demonstrates patience and warmth through words and body language.',
  },
  {
    code: 'PIC7',
    label: 'Equitable Interactions',
    desc: 'Teacher distributes speaking opportunities fairly across all students — no pattern of favoritism.',
  },
] as const;

// ── Section C — Subject Specific ─────────────────────────────────────────────
export const MATH_C = [
  {
    code: 'M3C',
    label: 'Use of Concrete / Proxy Materials',
    desc: 'Students actively use physical materials (formal or proxy) to represent and explore mathematical concepts.',
  },
  {
    code: 'M4C',
    label: 'CPA Progression — Concrete Phase',
    desc: 'Teacher delivers concrete stage purposefully with a verbal or visual bridge signposting toward the representational stage.',
  },
] as const;

export const MATH_PA = [
  {
    code: 'M3PA',
    label: 'Pictorial / Representational Stage',
    desc: 'Teacher uses visual models meaningfully — students actively engage with representations rather than passively observing.',
  },
  {
    code: 'M4PA',
    label: 'Abstract / Numerical Stage',
    desc: 'Students engage with symbolic work that is conceptually grounded — they understand what they compute and why.',
  },
] as const;

export const SCIENCE_C = [
  {
    code: 'S3',
    label: 'Hands-On or Minds-On Participation',
    desc: '70%+ students physically or cognitively active with science content — producing something observable.',
  },
  {
    code: 'S4',
    label: 'Concrete Anchoring of Concepts',
    desc: 'Teacher grounds the concept in something visible — real object, diagram, picture, or demonstration.',
  },
] as const;

export const LITERACY_C = [
  {
    code: 'L4',
    label: 'Interactive Reading & Text Engagement',
    desc: 'Text accessible to all students; 70%+ visibly engaged with print; teacher actively supports tracking.',
  },
] as const;

// ── Section D — Evidence Markers (not scored independently) ──────────────────
export const SECTION_D = [
  { code: 'SE1', label: 'Initial Engagement & Learning Readiness', desc: 'Students exhibit inquisitive attitude and actively participate at the start of lesson.' },
  { code: 'SE2', label: 'Instructional Understanding', desc: 'Students follow the explanation and engage through questions, responses, or gestures.' },
  { code: 'SE3', label: 'Productive Group Collaboration', desc: 'Students are discussing, collaborating, and solving tasks with peers or in groups.' },
  { code: 'SE4', label: 'On-Task Independent Work', desc: 'Students are working independently, staying on task, and completing assigned work.' },
  { code: 'SE5', label: 'Student Reflection and Closure Engagement', desc: 'Students summarizing key takeaways or engaging in wrap-up activities.' },
  { code: 'SE6', label: 'Higher-Order Student Questioning', desc: 'Students independently ask open-ended why/how/what-if questions showing curiosity.' },
] as const;

// ── Types ────────────────────────────────────────────────────────────────────
export interface FicoSectionB {
  SI4?: FicoScore;
  SI5?: FicoScore;
  SI6?: FicoScore;
  PIC6?: FicoScore;
  PIC7?: FicoScore;
}

export interface FicoSectionC {
  math_type?: MathType;
  M3C?: FicoScore;
  M4C?: FicoScore;
  M3PA?: FicoScore;
  M4PA?: FicoScore;
  S3?: FicoScore;
  S4?: FicoScore;
  L4?: FicoScore;
}

export interface FicoSectionD {
  SE1?: FicoScore;
  SE2?: FicoScore;
  SE3?: FicoScore;
  SE4?: FicoScore;
  SE5?: FicoScore;
  SE6?: FicoScore;
}

export interface FicoStudentSample {
  q1: boolean | null;
  q2: boolean | null;
  q3: boolean | null;
}

export interface FicoRubric {
  section_b: FicoSectionB;
  section_c: FicoSectionC;
  section_d: FicoSectionD;
  section_e: FicoStudentSample[];
}

export const DEFAULT_FICO_RUBRIC: FicoRubric = {
  section_b: {},
  section_c: {},
  section_d: {},
  section_e: [
    { q1: null, q2: null, q3: null },
    { q1: null, q2: null, q3: null },
    { q1: null, q2: null, q3: null },
    { q1: null, q2: null, q3: null },
    { q1: null, q2: null, q3: null },
  ],
};

// ── Helpers ──────────────────────────────────────────────────────────────────
export function isRegionFico(region: string): boolean {
  const r = region.toLowerCase();
  return r.includes('ict') || r.includes('islamabad');
}

export type SubjectCategory = 'math' | 'science' | 'literacy' | 'other';

export function getSubjectCategory(subject: string): SubjectCategory {
  const s = subject.toLowerCase();
  if (s.includes('math') || s.includes('numeracy') || s.includes('arithmetic')) return 'math';
  if (s.includes('science') || s.includes('biology') || s.includes('chemistry') || s.includes('physics')) return 'science';
  if (s.includes('english') || s.includes('literacy') || s.includes('urdu') || s.includes('reading') || s.includes('language')) return 'literacy';
  return 'other';
}

export interface FicoScoreResult {
  sectionBEarned: number;
  sectionBMax: number;
  sectionCEarned: number;
  sectionCMax: number;
  totalEarned: number;
  totalMax: number;
  percentage: number;
}

function scoreVal(v: FicoScore | undefined): number {
  if (!v || v === 'na') return 0;
  return SCORE_VALUE[v] ?? 0;
}

export function calculateFicoScore(rubric: FicoRubric, subject: string): FicoScoreResult {
  // Section B — always 5 indicators, max 5
  const b = rubric.section_b ?? {};
  const sectionBEarned =
    scoreVal(b.SI4) + scoreVal(b.SI5) + scoreVal(b.SI6) + scoreVal(b.PIC6) + scoreVal(b.PIC7);
  const sectionBMax = 5;

  // Section C — depends on subject
  const c = rubric.section_c ?? {};
  let sectionCEarned = 0;
  let sectionCMax = 0;
  const cat = getSubjectCategory(subject);

  if (cat === 'math') {
    if (c.math_type === 'C') {
      sectionCMax = 2;
      sectionCEarned = scoreVal(c.M3C) + scoreVal(c.M4C);
    } else if (c.math_type === 'PA') {
      sectionCMax = 2;
      sectionCEarned = scoreVal(c.M3PA) + scoreVal(c.M4PA);
    }
  } else if (cat === 'science') {
    sectionCMax = 2;
    sectionCEarned = scoreVal(c.S3) + scoreVal(c.S4);
  } else if (cat === 'literacy') {
    sectionCMax = 1;
    sectionCEarned = scoreVal(c.L4);
  }

  const totalEarned = sectionBEarned + sectionCEarned;
  const totalMax = sectionBMax + sectionCMax;
  const percentage = totalMax > 0 ? Math.round((totalEarned / totalMax) * 100) : 0;

  return { sectionBEarned, sectionBMax, sectionCEarned, sectionCMax, totalEarned, totalMax, percentage };
}

export interface FicoProficiency {
  level: string;
  color: string;
  bgColor: string;
  borderColor: string;
  barColor: string;
}

export function getFicoProficiency(percentage: number): FicoProficiency {
  if (percentage >= 85) return { level: 'Advanced', color: 'text-emerald-700', bgColor: 'bg-emerald-50', borderColor: 'border-emerald-200', barColor: 'bg-emerald-500' };
  if (percentage >= 70) return { level: 'Proficient', color: 'text-green-700', bgColor: 'bg-green-50', borderColor: 'border-green-200', barColor: 'bg-green-500' };
  if (percentage >= 50) return { level: 'Basic', color: 'text-yellow-700', bgColor: 'bg-yellow-50', borderColor: 'border-yellow-200', barColor: 'bg-yellow-500' };
  return { level: 'Below Basic', color: 'text-red-700', bgColor: 'bg-red-50', borderColor: 'border-red-200', barColor: 'bg-red-500' };
}

export function isFicoSectionBComplete(rubric: FicoRubric): boolean {
  const b = rubric.section_b ?? {};
  return !!(b.SI4 && b.SI5 && b.SI6 && b.PIC6 && b.PIC7);
}
