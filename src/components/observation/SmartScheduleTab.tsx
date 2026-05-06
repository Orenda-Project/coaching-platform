import { useEffect, useMemo, useRef, useState } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  buildRosterFromDcScores,
  rankTeachersByUrgency,
  generateWeeklySchedule,
  generateFourWeekPlan,
  detectTierChange,
  type PriorityTier,
  type RankedTeacher,
} from '@/lib/scheduler-utils';
import PriorityList from './PriorityList';
import WeeklyPlanView from './WeeklyPlanView';
import FourWeekOverview from './FourWeekOverview';
import PriorityAlertBanner from './PriorityAlertBanner';
import { TrendingDown } from 'lucide-react';
import type { TeacherDcScore, CotObservation } from '@/types/observation';

interface TierChange {
  teacher: string;
  school: string;
  oldTier: PriorityTier;
  newTier: PriorityTier;
}

export default function SmartScheduleTab() {
  const { user } = useAuth();
  const [dcScores, setDcScores] = useState<TeacherDcScore[]>([]);
  const [visits, setVisits] = useState<Pick<CotObservation, 'teacher_name' | 'school_name' | 'submitted_at' | 'status'>[]>([]);
  const [loading, setLoading] = useState(true);
  const prevTierMap = useRef<Map<string, PriorityTier>>(new Map());
  const [tierChanges, setTierChanges] = useState<TierChange[]>([]);

  useEffect(() => {
    if (!user) return;
    loadData();
  }, [user]);

  const loadData = async () => {
    setLoading(true);

    let coachSubRegion = 'Tarnol'; // default

    try {
      const assignRes = await (supabase as any)
        .from('coach_assignments')
        .select('region, sub_region')
        .eq('coach_id', user!.id)
        .single();

      if (assignRes.data?.sub_region) {
        coachSubRegion = assignRes.data.sub_region;
      }
      if (assignRes.error) {
        console.error('Coach assignment error:', assignRes.error);
      }
    } catch (err) {
      console.error('Error fetching coach assignment:', err);
    }

    const [scoresRes, visitsRes] = await Promise.all([
      (supabase as any)
        .from('teacher_dc_scores')
        .select('*')
        .eq('observer_id', user!.id)
        .eq('sub_region', coachSubRegion)
        .order('scored_at', { ascending: false }),
      (supabase as any)
        .from('cot_observations')
        .select('teacher_name, school_name, submitted_at, status')
        .eq('observer_id', user!.id)
        .in('status', ['Submitted', 'Approved'])
        .order('submitted_at', { ascending: false }),
    ]);
    setDcScores(scoresRes.data ?? []);
    setVisits(visitsRes.data ?? []);
    setLoading(false);
  };

  const rankedTeachers = useMemo(() => {
    const roster = buildRosterFromDcScores(dcScores, visits);
    return rankTeachersByUrgency(roster);
  }, [dcScores, visits]);

  // Detect tier changes after each rank update
  useEffect(() => {
    if (rankedTeachers.length === 0) return;
    const changes: TierChange[] = [];
    rankedTeachers.forEach(t => {
      const key = `${t.teacher_name}||${t.school_name}`;
      const old = prevTierMap.current.get(key) ?? null;
      if (old && detectTierChange(old, t.tier)) {
        changes.push({ teacher: t.teacher_name, school: t.school_name, oldTier: old, newTier: t.tier });
      }
    });
    if (changes.length > 0) setTierChanges(changes);

    // Update ref for next comparison
    const newMap = new Map<string, PriorityTier>();
    rankedTeachers.forEach(t => newMap.set(`${t.teacher_name}||${t.school_name}`, t.tier));
    prevTierMap.current = newMap;
  }, [rankedTeachers]);

  const { scheduled: weeklySchedule } = useMemo(
    () => generateWeeklySchedule(rankedTeachers),
    [rankedTeachers]
  );

  const fourWeekPlan = useMemo(
    () => generateFourWeekPlan(rankedTeachers),
    [rankedTeachers]
  );

  const criticalCount = rankedTeachers.filter(t => t.tier === 'CRITICAL').length;

  const noop = () => {};

  if (loading) {
    return (
      <div className="flex justify-center py-14">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  if (rankedTeachers.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <TrendingDown className="w-10 h-10 text-muted-foreground mb-3" />
        <h3 className="font-semibold text-foreground mb-1">No DC scores yet</h3>
        <p className="text-sm text-muted-foreground max-w-xs">
          Teacher scores from the DC dashboard will appear here once synced. Teachers with lower scores are prioritised for visits first.
        </p>
      </div>
    );
  }

  const subRegion = rankedTeachers.length > 0 ? rankedTeachers[0]?.region || 'ICT' : 'ICT';

  return (
    <div className="space-y-4">
      <div>
        <h2 className="font-display text-lg font-semibold text-foreground">Smart Visit Scheduler</h2>
        <p className="text-sm text-muted-foreground">
          {rankedTeachers.length} teacher{rankedTeachers.length !== 1 ? 's' : ''} in <span className="font-medium text-foreground">{subRegion}</span>
          {criticalCount > 0 && (
            <span className="text-red-600 font-medium"> · {criticalCount} critical</span>
          )}
        </p>
      </div>

      <PriorityAlertBanner changes={tierChanges} />

      <Tabs defaultValue="priority">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="priority" className="text-xs sm:text-sm">Priority List</TabsTrigger>
          <TabsTrigger value="weekly" className="text-xs sm:text-sm">Weekly Plan</TabsTrigger>
          <TabsTrigger value="month" className="text-xs sm:text-sm">4-Week Overview</TabsTrigger>
        </TabsList>

        <TabsContent value="priority" className="mt-4">
          <PriorityList
            rankedTeachers={rankedTeachers}
            onRemoveTeacher={noop}
            onAddToSchedule={noop}
          />
        </TabsContent>

        <TabsContent value="weekly" className="mt-4">
          <WeeklyPlanView schedule={weeklySchedule} onAddToSchedule={noop} />
        </TabsContent>

        <TabsContent value="month" className="mt-4">
          <FourWeekOverview plan={fourWeekPlan} />
        </TabsContent>
      </Tabs>
    </div>
  );
}
