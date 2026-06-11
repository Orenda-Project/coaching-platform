import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { Button } from "@/components/ui/button";
import {
  ArrowLeft, ArrowRight, GraduationCap, CheckCircle2
} from "lucide-react";
import TrainingContentViewer from "@/components/training/TrainingContentViewer";

const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:8000";

interface Training {
  id: string;
  title: string;
  description: string;
  module_id: string;
  order_number: number;
}

export default function TrainingModule() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();
  const [training, setTraining] = useState<Training | null>(null);
  const [loading, setLoading] = useState(true);
  const [contentCompleted, setContentCompleted] = useState(false);

  useEffect(() => {
    loadTraining();
  }, [id]); // eslint-disable-line react-hooks/exhaustive-deps

  // Auto-save progress when content is completed
  useEffect(() => {
    if (contentCompleted && user && id) {
      saveProgress();
    }
  }, [contentCompleted]); // eslint-disable-line react-hooks/exhaustive-deps

  const loadTraining = async () => {
    if (!id) return;
    try {
      const trainingRes = await fetch(`${apiUrl}/api/training/${id}`);
      if (!trainingRes.ok) { setLoading(false); return; }
      const trainingData = await trainingRes.json();
      setTraining(trainingData as Training);

      // Check if already completed
      if (user) {
        try {
          const progressRes = await fetch(`${apiUrl}/api/training/progress/${user.id}/${id}`);
          if (progressRes.ok) {
            const existing = await progressRes.json();
            if (existing.passed) setContentCompleted(true);
          }
        } catch { /* no progress yet */ }
      }
    } catch (err) {
      console.error("Failed to load training:", err);
    }
    setLoading(false);
  };

  const saveProgress = async () => {
    if (!user || !id) return;
    try {
      const getRes = await fetch(`${apiUrl}/api/training/progress/${user.id}/${id}`);
      if (getRes.ok) {
        await fetch(`${apiUrl}/api/training/progress/${user.id}/${id}/complete`, { method: "POST" });
      } else {
        await fetch(`${apiUrl}/api/training/progress?user_id=${user.id}&training_id=${id}`, { method: "POST" });
        await fetch(`${apiUrl}/api/training/progress/${user.id}/${id}/complete`, { method: "POST" });
      }
    } catch (err) {
      console.error("Failed to save progress:", err);
    }
  };

  if (loading || !training) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b border-border bg-background sticky top-0 z-10">
        <div className="container flex items-center justify-between h-14 px-4 gap-2">
          <div className="flex items-center gap-2 min-w-0">
            <GraduationCap className="w-5 h-5 text-primary shrink-0" />
            <span className="font-bold text-foreground truncate text-sm sm:text-base">{training.title}</span>
          </div>
          <Button variant="ghost" size="sm" onClick={() => navigate("/dashboard")} className="shrink-0">
            <ArrowLeft className="w-4 h-4 sm:mr-1" />
            <span className="hidden sm:inline">Dashboard</span>
          </Button>
        </div>
      </header>

      <main className="container px-4 py-8 max-w-2xl">
        <h1 className="text-2xl font-bold text-foreground mb-1">{training.title}</h1>
        <p className="text-muted-foreground mb-6">{training.description}</p>

        <TrainingContentViewer
          trainingId={id!}
          trainingTitle={training.title}
          onContentCompleted={setContentCompleted}
        />

        {contentCompleted && (
          <div className="mt-6 flex items-center justify-between">
            <div className="flex items-center gap-2 text-success text-sm">
              <CheckCircle2 className="w-4 h-4" />
              Unit completed
            </div>
            <Button onClick={() => navigate("/dashboard")}>
              Back to Dashboard <ArrowRight className="w-4 h-4 ml-1" />
            </Button>
          </div>
        )}
      </main>
    </div>
  );
}
