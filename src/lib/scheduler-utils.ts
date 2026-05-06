import { CotObservation, TeacherDcScore } from '@/types/observation';

export type PriorityTier = 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW';

export interface TeacherWithScore {
  teacher_name: string;
  school_name: string;
  region: string;
  latestScore: number | null;
  lastVisitDate: Date | null;
  neverObserved: boolean;
  scoreTrend: 'falling' | 'flat' | 'improving' | null;
}

export interface RankedTeacher extends TeacherWithScore {
  tier: PriorityTier;
  urgency: number;
  visitInterval: number; // days
}

export interface ScheduledVisit {
  teacher_name: string;
  school_name: string;
  date: Date;
  dayOfWeek: string;
  tier: PriorityTier;
  purpose: string;
  urgency: number;
}

// Priority tier assignment based on score thresholds
export function assignPriorityTier(
  score: number | null,
  neverObserved: boolean
): PriorityTier {
  if (neverObserved || score === null || score < 40) return 'CRITICAL';
  if (score < 60) return 'HIGH';
  if (score < 75) return 'MEDIUM';
  return 'LOW';
}

// Visit frequency in days based on tier
export function getVisitInterval(tier: PriorityTier): number {
  const intervals: Record<PriorityTier, number> = {
    CRITICAL: 7,
    HIGH: 14,
    MEDIUM: 21,
    LOW: 30,
  };
  return intervals[tier];
}

// Determine score trend by comparing last two observations
export function getScoreTrend(
  currentScore: number | null,
  previousScore: number | null
): 'falling' | 'flat' | 'improving' | null {
  if (currentScore === null || previousScore === null) return null;
  if (currentScore < previousScore - 5) return 'falling';
  if (currentScore > previousScore + 5) return 'improving';
  return 'flat';
}

// Calculate days overdue for a teacher (days past their scheduled interval)
export function calculateDaysOverdue(
  lastVisitDate: Date | null,
  visitInterval: number,
  today: Date = new Date()
): number {
  if (!lastVisitDate) return 0;
  const daysSinceLastVisit = Math.floor(
    (today.getTime() - lastVisitDate.getTime()) / (1000 * 60 * 60 * 24)
  );
  return Math.max(0, daysSinceLastVisit - visitInterval);
}

// Compute urgency score: higher = more urgent
export function calculateUrgency(
  neverObserved: boolean,
  daysOverdue: number,
  scoreTrend: 'falling' | 'flat' | 'improving' | null
): number {
  if (neverObserved) return 9999; // Always top priority
  let urgency = daysOverdue;
  if (scoreTrend === 'falling') urgency += 10;
  if (scoreTrend === 'improving') urgency -= 5;
  return Math.max(0, urgency);
}

// Rank all teachers by urgency
export function rankTeachersByUrgency(
  roster: TeacherWithScore[],
  today: Date = new Date()
): RankedTeacher[] {
  return roster
    .map((teacher) => {
      const tier = assignPriorityTier(teacher.latestScore, teacher.neverObserved);
      const visitInterval = getVisitInterval(tier);
      const daysOverdue = calculateDaysOverdue(teacher.lastVisitDate, visitInterval, today);
      const urgency = calculateUrgency(
        teacher.neverObserved,
        daysOverdue,
        teacher.scoreTrend
      );
      return {
        ...teacher,
        tier,
        visitInterval,
        urgency,
      };
    })
    .sort((a, b) => b.urgency - a.urgency); // Sort descending by urgency
}

// Group teachers by school for clustering
function groupBySchool(teachers: RankedTeacher[]): Map<string, RankedTeacher[]> {
  const grouped = new Map<string, RankedTeacher[]>();
  teachers.forEach((teacher) => {
    if (!grouped.has(teacher.school_name)) {
      grouped.set(teacher.school_name, []);
    }
    grouped.get(teacher.school_name)!.push(teacher);
  });
  return grouped;
}

// Build weekly schedule: fill 8 slots (2/day, Mon–Fri), cluster by school
export function generateWeeklySchedule(
  rankedTeachers: RankedTeacher[],
  startDate: Date = new Date(),
  maxVisitsPerDay: number = 2,
  workingDays: number = 5
): { scheduled: ScheduledVisit[]; overflow: RankedTeacher[] } {
  const maxVisitsPerWeek = maxVisitsPerDay * workingDays; // 10 slots available
  const scheduled: ScheduledVisit[] = [];
  const used = new Set<string>();

  // Get working days (Mon–Fri) starting from the startDate
  const workingDatesList: Date[] = [];
  const current = new Date(startDate);

  // Find next Monday if needed
  const dayOfWeek = current.getDay();
  if (dayOfWeek !== 1) {
    current.setDate(current.getDate() + ((1 - dayOfWeek + 7) % 7));
  }

  for (let i = 0; i < workingDays; i++) {
    workingDatesList.push(new Date(current));
    current.setDate(current.getDate() + 1);
  }

  // Group by school to enable clustering
  const schoolGroups = groupBySchool(rankedTeachers);
  const schoolOrder = Array.from(schoolGroups.keys());

  let dayIndex = 0;
  let visitsOnCurrentDay = 0;

  for (const school of schoolOrder) {
    const teachersAtSchool = schoolGroups.get(school)!;

    for (const teacher of teachersAtSchool) {
      if (scheduled.length >= maxVisitsPerWeek) break;

      // If we've hit the day limit, move to next day
      if (visitsOnCurrentDay >= maxVisitsPerDay) {
        dayIndex++;
        visitsOnCurrentDay = 0;
      }

      if (dayIndex >= workingDatesList.length) break;

      const visitDate = workingDatesList[dayIndex];
      const dayName = visitDate.toLocaleDateString('en-US', { weekday: 'long' });

      scheduled.push({
        teacher_name: teacher.teacher_name,
        school_name: teacher.school_name,
        date: visitDate,
        dayOfWeek: dayName,
        tier: teacher.tier,
        purpose: getPurposeForTier(teacher.tier, teacher.neverObserved),
        urgency: teacher.urgency,
      });

      used.add(`${teacher.teacher_name}-${teacher.school_name}`);
      visitsOnCurrentDay++;
    }
  }

  // Collect overflow (teachers not scheduled this week)
  const overflow = rankedTeachers.filter(
    (t) => !used.has(`${t.teacher_name}-${t.school_name}`)
  );

  return { scheduled, overflow };
}

// Purpose statement based on tier and observation status
function getPurposeForTier(tier: PriorityTier, neverObserved: boolean): string {
  if (neverObserved) return 'Baseline observation';
  const purposes: Record<PriorityTier, string> = {
    CRITICAL: 'Urgent support needed',
    HIGH: 'Active support',
    MEDIUM: 'Monitoring',
    LOW: 'Check-in',
  };
  return purposes[tier];
}

// Generate 4-week plan by calling generateWeeklySchedule 4 times
export function generateFourWeekPlan(
  rankedTeachers: RankedTeacher[],
  startDate: Date = new Date()
): ScheduledVisit[] {
  const allScheduled: ScheduledVisit[] = [];
  let remaining = rankedTeachers;
  const currentDate = new Date(startDate);

  for (let week = 0; week < 4; week++) {
    const { scheduled, overflow } = generateWeeklySchedule(remaining, currentDate);
    allScheduled.push(...scheduled);
    remaining = overflow;

    // Move to next Monday
    currentDate.setDate(currentDate.getDate() + 7);
  }

  return allScheduled;
}

// Detect if a teacher's priority tier has changed since last plan run
export function detectTierChange(
  oldTier: PriorityTier | null,
  newTier: PriorityTier
): boolean {
  if (!oldTier) return false;
  return oldTier !== newTier;
}

// Normalize raw score to 0–100 percentage based on framework
export function normalizeScore(score: number, framework: string): number {
  const max = framework === 'FICO' ? 100 : 80;
  return Math.round((score / max) * 100);
}

// Build roster from teacher_dc_scores + cot_observations (new primary path)
export function buildRosterFromDcScores(
  dcScores: TeacherDcScore[],
  visits: Pick<CotObservation, 'teacher_name' | 'school_name' | 'submitted_at' | 'status'>[]
): TeacherWithScore[] {
  // Group dc scores per teacher+school, ordered newest first
  const scoreMap = new Map<string, TeacherDcScore[]>();
  for (const s of dcScores) {
    const key = `${s.teacher_name}||${s.school_name}`;
    if (!scoreMap.has(key)) scoreMap.set(key, []);
    scoreMap.get(key)!.push(s);
  }

  // Last-visit lookup from submitted observations
  const lastVisitMap = new Map<string, Date>();
  for (const v of visits) {
    const key = `${v.teacher_name}||${v.school_name}`;
    if (!lastVisitMap.has(key) && v.submitted_at) {
      lastVisitMap.set(key, new Date(v.submitted_at));
    }
  }

  const result: TeacherWithScore[] = [];
  for (const [key, scores] of scoreMap.entries()) {
    const latest = scores[0];
    const latestNorm = normalizeScore(latest.total_score, latest.framework);
    const prevNorm = scores[1] ? normalizeScore(scores[1].total_score, scores[1].framework) : null;
    const scoreTrend = getScoreTrend(latestNorm, prevNorm);
    const lastVisitDate = lastVisitMap.get(key) ?? null;
    const neverObserved = !lastVisitDate;

    result.push({
      teacher_name: latest.teacher_name,
      school_name: latest.school_name,
      region: latest.region,
      latestScore: latestNorm,
      lastVisitDate,
      neverObserved,
      scoreTrend,
    });
  }

  return result;
}

// Build a roster with latest scores from observations
export function buildTeacherRosterWithScores(
  rosterRows: Array<{ teacher_name: string; school_name: string; region?: string }>,
  observations: CotObservation[]
): TeacherWithScore[] {
  return rosterRows.map((teacher) => {
    // Get all observations for this teacher (submitted or approved)
    const teacherObservations = observations.filter(
      (obs) =>
        obs.teacher_name === teacher.teacher_name &&
        obs.school_name === teacher.school_name &&
        (obs.status === 'Submitted' || obs.status === 'Approved')
    );

    const neverObserved = teacherObservations.length === 0;
    const latestScore = neverObserved ? null : teacherObservations[0].total_score ?? null;
    const lastVisitDate = neverObserved ? null : teacherObservations[0].date ? new Date(teacherObservations[0].date) : null;

    // Score trend: compare last two observations
    let scoreTrend: 'falling' | 'flat' | 'improving' | null = null;
    if (teacherObservations.length >= 2) {
      const current = teacherObservations[0].total_score;
      const previous = teacherObservations[1].total_score;
      if (current !== null && previous !== null) {
        scoreTrend = getScoreTrend(current, previous);
      }
    }

    return {
      teacher_name: teacher.teacher_name,
      school_name: teacher.school_name,
      region: teacher.region ?? '',
      latestScore,
      lastVisitDate,
      neverObserved,
      scoreTrend,
    };
  });
}
