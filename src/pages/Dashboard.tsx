import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { PersonaBadge } from "@/components/PersonaBadge";
import { ModuleCard } from "@/components/ModuleCard";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { GraduationCap, LogOut, Award, ClipboardCheck, Trophy } from "lucide-react";
import { toast } from "sonner";
import { Tables } from "@/integrations/supabase/types";

type Training = Tables<"trainings">;
type TrainingProgress = Tables<"training_progress">;

export default function Dashboard() {
  const { user, profile, signOut, refreshProfile } = useAuth();
  const navigate = useNavigate();
  const [trainings, setTrainings] = useState<Training[]>([]);
  const [progress, setProgress] = useState<TrainingProgress[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (profile) loadData();
  }, [profile]);

  const loadData = async () => {
    if (!user || !profile) return;

    // Fetch trainings for user's persona (common + persona-specific)
    let query = supabase.from("trainings").select("*").order("order_number");
    
    if (profile.persona) {
      query = query.or(`is_common.eq.true,persona_required.eq.${profile.persona}`);
    } else {
      query = query.eq("is_common", true);
    }

    const [{ data: trainingsData }, { data: progressData }] = await Promise.all([
      query,
      supabase.from("training_progress").select("*").eq("user_id", user.id),
    ]);

    setTrainings(trainingsData || []);
    setProgress(progressData || []);
    setLoading(false);
  };

  const getModuleStatus = (trainingId: string): "not_started" | "in_progress" | "passed" | "failed" => {
    const p = progress.find((pr) => pr.training_id === trainingId);
    if (!p) return "not_started";
    if (p.passed) return "passed";
    if (p.score !== null && p.score < 80) return "failed";
    return "in_progress";
  };

  const isModuleLocked = (index: number): boolean => {
    if (profile?.endline_completed) return false; // All unlocked after completion
    if (!profile?.baseline_completed) return true;
    if (index === 0) return false; // First module always unlocked
    const prevTraining = trainings[index - 1];
    if (!prevTraining) return true;
    const prevProgress = progress.find((p) => p.training_id === prevTraining.id);
    return !prevProgress?.passed;
  };

  const passedCount = progress.filter((p) => p.passed).length;
  const totalModules = trainings.length;
  const overallProgress = totalModules > 0 ? (passedCount / totalModules) * 100 : 0;
  const allModulesCompleted = passedCount === totalModules && totalModules > 0;

  const handleModuleClick = (training: Training) => {
    navigate(`/training/${training.id}`);
  };

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
        <div className="container flex items-center justify-between h-16 px-4">
          <div className="flex items-center gap-2">
            <div className="w-9 h-9 rounded-lg bg-primary flex items-center justify-center">
              <GraduationCap className="w-5 h-5 text-primary-foreground" />
            </div>
            <span className="font-display font-bold text-lg text-foreground">CoachCert</span>
          </div>
          <div className="flex items-center gap-3">
            {profile?.persona && <PersonaBadge persona={profile.persona} size="sm" />}
            <Button variant="ghost" size="sm" onClick={() => { signOut(); navigate("/login"); }}>
              <LogOut className="w-4 h-4 mr-1" />
              Sign Out
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
        <div className="grid grid-cols-1 sm:grid-cols-4 gap-4 mb-8">
          <Card className="glass-card animate-fade-in" style={{ animationDelay: "0.1s" }}>
            <CardContent className="p-4 flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-accent flex items-center justify-center">
                <ClipboardCheck className="w-5 h-5 text-accent-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Baseline</p>
                <p className="font-semibold text-foreground">
                  {profile?.baseline_completed ? `${Math.round(profile.baseline_score || 0)}%` : "Pending"}
                </p>
              </div>
            </CardContent>
          </Card>
          <Card className="glass-card animate-fade-in" style={{ animationDelay: "0.15s" }}>
            <CardContent className="p-4 flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-accent flex items-center justify-center">
                <ClipboardCheck className="w-5 h-5 text-accent-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Endline</p>
                <p className="font-semibold text-foreground">
                  {profile?.endline_completed ? `${Math.round(profile.endline_score || 0)}%` : "Pending"}
                </p>
              </div>
            </CardContent>
          </Card>
          <Card className="glass-card animate-fade-in" style={{ animationDelay: "0.2s" }}>
            <CardContent className="p-4 flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-accent flex items-center justify-center">
                <Award className="w-5 h-5 text-accent-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Progress</p>
                <p className="font-semibold text-foreground">{passedCount}/{totalModules} Modules</p>
              </div>
            </CardContent>
          </Card>
          <Card className="glass-card animate-fade-in" style={{ animationDelay: "0.3s" }}>
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

        {/* Baseline CTA */}
        {!profile?.baseline_completed && (
          <Card className="glass-card mb-8 border-secondary/30 animate-fade-in">
            <CardContent className="p-6 text-center">
              <ClipboardCheck className="w-12 h-12 text-secondary mx-auto mb-3" />
              <h2 className="text-xl font-display font-bold text-foreground mb-2">Baseline Assessment Required</h2>
              <p className="text-muted-foreground mb-4">
                Complete the baseline assessment to unlock your personalized training path.
              </p>
              <Button onClick={() => navigate("/assessment/baseline")} size="lg">
                Attempt Baseline Assessment
              </Button>
            </CardContent>
          </Card>
        )}

        {/* Progress bar */}
        {profile?.baseline_completed && (
          <div className="mb-6 animate-fade-in">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium text-foreground">Overall Progress</span>
              <span className="text-sm text-muted-foreground">{Math.round(overallProgress)}%</span>
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
                You've completed all training modules. Take the endline assessment to earn your certificate.
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
              <h2 className="text-xl font-display font-bold text-foreground mb-2">Certificate Earned!</h2>
              <p className="text-muted-foreground mb-4">
                Congratulations on completing your certification.
              </p>
              <Button onClick={() => navigate("/certificate")} size="lg">
                View & Download Certificate
              </Button>
            </CardContent>
          </Card>
        )}

        {/* Training Modules */}
        {profile?.baseline_completed && trainings.length > 0 && (
          <div className="space-y-3 animate-fade-in" style={{ animationDelay: "0.2s" }}>
            <h2 className="text-lg font-display font-bold text-foreground mb-3">Training Modules</h2>
            {trainings.map((training, index) => {
              const status = getModuleStatus(training.id);
              const locked = isModuleLocked(index);
              const p = progress.find((pr) => pr.training_id === training.id);
              return (
                <ModuleCard
                  key={training.id}
                  title={training.title}
                  description={training.description}
                  orderNumber={training.order_number}
                  isLocked={locked}
                  status={status}
                  score={p?.score}
                  onClick={() => handleModuleClick(training)}
                />
              );
            })}
          </div>
        )}
      </main>
    </div>
  );
}
