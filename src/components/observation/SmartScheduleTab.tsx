import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import DCDashboard from './DCDashboard';
import { AlertCircle, ChevronLeft, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';
import type { CotObservation } from '@/types/observation';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const typedSupabase = supabase as any;

interface SmartScheduleTabProps {
  onNewObservation?: (obs: CotObservation) => void;
}

interface DCTeacher {
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
}

export default function SmartScheduleTab({ onNewObservation }: SmartScheduleTabProps) {
  const { user } = useAuth();
  const [teachers, setTeachers] = useState<DCTeacher[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedSector, setSelectedSector] = useState<string | null>(null);
  const [schedulingTeacherId, setSchedulingTeacherId] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      const { data, error: queryError } = await typedSupabase
        .from('teacher_dc_scores')
        .select('*')
        .order('total_score', { ascending: true });

      if (queryError) {
        setError(queryError.message);
        setTeachers([]);
      } else if (!data || data.length === 0) {
        setError('No DC scores available. Seed the teacher_dc_scores table first.');
        setTeachers([]);
      } else {
        // Map database fields to component interface
        interface DbRow {
          id: string;
          teacher_name: string;
          school_name: string;
          region: string;
          grade: string;
          subject: string;
          total_score: number;
          scored_at: string;
          raw_results?: {
            overall_percentage?: number;
            accurate_lesson_planning?: number;
            timely_lesson_delivery?: number;
            subject_command?: number;
            effective_pedagogy?: number;
            effective_resource_use?: number;
            activity_based_learning?: number;
            student_participation?: number;
            critical_thinking?: number;
            inclusive_practices?: number;
            technology_integration?: number;
            technology_handling?: number;
            verbal_communication?: number;
            non_verbal_communication?: number;
          };
        }
        const mappedTeachers: DCTeacher[] = data.map((row: DbRow) => ({
          user_id: row.id,
          teacher_name: row.teacher_name,
          school: row.school_name,
          sector: row.region,
          overall_percentage: row.raw_results?.overall_percentage || 0,
          total_score: row.total_score,
          created_date: row.scored_at,
          grade: row.grade,
          subject: row.subject,
          accurate_lesson_planning: row.raw_results?.accurate_lesson_planning || 0,
          timely_lesson_delivery: row.raw_results?.timely_lesson_delivery || 0,
          subject_command: row.raw_results?.subject_command || 0,
          effective_pedagogy: row.raw_results?.effective_pedagogy || 0,
          effective_resource_use: row.raw_results?.effective_resource_use || 0,
          activity_based_learning: row.raw_results?.activity_based_learning || 0,
          student_participation: row.raw_results?.student_participation || 0,
          critical_thinking: row.raw_results?.critical_thinking || 0,
          inclusive_practices: row.raw_results?.inclusive_practices || 0,
          technology_integration: row.raw_results?.technology_integration || 0,
          technology_handling: row.raw_results?.technology_handling || 0,
          verbal_communication: row.raw_results?.verbal_communication || 0,
          non_verbal_communication: row.raw_results?.non_verbal_communication || 0,
        }));
        setTeachers(mappedTeachers);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
      setTeachers([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const handleScheduleVisit = useCallback(async (teacher: DCTeacher) => {
    if (!user) {
      toast.error('Not authenticated');
      return;
    }

    setSchedulingTeacherId(teacher.user_id);
    try {
      const { data, error: insertError } = await typedSupabase
        .from('cot_observations')
        .insert({
          observer_id: user.id,
          teacher_name: teacher.teacher_name,
          school_name: teacher.school,
          subject: teacher.subject,
          grade: teacher.grade,
          framework: 'FICO',
          date: new Date().toISOString(),
          status: 'Draft',
        })
        .select()
        .single();

      if (insertError) {
        toast.error('Failed to schedule visit');
        console.error(insertError);
        return;
      }

      toast.success('Visit scheduled! Opening debrief...');
      onNewObservation?.(data as CotObservation);
    } catch (err) {
      toast.error('Error scheduling visit');
      console.error(err);
    } finally {
      setSchedulingTeacherId(null);
    }
  }, [user, onNewObservation]);

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <AlertCircle className="w-10 h-10 text-amber-600 mb-3" />
        <h3 className="font-semibold text-foreground mb-1">Unable to load DC scores</h3>
        <p className="text-sm text-muted-foreground max-w-xs mb-4">{error}</p>
        <p className="text-xs text-muted-foreground max-w-sm">
          To get started, seed teacher DC scores into the database using the seed script, or ensure the data sync from the DC dashboard is configured.
        </p>
      </div>
    );
  }

  // Extract unique sectors and count teachers per sector
  const uniqueSectors = Array.from(
    new Map(
      teachers.map(t => [
        t.sector,
        { sector: t.sector, count: teachers.filter(x => x.sector === t.sector).length }
      ])
    ).values()
  ).sort((a, b) => a.sector.localeCompare(b.sector));

  // Filter teachers by selected sector
  const filteredTeachers = selectedSector
    ? teachers.filter(t => t.sector === selectedSector)
    : [];

  // Sector selector view
  if (!selectedSector) {
    return (
      <div className="space-y-4">
        <div>
          <h2 className="font-display text-lg font-semibold text-foreground">Select Your Sector</h2>
          <p className="text-sm text-muted-foreground">
            Choose your sub-region to see assigned teachers
          </p>
        </div>

        {uniqueSectors.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-14 text-center">
            <AlertCircle className="w-10 h-10 text-amber-600 mb-3" />
            <h3 className="font-semibold text-foreground mb-1">No sectors found</h3>
            <p className="text-sm text-muted-foreground">
              No teacher data available yet.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-2 gap-3">
            {uniqueSectors.map(({ sector, count }) => (
              <button
                key={sector}
                onClick={() => setSelectedSector(sector)}
                className="p-4 rounded-lg border border-border bg-card hover:bg-accent transition-colors text-left"
              >
                <div className="font-medium text-foreground">{sector}</div>
                <div className="text-xs text-muted-foreground mt-1">
                  {count} teacher{count !== 1 ? 's' : ''}
                </div>
              </button>
            ))}
          </div>
        )}
      </div>
    );
  }

  // Teacher list view for selected sector
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <button
            onClick={() => setSelectedSector(null)}
            className="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors mb-2"
          >
            <ChevronLeft className="w-4 h-4" />
            Change sector
          </button>
          <h2 className="font-display text-lg font-semibold text-foreground">{selectedSector}</h2>
          <p className="text-sm text-muted-foreground">
            {filteredTeachers.length} teacher{filteredTeachers.length !== 1 ? 's' : ''} • Ranked by coaching priority
          </p>
        </div>
      </div>

      <DCDashboard
        teachers={filteredTeachers}
        loading={loading}
        onScheduleVisit={handleScheduleVisit}
      />
    </div>
  );
}
