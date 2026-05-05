import type { DcResults, DcSection } from '@/types/observation';

export function subjectToShortcode(subject: string): string {
  const s = subject.toLowerCase();
  if (s.includes('math') || s.includes('numeracy')) return 'Math';
  if (s.includes('english') || s.includes('literacy') || s.includes('reading')) return 'Eng';
  if (s.includes('urdu')) return 'Urdu';
  if (s.includes('science')) return 'Sci';
  if (s.includes('social') || s.includes('studies')) return 'SST';
  return subject.substring(0, 4);
}

export type DcScoreValue = 'yes' | 'partial' | 'no' | 'N/A' | 'UNABLE_TO_DETECT';

export function scoreBadgeClass(score: DcScoreValue | string): string {
  switch (score) {
    case 'yes':              return 'bg-green-100 text-green-700 border-green-300';
    case 'partial':          return 'bg-yellow-100 text-yellow-700 border-yellow-300';
    case 'no':               return 'bg-red-100 text-red-700 border-red-300';
    case 'N/A':              return 'bg-gray-100 text-gray-500 border-gray-200';
    case 'UNABLE_TO_DETECT': return 'bg-muted text-muted-foreground border-border';
    default:                 return 'bg-muted text-muted-foreground border-border';
  }
}

export function scoreLabel(score: DcScoreValue | string): string {
  if (score === 'UNABLE_TO_DETECT') return 'Unable to detect';
  return score;
}

export function sectionLabel(key: string): string {
  switch (key) {
    case 'section_b': return 'Section B — Structural & Pedagogical';
    case 'section_c': return 'Section C — Subject Specific';
    case 'section_d': return 'Section D — Student Engagement';
    default:          return key;
  }
}

export function dcResultsSections(results: DcResults): { key: string; label: string; section: DcSection }[] {
  return (['section_b', 'section_c', 'section_d'] as const)
    .filter(k => !!results[k])
    .map(k => ({ key: k, label: sectionLabel(k), section: results[k]! }));
}
