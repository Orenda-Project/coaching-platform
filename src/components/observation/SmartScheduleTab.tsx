import { useState, useMemo } from 'react';
import { CotObservation } from '@/types/observation';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  buildTeacherRosterWithScores,
  rankTeachersByUrgency,
  generateWeeklySchedule,
  generateFourWeekPlan,
  RankedTeacher,
  ScheduledVisit,
  PriorityTier,
} from '@/lib/scheduler-utils';
import PriorityList from './PriorityList';
import WeeklyPlanView from './WeeklyPlanView';
import FourWeekOverview from './FourWeekOverview';
import PriorityAlertBanner from './PriorityAlertBanner';

interface TeacherRosterRow {
  teacher_name: string;
  school_name: string;
  region?: string;
}

interface SmartScheduleTabProps {
  observations: CotObservation[];
  onAddToSchedule: (teacher: ScheduledVisit) => void;
}

export default function SmartScheduleTab({
  observations,
  onAddToSchedule,
}: SmartScheduleTabProps) {
  const [roster, setRoster] = useState<TeacherRosterRow[]>([]);
  const [newTeacherName, setNewTeacherName] = useState('');
  const [newSchoolName, setNewSchoolName] = useState('');
  const [newRegion, setNewRegion] = useState('');
  const [openDialog, setOpenDialog] = useState(false);
  const [lastPlanTierMap, setLastPlanTierMap] = useState<
    Map<string, PriorityTier>
  >(new Map());

  // Build teacher roster with scores and rank by urgency
  const rankedTeachers = useMemo(() => {
    const withScores = buildTeacherRosterWithScores(roster, observations);
    return rankTeachersByUrgency(withScores);
  }, [roster, observations]);

  // Generate this week's schedule
  const { scheduled: weeklySchedule } = useMemo(
    () => generateWeeklySchedule(rankedTeachers),
    [rankedTeachers]
  );

  // Generate 4-week plan
  const fourWeekPlan = useMemo(
    () => generateFourWeekPlan(rankedTeachers),
    [rankedTeachers]
  );

  // Detect tier changes from last plan run
  const tierChanges = useMemo(() => {
    const changes: Array<{ teacher: string; school: string; oldTier: PriorityTier | null; newTier: PriorityTier }> = [];
    rankedTeachers.forEach((teacher) => {
      const key = `${teacher.teacher_name}-${teacher.school_name}`;
      const oldTier = lastPlanTierMap.get(key) ?? null;
      if (oldTier && oldTier !== teacher.tier) {
        changes.push({
          teacher: teacher.teacher_name,
          school: teacher.school_name,
          oldTier,
          newTier: teacher.tier,
        });
      }
    });
    return changes;
  }, [rankedTeachers, lastPlanTierMap]);

  // Add teacher to roster
  const handleAddTeacher = () => {
    if (!newTeacherName.trim() || !newSchoolName.trim()) {
      alert('Please fill in teacher name and school');
      return;
    }

    const isDuplicate = roster.some(
      (t) =>
        t.teacher_name === newTeacherName &&
        t.school_name === newSchoolName
    );
    if (isDuplicate) {
      alert('This teacher is already in your roster');
      return;
    }

    setRoster([
      ...roster,
      {
        teacher_name: newTeacherName,
        school_name: newSchoolName,
        region: newRegion,
      },
    ]);

    setNewTeacherName('');
    setNewSchoolName('');
    setNewRegion('');
    setOpenDialog(false);
  };

  // Remove teacher from roster
  const handleRemoveTeacher = (teacherName: string, schoolName: string) => {
    setRoster((prev) =>
      prev.filter(
        (t) => !(t.teacher_name === teacherName && t.school_name === schoolName)
      )
    );
  };

  // Update tier map after viewing plan
  const handleViewPlan = () => {
    const newMap = new Map<string, PriorityTier>();
    rankedTeachers.forEach((teacher) => {
      const key = `${teacher.teacher_name}-${teacher.school_name}`;
      newMap.set(key, teacher.tier);
    });
    setLastPlanTierMap(newMap);
  };

  return (
    <div className="space-y-6 p-6">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-semibold">Smart Coach Visit Scheduler</h2>
          <p className="text-sm text-gray-600 mt-1">
            {roster.length} teachers · {rankedTeachers.filter(t => t.tier === 'CRITICAL').length} critical
          </p>
        </div>

        <Dialog open={openDialog} onOpenChange={setOpenDialog}>
          <DialogTrigger asChild>
            <Button>+ Add Teacher to Roster</Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Add Teacher to Roster</DialogTitle>
              <DialogDescription>
                Add a teacher even if they haven't been observed yet.
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4">
              <div>
                <label className="text-sm font-medium">Teacher Name</label>
                <Input
                  value={newTeacherName}
                  onChange={(e) => setNewTeacherName(e.target.value)}
                  placeholder="e.g., Ayesha Khan"
                />
              </div>
              <div>
                <label className="text-sm font-medium">School Name</label>
                <Input
                  value={newSchoolName}
                  onChange={(e) => setNewSchoolName(e.target.value)}
                  placeholder="e.g., Gov School Jand"
                />
              </div>
              <div>
                <label className="text-sm font-medium">Region (Optional)</label>
                <Input
                  value={newRegion}
                  onChange={(e) => setNewRegion(e.target.value)}
                  placeholder="e.g., ICT, Punjab"
                />
              </div>
              <Button onClick={handleAddTeacher} className="w-full">
                Add Teacher
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      </div>

      {/* Alert Banner: Show if tier changes detected */}
      {tierChanges.length > 0 && (
        <PriorityAlertBanner changes={tierChanges} />
      )}

      {roster.length === 0 ? (
        <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
          <p className="text-gray-600 mb-4">
            No teachers in your roster yet. Add some to generate a smart schedule.
          </p>
          <Button onClick={() => setOpenDialog(true)}>Add Your First Teacher</Button>
        </div>
      ) : (
        <Tabs defaultValue="priority" onValueChange={(value) => {
          if (value === 'weekly') handleViewPlan();
        }}>
          <TabsList>
            <TabsTrigger value="priority">Priority List</TabsTrigger>
            <TabsTrigger value="weekly">Weekly Plan</TabsTrigger>
            <TabsTrigger value="month">4-Week Overview</TabsTrigger>
          </TabsList>

          <TabsContent value="priority">
            <PriorityList
              rankedTeachers={rankedTeachers}
              onRemoveTeacher={handleRemoveTeacher}
              onAddToSchedule={onAddToSchedule}
            />
          </TabsContent>

          <TabsContent value="weekly">
            <WeeklyPlanView
              schedule={weeklySchedule}
              onAddToSchedule={onAddToSchedule}
            />
          </TabsContent>

          <TabsContent value="month">
            <FourWeekOverview plan={fourWeekPlan} />
          </TabsContent>
        </Tabs>
      )}
    </div>
  );
}
