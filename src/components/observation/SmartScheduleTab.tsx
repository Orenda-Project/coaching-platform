import { useEffect, useState } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { User, MapPin, BookOpen, TrendingDown, Clock, AlertTriangle } from 'lucide-react';
import type { TeacherDcScore, CotObservation } from '@/types/observation';

interface RankedEntry {
  score: TeacherDcScore;
  lastVisit: string | null;
  daysSinceVisit: number | null;
  tier: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW';
}

function getTier(totalScore: number, framework: string): 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW' {
  const max = framework === 'FICO' ? 100 : 80;
  const pct = (totalScore / max) * 100;
  if (pct < 40) return 'CRITICAL';
  if (pct < 60) return 'HIGH';
  if (pct < 75) return 'MEDIUM';
  return 'LOW';
}

const TIER_STYLES: Record<string, { badge: string; Icon: React.ElementType }> = {
  CRITICAL: { badge: 'text-red-700 border-red-200 bg-red-50', Icon: AlertTriangle },
  HIGH: { badge: 'text-orange-700 border-orange-200 bg-orange-50', Icon: TrendingDown },
  MEDIUM: { badge: 'text-yellow-700 border-yellow-200 bg-yellow-50', Icon: Clock },
  LOW: { badge: 'text-green-700 border-green-200 bg-green-50', Icon: Clock },
};

const TIER_SCORE_COLORS: Record<string, string> = {
  CRITICAL: 'text-red-600',
  HIGH: 'text-orange-600',
  MEDIUM: 'text-yellow-600',
  LOW: 'text-green-600',
};

const TIER_LABELS: Record<string, string> = {
  CRITICAL: 'Critical — visit ASAP',
  HIGH: 'High — visit within 2 weeks',
  MEDIUM: 'Medium — visit within 3 weeks',
  LOW: 'Low — visit monthly',
};

export default function SmartScheduleTab() {
  const { user } = useAuth();
  const [ranked, setRanked] = useState<RankedEntry[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;
    loadData();
  }, [user]);

  const loadData = async () => {
    setLoading(true);

    const [scoresRes, obsRes] = await Promise.all([
      (supabase as any)
        .from('teacher_dc_scores')
        .select('*')
        .eq('observer_id', user!.id)
        .order('scored_at', { ascending: false }),
      (supabase as any)
        .from('cot_observations')
        .select('teacher_name, school_name, submitted_at, status')
        .eq('observer_id', user!.id)
        .in('status', ['Submitted', 'Approved'])
        .order('submitted_at', { ascending: false }),
    ]);

    const scores: TeacherDcScore[] = scoresRes.data ?? [];
    const visits: Pick<CotObservation, 'teacher_name' | 'school_name' | 'submitted_at' | 'status'>[] = obsRes.data ?? [];

    // Keep latest score per teacher+school
    const seen = new Set<string>();
    const latest: TeacherDcScore[] = [];
    for (const s of scores) {
      const key = `${s.teacher_name}||${s.school_name}`;
      if (!seen.has(key)) {
        seen.add(key);
        latest.push(s);
      }
    }

    // Build last-visit lookup
    const lastVisitMap = new Map<string, string>();
    for (const v of visits) {
      const key = `${v.teacher_name}||${v.school_name}`;
      if (!lastVisitMap.has(key) && v.submitted_at) {
        lastVisitMap.set(key, v.submitted_at);
      }
    }

    const today = new Date();
    const entries: RankedEntry[] = latest.map(s => {
      const key = `${s.teacher_name}||${s.school_name}`;
      const lastVisit = lastVisitMap.get(key) ?? null;
      const daysSinceVisit = lastVisit
        ? Math.floor((today.getTime() - new Date(lastVisit).getTime()) / 86400000)
        : null;
      return { score: s, lastVisit, daysSinceVisit, tier: getTier(s.total_score, s.framework) };
    });

    const tierOrder: Record<string, number> = { CRITICAL: 0, HIGH: 1, MEDIUM: 2, LOW: 3 };
    entries.sort((a, b) => {
      const diff = tierOrder[a.tier] - tierOrder[b.tier];
      if (diff !== 0) return diff;
      return (b.daysSinceVisit ?? 999) - (a.daysSinceVisit ?? 999);
    });

    setRanked(entries);
    setLoading(false);
  };

  if (loading) {
    return (
      <div className="flex justify-center py-14">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  if (ranked.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <TrendingDown className="w-10 h-10 text-muted-foreground mb-3" />
        <h3 className="font-semibold text-foreground mb-1">No DC scores yet</h3>
        <p className="text-sm text-muted-foreground max-w-xs">
          Teacher scores from the DC dashboard will appear here once synced. Teachers with lower scores are prioritised for visits.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div>
        <h2 className="font-display text-lg font-semibold text-foreground">Smart Visit Scheduler</h2>
        <p className="text-sm text-muted-foreground">
          {ranked.length} teacher{ranked.length !== 1 ? 's' : ''} ranked by priority · lower DC scores visited first
        </p>
      </div>

      <div className="space-y-3">
        {ranked.map((entry, idx) => {
          const { score, daysSinceVisit, tier } = entry;
          const { badge, Icon } = TIER_STYLES[tier];
          const max = score.framework === 'FICO' ? 100 : 80;

          return (
            <Card key={score.id} className="glass-card">
              <CardContent className="p-4">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1 space-y-2">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="text-xs font-medium text-muted-foreground">#{idx + 1}</span>
                      <Badge variant="outline" className={`text-xs ${badge}`}>
                        <Icon className="w-3 h-3 mr-1" />
                        {tier}
                      </Badge>
                      <Badge variant="outline" className="text-xs">{score.framework}</Badge>
                    </div>

                    <div className="grid grid-cols-2 gap-x-4 gap-y-1 text-sm">
                      <div className="flex items-center gap-1.5">
                        <User className="w-3.5 h-3.5 text-muted-foreground shrink-0" />
                        <span className="font-medium text-foreground truncate">{score.teacher_name}</span>
                      </div>
                      <div className="flex items-center gap-1.5 text-muted-foreground">
                        <MapPin className="w-3.5 h-3.5 shrink-0" />
                        <span className="truncate">{score.school_name}</span>
                      </div>
                      {(score.subject || score.grade) && (
                        <div className="flex items-center gap-1.5 text-muted-foreground">
                          <BookOpen className="w-3.5 h-3.5 shrink-0" />
                          <span>{[score.subject, score.grade].filter(Boolean).join(' · ')}</span>
                        </div>
                      )}
                      <div className="flex items-center gap-1.5 text-muted-foreground">
                        <Clock className="w-3.5 h-3.5 shrink-0" />
                        <span>
                          {daysSinceVisit === null
                            ? 'Never visited'
                            : `${daysSinceVisit}d since last visit`}
                        </span>
                      </div>
                    </div>

                    <p className="text-xs text-muted-foreground">{TIER_LABELS[tier]}</p>
                  </div>

                  <div className="text-right shrink-0">
                    <div className={`text-2xl font-bold ${TIER_SCORE_COLORS[tier]}`}>
                      {score.total_score}/{max}
                    </div>
                    {score.proficiency_level && (
                      <div className="text-xs text-muted-foreground">{score.proficiency_level}</div>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
