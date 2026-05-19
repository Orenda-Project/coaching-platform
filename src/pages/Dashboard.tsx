import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { PersonaBadge } from "@/components/PersonaBadge";
import { ModuleCard } from "@/components/ModuleCard";
import { BaselineResultsCard } from "@/components/BaselineResultsCard";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  GraduationCap,
  LogOut,
  Award,
  ClipboardCheck,
  Trophy,
  Shield,
  ChevronDown,
  ChevronRight,
  FileQuestion,
  User,
  CalendarDays,
} from "lucide-react";
import { useAdminRole } from "@/hooks/useAdminRole";
import { useCoachRole } from "@/hooks/useCoachRole";
import { useAnalytics } from "@/hooks/useAnalytics";
import { Tables } from "@/integrations/supabase/types";
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible";

type Training = Tables<"trainings">;
type TrainingProgress = Tables<"training_progress">;

interface Module {
  id: string;
  title: string;
  description: string | null;
  is_mandatory: boolean;
  order_number: number;
  competencies: string | null;
  desired_outcomes: string | null;
}

export default function Dashboard() {
  const { user, profile, signOut } = useAuth();
  const navigate = useNavigate();
  const { isAdmin } = useAdminRole();
  const { isCoach } = useCoachRole();
  const { track } = useAnalytics();
  const [modules, setModules] = useState<Module[]>([]);
  const [trainings, setTrainings] = useState<Training[]>([]);
  const [progress, setProgress] = useState<TrainingProgress[]>([]);
  const [loading, setLoading] = useState(true);
  const [openModules, setOpenModules] = useState<Set<string>>(new Set());

  useEffect(() => {
    // Redirect to onboarding if not completed — region is the required onboarding field
    if (profile && !profile.region) {
      navigate("/onboarding");
      return;
    }
    if (profile) loadData();
  }, [profile, navigate, isCoach]); // Re-run when isCoach is detected

  // Track tab visibility changes on dashboard
  useEffect(() => {
    const handleVisibilityChange = () => {
      track({
        event_type: document.hidden ? "tab_hidden" : "tab_visible",
        metadata: { page: "dashboard" },
      });
    };

    document.addEventListener("visibilitychange", handleVisibilityChange);
    return () => {
      document.removeEventListener("visibilitychange", handleVisibilityChange);
    };
  }, [track]);

  const loadData = async () => {
    if (!user || !profile) return;

    const [
      { data: modulesData },
      { data: trainingsData },
      { data: progressData },
    ] = await Promise.all([
      supabase.from("modules").select("*").order("order_number"),
      supabase.from("trainings").select("*").order("order_number"),
      supabase.from("training_progress").select("*").eq("user_id", user.id),
    ]);

    const allModules: Module[] = (modulesData as Module[]) || [];
    const allTrainings = trainingsData || [];

    // Module visibility logic:
    // - Coaches: Always show all modules (regardless of persona or vacation mode)
    // - Persona E: Always show all modules
    // - Other personas: Show Module 1 (mandatory) + modules matching weak_modules from baseline
    let assignedModules = allModules;
    if (isCoach || profile.persona === "E") {
      // Coaches and Persona E see all modules
      assignedModules = allModules;
    } else {
      // Everyone else: show persona-based filtering (Module 1 + weak_modules)
      const weakModules = profile.weak_modules || [];
      assignedModules = allModules.filter(
        (m) =>
          m.is_mandatory || weakModules.some((wm) => m.title.startsWith(wm)),
      );
    }
    const assignedModuleIds = new Set(assignedModules.map((m) => m.id));
    const assignedTrainings = allTrainings.filter(
      (t) => t.module_id && assignedModuleIds.has(t.module_id),
    );

    setModules(assignedModules);
    setTrainings(assignedTrainings);
    setProgress(progressData || []);
    setLoading(false);
  };

  const getModuleStatus = (
    trainingId: string,
  ): "not_started" | "in_progress" | "passed" | "failed" => {
    const p = progress.find((pr) => pr.training_id === trainingId);
    if (!p) return "not_started";
    if (p.passed) return "passed";
    if (p.score !== null && p.score < 80) return "failed";
    return "in_progress";
  };

  const getUnitsForModule = (moduleId: string) =>
    trainings.filter((t) => t.module_id === moduleId);

  const getModuleProgress = (moduleId: string) => {
    const units = getUnitsForModule(moduleId);
    if (units.length === 0) return { passed: 0, total: 0, percent: 0 };
    const passed = units.filter((u) => {
      const p = progress.find((pr) => pr.training_id === u.id);
      return p?.passed;
    }).length;
    return {
      passed,
      total: units.length,
      percent: (passed / units.length) * 100,
    };
  };

  const isUnitLocked = (moduleId: string, unitIndex: number): boolean => {
    if (profile?.endline_completed) return false;
    if (!profile?.baseline_completed) return true;
    // Sort units by order_number (not array index) before checking sequential lock
    const units = getUnitsForModule(moduleId)
      .slice()
      .sort((a, b) => a.order_number - b.order_number);
    if (unitIndex === 0) return false;
    const prevUnit = units[unitIndex - 1];
    if (!prevUnit) return true;
    const prevProgress = progress.find((p) => p.training_id === prevUnit.id);
    return !prevProgress?.passed;
  };

  const allUnitsPassedForModule = (moduleId: string) => {
    const units = getUnitsForModule(moduleId);
    return (
      units.length > 0 &&
      units.every((u) => progress.find((p) => p.training_id === u.id)?.passed)
    );
  };

  // Endline is unlocked only when ALL assigned trainings are passed
  const allModulesCompleted =
    trainings.length > 0 &&
    trainings.every(
      (t) => progress.find((p) => p.training_id === t.id)?.passed,
    );

  const toggleModule = (id: string) => {
    setOpenModules((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const passedCount = progress.filter((p) => p.passed).length;
  const totalUnits = trainings.length;
  const overallProgress = totalUnits > 0 ? (passedCount / totalUnits) * 100 : 0;

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
      <header className="border-b border-border bg-card">
        <div className="container flex items-center justify-between h-16 px-4 gap-2">
          <div className="flex items-center gap-2 shrink-0">
            <div className="w-9 h-9 rounded-lg bg-primary flex items-center justify-center">
              <GraduationCap className="w-5 h-5 text-primary-foreground" />
            </div>
            <span className="font-display font-bold text-lg text-foreground">
              <span className="hidden sm:inline">RABT (Reflective Action for Better Teaching)</span>
              <span className="sm:hidden">RABT</span>
            </span>
          </div>
          <div className="flex items-center gap-1 sm:gap-3">
            {profile?.persona && (
              <PersonaBadge persona={profile.persona} size="sm" />
            )}
            <Button
              variant="ghost"
              size="sm"
              onClick={() => navigate("/observation-scheduler")}
            >
              <CalendarDays className="w-4 h-4 sm:mr-1" />
              <span className="hidden sm:inline">Scheduler</span>
            </Button>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => navigate("/profile")}
            >
              <User className="w-4 h-4 sm:mr-1" />
              <span className="hidden sm:inline">Profile</span>
            </Button>
            {isAdmin && (
              <Button
                variant="outline"
                size="sm"
                onClick={() => navigate("/admin/analytics")}
              >
                <Shield className="w-4 h-4 sm:mr-1" />
                <span className="hidden sm:inline">Admin</span>
              </Button>
            )}
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                signOut();
                navigate("/login");
              }}
            >
              <LogOut className="w-4 h-4 sm:mr-1" />
              <span className="hidden sm:inline">Sign Out</span>
            </Button>
          </div>
        </div>
      </header>

      <main className="container px-4 py-8 max-w-4xl">
        {/* Welcome */}
        <div className="mb-8 animate-fade-in">
          <h1 className="text-3xl font-display font-bold text-foreground">
            Welcome{profile?.full_name ? `, ${profile.full_name}` : ""}
          </h1>
          <p className="text-muted-foreground mt-1">
            {profile?.endline_completed
              ? "Congratulations! You've completed your certification."
              : profile?.baseline_completed
                ? "Continue your training journey below."
                : "Complete your baseline assessment to begin training."}
          </p>
        </div>

        {/* Stats row */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-8">
          <Card
            className="glass-card animate-fade-in"
            style={{ animationDelay: "0.1s" }}
          >
            <CardContent className="p-4 flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-accent flex items-center justify-center">
                <ClipboardCheck className="w-5 h-5 text-accent-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Baseline</p>
                <p className="font-semibold text-foreground">
                  {profile?.baseline_completed
                    ? `${Math.round(profile.baseline_score || 0)}%`
                    : "Pending"}
                </p>
              </div>
            </CardContent>
          </Card>
          {(allModulesCompleted || profile?.endline_completed) && (
            <Card
              className="glass-card animate-fade-in"
              style={{ animationDelay: "0.15s" }}
            >
              <CardContent className="p-4 flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg bg-accent flex items-center justify-center">
                  <ClipboardCheck className="w-5 h-5 text-accent-foreground" />
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">Endline</p>
                  <p className="font-semibold text-foreground">
                    {profile?.endline_completed
                      ? `${Math.round(profile.endline_score || 0)}%`
                      : "Pending"}
                  </p>
                </div>
              </CardContent>
            </Card>
          )}
          <Card
            className="glass-card animate-fade-in"
            style={{ animationDelay: "0.2s" }}
          >
            <CardContent className="p-4 flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-accent flex items-center justify-center">
                <Award className="w-5 h-5 text-accent-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Progress</p>
                <p className="font-semibold text-foreground">
                  {passedCount}/{totalUnits} Units
                </p>
              </div>
            </CardContent>
          </Card>
          <Card
            className="glass-card animate-fade-in"
            style={{ animationDelay: "0.3s" }}
          >
            <CardContent className="p-4 flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-accent flex items-center justify-center">
                <Trophy className="w-5 h-5 text-accent-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Certificate</p>
                <p className="font-semibold text-foreground">
                  {profile?.endline_completed ? "Earned ✓" : "Locked"}
                </p>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Baseline CTA — not yet attempted */}
        {!profile?.baseline_completed && (
          <Card className="glass-card mb-8 border-secondary/30 animate-fade-in">
            <CardContent className="p-6 text-center">
              <ClipboardCheck className="w-12 h-12 text-secondary mx-auto mb-3" />
              <h2 className="text-xl font-display font-bold text-foreground mb-2">
                Baseline Assessment Required
              </h2>
              <p className="text-muted-foreground mb-4">
                Complete the baseline assessment to unlock your personalized
                training path.
              </p>
              <Button
                onClick={() => navigate("/assessment/baseline")}
                size="lg"
              >
                Attempt Baseline Assessment
              </Button>
            </CardContent>
          </Card>
        )}

        {/* Baseline Results — completed */}
        {profile?.baseline_completed && (
          <BaselineResultsCard
            baselineScore={Math.round(profile.baseline_score || 0)}
            persona={profile.persona || ""}
            weakModules={profile.weak_modules || []}
          />
        )}

        {/* Progress bar */}
        {profile?.baseline_completed && (
          <div className="mb-6 animate-fade-in">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium text-foreground">
                Overall Progress
              </span>
              <span className="text-sm text-muted-foreground">
                {Math.round(overallProgress)}%
              </span>
            </div>
            <Progress value={overallProgress} className="h-2" />
          </div>
        )}

        {/* Endline CTA */}
        {allModulesCompleted && !profile?.endline_completed && (
          <Card className="glass-card mb-8 border-success/30 animate-fade-in">
            <CardContent className="p-6 text-center">
              <Trophy className="w-12 h-12 text-success mx-auto mb-3" />
              <h2 className="text-xl font-display font-bold text-foreground mb-2">
                🎉 All Trainings Complete!
              </h2>
              <p className="text-muted-foreground mb-4">
                You've completed all training modules. Take the endline
                assessment to earn your certificate.
              </p>
              <Button onClick={() => navigate("/assessment/endline")} size="lg">
                Attempt Endline Assessment
              </Button>
            </CardContent>
          </Card>
        )}

        {/* Certificate download */}
        {profile?.endline_completed && (
          <Card className="glass-card mb-8 border-success/30 animate-fade-in">
            <CardContent className="p-6 text-center">
              <Award className="w-12 h-12 text-success mx-auto mb-3" />
              <h2 className="text-xl font-display font-bold text-foreground mb-2">
                Certificate Earned!
              </h2>
              <p className="text-muted-foreground mb-4">
                Congratulations on completing your certification.
              </p>
              <Button onClick={() => navigate("/certificate")} size="lg">
                View & Download Certificate
              </Button>
            </CardContent>
          </Card>
        )}

        {/* Modules with Units */}
        {profile?.baseline_completed && modules.length > 0 && (
          <div
            className="space-y-4 animate-fade-in"
            style={{ animationDelay: "0.2s" }}
          >
            <h2 className="text-lg font-display font-bold text-foreground mb-3">
              Training Modules
            </h2>
            {modules.map((mod, modIdx) => {
              const units = getUnitsForModule(mod.id);
              const modProgress = getModuleProgress(mod.id);
              const isOpen = openModules.has(mod.id);

              return (
                <Collapsible
                  key={mod.id}
                  open={isOpen}
                  onOpenChange={() => toggleModule(mod.id)}
                >
                  <Card
                    className={
                      modProgress.percent === 100
                        ? "border-success/30 bg-success/5"
                        : ""
                    }
                  >
                    <CollapsibleTrigger asChild>
                      <CardContent className="p-5 cursor-pointer hover:bg-accent/30 transition-colors">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-lg bg-primary text-primary-foreground flex items-center justify-center text-sm font-bold font-display shrink-0">
                            {modIdx + 1}
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2 flex-wrap">
                              <h3 className="font-semibold font-display text-foreground">
                                {mod.title}
                              </h3>
                              {mod.is_mandatory && (
                                <span className="text-xs bg-secondary/20 text-secondary-foreground px-2 py-0.5 rounded">
                                  Mandatory
                                </span>
                              )}
                            </div>
                            {mod.description && (
                              <p className="text-sm text-muted-foreground mt-1">
                                {mod.description}
                              </p>
                            )}
                            <div className="flex items-center gap-2 mt-2">
                              <Progress
                                value={modProgress.percent}
                                className="flex-1 h-1.5"
                              />
                              <span className="text-xs text-muted-foreground">
                                {modProgress.passed}/{modProgress.total}
                              </span>
                            </div>
                          </div>
                          {isOpen ? (
                            <ChevronDown className="w-5 h-5 text-muted-foreground shrink-0" />
                          ) : (
                            <ChevronRight className="w-5 h-5 text-muted-foreground shrink-0" />
                          )}
                        </div>
                      </CardContent>
                    </CollapsibleTrigger>
                    <CollapsibleContent>
                      <div className="px-5 pb-4 space-y-2 border-t border-border pt-3">
                        {units.length === 0 && (
                          <p className="text-sm text-muted-foreground text-center py-2">
                            No training units in this module yet.
                          </p>
                        )}
                        {units.map((unit, unitIdx) => {
                          const status = getModuleStatus(unit.id);
                          const locked = isUnitLocked(mod.id, unitIdx);
                          const p = progress.find(
                            (pr) => pr.training_id === unit.id,
                          );
                          return (
                            <ModuleCard
                              key={unit.id}
                              title={unit.title}
                              description={unit.description}
                              orderNumber={unitIdx + 1}
                              isLocked={locked}
                              status={status}
                              score={p?.score}
                              onClick={() => navigate(`/training/${unit.id}`)}
                            />
                          );
                        })}

                        {/* Module Quiz CTA */}
                        {units.length > 0 && (
                          <div
                            className={`mt-3 p-3 rounded-lg border flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 ${allUnitsPassedForModule(mod.id) ? "border-primary/30 bg-primary/5" : "border-border bg-muted/30"}`}
                          >
                            <div className="flex items-center gap-2">
                              <FileQuestion
                                className={`w-5 h-5 ${allUnitsPassedForModule(mod.id) ? "text-primary" : "text-muted-foreground"}`}
                              />
                              <div>
                                <p
                                  className={`text-sm font-medium ${allUnitsPassedForModule(mod.id) ? "text-foreground" : "text-muted-foreground"}`}
                                >
                                  Module Quiz
                                </p>
                                <p className="text-xs text-muted-foreground">
                                  {allUnitsPassedForModule(mod.id)
                                    ? "All units complete — quiz unlocked"
                                    : "Complete all units to unlock"}
                                </p>
                              </div>
                            </div>
                            <Button
                              size="sm"
                              disabled={!allUnitsPassedForModule(mod.id)}
                              onClick={() => navigate(`/module-quiz/${mod.id}`)}
                              className="shrink-0"
                            >
                              Attempt Quiz
                            </Button>
                          </div>
                        )}
                      </div>
                    </CollapsibleContent>
                  </Card>
                </Collapsible>
              );
            })}
          </div>
        )}
      </main>
    </div>
  );
}
