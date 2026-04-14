import { useState, useEffect, useRef } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { BookOpen, CheckCircle2, Layers, GitBranch } from "lucide-react";
import { Tables } from "@/integrations/supabase/types";
import SlidesPlayer, { Slide } from "./SlidesPlayer";
import ScenarioPlayer, { ScenarioStep } from "./ScenarioPlayer";

type TrainingContent = Tables<"training_content">;

interface TrainingContentViewerProps {
  trainingId: string;
  trainingTitle: string;
  onContentCompleted?: (completed: boolean) => void;
}

export default function TrainingContentViewer({ trainingId, trainingTitle, onContentCompleted }: TrainingContentViewerProps) {
  const [contents, setContents] = useState<TrainingContent[]>([]);
  const [selectedFormat, setSelectedFormat] = useState<string | null>("slides");
  const [loading, setLoading] = useState(true);
  const [contentCompleted, setContentCompleted] = useState(false);
  const slideTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const [videoProgress, setVideoProgress] = useState(0);

  useEffect(() => {
    const load = async () => {
      const { data } = await supabase
        .from("training_content")
        .select("*")
        .eq("training_id", trainingId)
        .neq("format_type", "audio");
      setContents(data || []);
      setLoading(false);
    };
    load();
  }, [trainingId]);

  useEffect(() => {
    onContentCompleted?.(contentCompleted);
  }, [contentCompleted, onContentCompleted]);

  const selectedContent = contents.find((c) => c.format_type === selectedFormat);
  const availableFormats = contents.map((c) => c.format_type);

  const formatConfig: Record<string, { icon: typeof FileText; label: string }> = {
    slides: { icon: Layers, label: "Slides" },
    scenario: { icon: GitBranch, label: "Scenario" },
  };

  const handleVideoEnded = () => setContentCompleted(true);

  const handleSlideLoad = () => {
    if (slideTimerRef.current) clearTimeout(slideTimerRef.current);
    slideTimerRef.current = setTimeout(() => setContentCompleted(true), 30000);
  };

  const handleVideoTimeUpdate = () => {
    const video = videoRef.current;
    if (!video || !video.duration) return;
    const pct = Math.round((video.currentTime / video.duration) * 100);
    setVideoProgress(pct);
    if (pct >= 90 && !contentCompleted) setContentCompleted(true);
  };

  // Parse JSON content_url for slides/scenario formats
  const parsedContent = (() => {
    if (!selectedContent) return null;
    if (selectedContent.format_type === "slides" || selectedContent.format_type === "scenario") {
      try {
        return JSON.parse(selectedContent.content_url);
      } catch {
        return null;
      }
    }
    return null;
  })();

  if (loading) {
    return (
      <Card className="glass-card mb-6">
        <CardContent className="p-8 text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto" />
        </CardContent>
      </Card>
    );
  }

  return (
    <>
      <Card className="glass-card mb-6">
        <CardHeader>
          <CardTitle className="text-lg font-display">Select Learning Format</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 gap-3">
            {Object.entries(formatConfig).map(([key, { icon: Icon, label }]) => {
              const available = availableFormats.includes(key);
              return (
                <button
                  key={key}
                  disabled={!available}
                  onClick={() => { setSelectedFormat(key); setContentCompleted(false); }}
                  className={`flex flex-col items-center gap-2 p-4 rounded-lg border-2 transition-all ${
                    selectedFormat === key
                      ? "border-primary bg-primary/10"
                      : available
                      ? "border-border hover:border-primary hover:bg-accent/50"
                      : "border-border opacity-40 cursor-not-allowed"
                  }`}
                >
                  <Icon className="w-8 h-8 text-primary" />
                  <span className="text-sm font-medium text-foreground">{label}</span>
                </button>
              );
            })}
          </div>
        </CardContent>
      </Card>

      <Card className="glass-card mb-6">
        <CardContent className="p-6">
          {!selectedContent ? (
            <div className="text-center py-8">
              <BookOpen className="w-16 h-16 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-lg font-display font-semibold text-foreground mb-2">Module Content</h3>
              <p className="text-muted-foreground">
                Select a format above to start learning "{trainingTitle}".
              </p>
            </div>
          ) : selectedContent.format_type === "slides" && parsedContent ? (
            <SlidesPlayer
              slides={parsedContent as Slide[]}
              onCompleted={() => setContentCompleted(true)}
              completed={contentCompleted}
            />
          ) : selectedContent.format_type === "scenario" && parsedContent ? (
            <ScenarioPlayer
              title={trainingTitle}
              description=""
              steps={parsedContent.steps as ScenarioStep[]}
              onCompleted={() => setContentCompleted(true)}
              completed={contentCompleted}
            />
          ) : selectedContent.format_type === "video" ? (
            <div>
              <h3 className="text-lg font-display font-semibold text-foreground mb-4">📹 Video Lesson</h3>
              <video
                ref={videoRef}
                controls
                className="w-full rounded-lg bg-black"
                src={selectedContent.content_url ?? undefined}
                onEnded={handleVideoEnded}
                onTimeUpdate={handleVideoTimeUpdate}
              >
                Your browser does not support the video tag.
              </video>
              <div className="mt-2 flex items-center justify-between text-sm text-muted-foreground">
                <span>Watch progress: {videoProgress}%</span>
                {contentCompleted
                  ? <span className="flex items-center gap-1 text-green-600"><CheckCircle2 className="w-4 h-4" /> Complete</span>
                  : <span>Watch to 90% to unlock quiz</span>}
              </div>
            </div>
          ) : (
            <div>
              <h3 className="text-lg font-display font-semibold text-foreground mb-4">📊 Slide Presentation</h3>
              <div className="bg-accent/20 rounded-lg p-4">
                <iframe
                  src={selectedContent.content_url}
                  className="w-full h-[280px] sm:h-[400px] md:h-[500px] rounded-lg border border-border"
                  allowFullScreen
                  title="Slide presentation"
                  onLoad={handleSlideLoad}
                />
              </div>
              {!contentCompleted && (
                <p className="text-sm text-muted-foreground mt-2 text-center">
                  View the slides for at least 30 seconds to unlock the quiz.
                </p>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </>
  );
}
