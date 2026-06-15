 
import { useEffect, useState, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Button } from '@/components/ui/button';
import { GraduationCap, Clock, CheckCircle2, BarChart2, ArrowLeft, CalendarDays } from 'lucide-react';
import { listObservationsForObserver } from '@/data/observations';
import { toast } from 'sonner';
import { ObservationsOverviewTab } from '@/components/observation/ObservationsOverviewTab';
import SmartScheduleTab from '@/components/observation/SmartScheduleTab';
import { VisitsDashboardTab } from '@/components/observation/VisitsDashboardTab';
import { QuickObservationPanel } from '@/components/observation/QuickObservationPanel';
import { DayEndSummaryPanel } from '@/components/observation/DayEndSummaryPanel';
import type { CotObservation } from '@/types/observation';

export default function ObservationScheduler() {
  const navigate = useNavigate();
  const { user, profile } = useAuth();
  const [observations, setObservations] = useState<CotObservation[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('scheduler');
  const [quickObs, setQuickObs] = useState<CotObservation | null>(null);
  const [showDayEndSummary, setShowDayEndSummary] = useState(false);

  const userSubRegion = (profile as Record<string, unknown>)?.sub_region as string | null;
  const userRegion = userSubRegion || ((profile as Record<string, unknown>)?.region as string | null);

  const loadObservations = useCallback(async () => {
    if (!user) return;
    try {
      console.log('[loadObservations] Loading for user:', user.id, 'region:', userRegion);
      const data = await listObservationsForObserver(user.id, userRegion || undefined);
      console.log('[loadObservations] Loaded', data.length, 'observations:', data);
      setObservations(data);
    } catch (err) {
      console.error('Failed to load observations:', err);
    }
    setLoading(false);
  }, [user, userRegion]);

  useEffect(() => {
    loadObservations();
  }, [loadObservations]);

  const scheduledCount = observations.filter(o => o.status === 'Scheduled').length;
  const completedCount = observations.filter(o => o.status === 'Submitted' || o.status === 'Approved').length;

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card sticky top-0 z-10">
        <div className="container flex items-center justify-between h-16 px-4">
          <div className="flex items-center gap-2">
            <div className="w-9 h-9 rounded-lg bg-primary flex items-center justify-center">
              <GraduationCap className="w-5 h-5 text-primary-foreground" />
            </div>
            <div className="leading-tight">
              <span className="font-display font-bold text-base text-foreground block">
                RABT
              </span>
              <span className="text-xs text-muted-foreground">Observation Scheduler</span>
            </div>
          </div>
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowDayEndSummary(true)}
              title="View day summary and export report"
            >
              📊 Day Summary
            </Button>
            <Button variant="ghost" size="sm" onClick={() => navigate('/dashboard')}>
              <ArrowLeft className="w-4 h-4 mr-1" /> Back
            </Button>
          </div>
        </div>
      </header>

      {/* Quick Observation Panel */}
      {quickObs && (
        <QuickObservationPanel
          observation={quickObs}
          onSaved={(updated) => setQuickObs(updated)}
          onSaveToDraft={async () => {
            await loadObservations();
            setQuickObs(null);
            setActiveTab('draft');
          }}
          onClose={() => setQuickObs(null)}
        />
      )}

      {/* Day End Summary Panel */}
      {showDayEndSummary && (
        <DayEndSummaryPanel
          observations={observations}
          coachName={profile?.full_name || user?.email || 'Coach'}
          subRegion={(profile as Record<string, unknown>)?.sub_region as string || 'Unknown'}
          onClose={() => setShowDayEndSummary(false)}
        />
      )}

      <main className="container px-4 py-6 max-w-3xl">
        {/* Page title */}
        <div className="mb-6">
          <h1 className="text-2xl font-display font-bold text-foreground">
            Academic Coaching &amp; Observations
          </h1>
          <p className="text-sm text-muted-foreground mt-1">
            Schedule school visits, conduct HOTS observations, and track your coaching impact
          </p>
        </div>

        {/* Main Tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="grid w-full grid-cols-3 mb-6">
            <TabsTrigger value="scheduler" className="text-xs sm:text-sm gap-1.5">
              <CalendarDays className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Smart Plan</span>
            </TabsTrigger>

            <TabsTrigger value="visits" className="text-xs sm:text-sm gap-1.5">
              <Clock className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Visits</span>
              {scheduledCount > 0 && (
                <span className="ml-0.5 bg-primary text-primary-foreground text-xs rounded-full w-4 h-4 flex items-center justify-center font-medium">
                  {scheduledCount}
                </span>
              )}
            </TabsTrigger>

            <TabsTrigger value="overview" className="text-xs sm:text-sm gap-1.5">
              <BarChart2 className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Overview</span>
            </TabsTrigger>
          </TabsList>

          <TabsContent value="scheduler">
            <SmartScheduleTab
              onNewObservation={(obs) => {
                loadObservations();
                setActiveTab('visits');
              }}
            />
          </TabsContent>

          <TabsContent value="visits">
            <VisitsDashboardTab
              observations={observations}
              onStartDebrief={(obs) => {
                setQuickObs(obs);
              }}
              onRefresh={loadObservations}
              onNavigateToScheduler={() => setActiveTab('scheduler')}
            />
          </TabsContent>

          <TabsContent value="overview">
            <ObservationsOverviewTab observations={observations} />
          </TabsContent>
        </Tabs>
      </main>
    </div>
  );
}
