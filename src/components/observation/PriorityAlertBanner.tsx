import { PriorityTier } from '@/lib/scheduler-utils';
import { AlertTriangle, TrendingUp, TrendingDown } from 'lucide-react';

interface TierChange {
  teacher: string;
  school: string;
  oldTier: PriorityTier;
  newTier: PriorityTier;
}

interface Props {
  changes: TierChange[];
}

const tierLabel: Record<PriorityTier, string> = {
  CRITICAL: 'Priority Tier 1',
  HIGH: 'Priority Tier 1',
  MEDIUM: 'Priority Tier 2',
  LOW: 'Priority Tier 3',
};

function isEscalation(oldTier: PriorityTier, newTier: PriorityTier): boolean {
  const order: Record<PriorityTier, number> = { CRITICAL: 0, HIGH: 1, MEDIUM: 2, LOW: 3 };
  return order[newTier] < order[oldTier];
}

export default function PriorityAlertBanner({ changes }: Props) {
  if (changes.length === 0) return null;

  const escalations = changes.filter(c => isEscalation(c.oldTier, c.newTier));
  const improvements = changes.filter(c => !isEscalation(c.oldTier, c.newTier));

  return (
    <div className="space-y-2 mb-4">
      {escalations.length > 0 && (
        <div className="rounded-lg border border-red-200 bg-red-50 p-4">
          <div className="flex items-start gap-3">
            <AlertTriangle className="w-4 h-4 text-red-600 shrink-0 mt-0.5" />
            <div>
              <p className="text-sm font-semibold text-red-800 mb-1">
                Priority escalated — visit sooner
              </p>
              <ul className="space-y-1">
                {escalations.map((c, i) => (
                  <li key={i} className="text-xs text-red-700">
                    <strong>{c.teacher}</strong> ({c.school}) moved from{' '}
                    <span className="font-medium">{tierLabel[c.oldTier]}</span> →{' '}
                    <span className="font-semibold">{tierLabel[c.newTier]}</span>
                    <TrendingDown className="inline w-3 h-3 ml-1" />
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      )}

      {improvements.length > 0 && (
        <div className="rounded-lg border border-green-200 bg-green-50 p-4">
          <div className="flex items-start gap-3">
            <TrendingUp className="w-4 h-4 text-green-600 shrink-0 mt-0.5" />
            <div>
              <p className="text-sm font-semibold text-green-800 mb-1">
                Teachers improving — slot freed up
              </p>
              <ul className="space-y-1">
                {improvements.map((c, i) => (
                  <li key={i} className="text-xs text-green-700">
                    <strong>{c.teacher}</strong> ({c.school}) moved from{' '}
                    <span className="font-medium">{tierLabel[c.oldTier]}</span> →{' '}
                    <span className="font-semibold">{tierLabel[c.newTier]}</span>
                    <TrendingUp className="inline w-3 h-3 ml-1" />
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
