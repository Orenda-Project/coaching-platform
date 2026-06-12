import { useState, useEffect, useRef } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { BookOpen, CheckCircle2, Layers, GitBranch } from "lucide-react";
import SlidesPlayer, { Slide } from "./SlidesPlayer";
import ScenarioPlayer, { ScenarioStep } from "./ScenarioPlayer";
import { isTrainingComplete, getActivePhase } from "@/domain/trainingRules";

const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:8000";

interface ContentItem {
  id: string;
  format_type: string;
  content_url: string;
  metadata: { duration_minutes: number | null; type_label: string };
}

interface TrainingContentViewerProps {
  trainingId: string;
  trainingTitle: string;
  onContentCompleted?: (completed: boolean) => void;
}

export default function TrainingContentViewer({ trainingId, trainingTitle, onContentCompleted }: TrainingContentViewerProps) {
  const [contents, setContents] = useState<ContentItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [slidesCompleted, setSlidesCompleted] = useState(false);
  const [scenarioCompleted, setScenarioCompleted] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);
  const [videoProgress, setVideoProgress] = useState(0);

  // Environment-based slide lock duration
  const slideLockDuration = import.meta.env.VITE_SLIDE_LOCK_DURATION
    ? parseInt(import.meta.env.VITE_SLIDE_LOCK_DURATION, 10)
    : 0;

  useEffect(() => {
    const load = async () => {
      try {
        const res = await fetch(`${apiUrl}/api/training/${trainingId}/content`);
        if (res.ok) {
          const data = await res.json();
          setContents(data || []);
        } else {
          setContents([]);
        }
      } catch {
        setContents([]);
      }
      setLoading(false);
    };
    load();
  }, [trainingId]);

  const availableFormats = contents.map((c) => c.format_type);
  const hasSlides = availableFormats.includes("slides");
  const hasScenario = availableFormats.includes("scenario");
  const hasVideo = availableFormats.includes("video");

  // Determine active phase based on domain rules
  const activePhase = getActivePhase(slidesCompleted, hasScenario);

  // Determine overall training completion
  const trainingComplete = isTrainingComplete(slidesCompleted, scenarioCompleted, hasScenario);

  // Notify parent of completion status
  useEffect(() => {
    onContentCompleted?.(trainingComplete);
  }, [trainingComplete, onContentCompleted]);

  // Parse JSON content for slides/scenario
  const slidesContent = contents.find((c) => c.format_type === "slides");
  const scenarioContent = contents.find((c) => c.format_type === "scenario");
  const videoContent = contents.find((c) => c.format_type === "video");

  const parsedSlides = (() => {
    if (!slidesContent) return null;
    try { return JSON.parse(slidesContent.content_url) as Slide[]; }
    catch { return null; }
  })();

  const parsedScenario = (() => {
    if (!scenarioContent) return null;
    try { return JSON.parse(scenarioContent.content_url); }
    catch { return null; }
  })();

  const handleVideoEnded = () => setSlidesCompleted(true);

  const handleSlideLoad = () => {
    // Legacy iframe slides — no auto-complete timer in dev/staging
  };

  const handleVideoTimeUpdate = () => {
    const video = videoRef.current;
    if (!video || !video.duration) return;
    const pct = Math.round((video.currentTime / video.duration) * 100);
    setVideoProgress(pct);
    if (pct >= 90 && !slidesCompleted) setSlidesCompleted(true);
  };

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
      {/* Phase indicator */}
      <Card className="glass-card mb-6">
        <CardHeader>
          <CardTitle className="text-lg font-display">Learning Progress</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex items-center gap-3">
            {/* Step 1: Slides */}
            <div className={`flex items-center gap-2 px-3 py-2 rounded-lg border-2 transition-all ${
              activePhase === "slides" && !slidesCompleted
                ? "border-primary bg-primary/10"
                : slidesCompleted
                ? "border-green-500 bg-green-500/10"
                : "border-border opacity-50"
            }`}>
              {slidesCompleted
                ? <CheckCircle2 className="w-5 h-5 text-green-500" />
                : <Layers className="w-5 h-5 text-primary" />}
              <span className="text-sm font-medium">Slides</span>
            </div>

            {/* Arrow */}
            {hasScenario && (
              <span className="text-muted-foreground">→</span>
            )}

            {/* Step 2: Scenario (only if exists) */}
            {hasScenario && (
              <div className={`flex items-center gap-2 px-3 py-2 rounded-lg border-2 transition-all ${
                activePhase === "scenario" && !scenarioCompleted
                  ? "border-primary bg-primary/10"
                  : scenarioCompleted
                  ? "border-green-500 bg-green-500/10"
                  : "border-border opacity-50"
              }`}>
                {scenarioCompleted
                  ? <CheckCircle2 className="w-5 h-5 text-green-500" />
                  : <GitBranch className="w-5 h-5 text-primary" />}
                <span className="text-sm font-medium">Practice</span>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Content area */}
      <Card className="glass-card mb-6">
        <CardContent className="p-6">
          {/* Phase: Slides */}
          {activePhase === "slides" && (
            <>
              {hasSlides && parsedSlides ? (
                <SlidesPlayer
                  slides={parsedSlides}
                  onCompleted={() => setSlidesCompleted(true)}
                  completed={slidesCompleted}
                />
              ) : hasVideo && videoContent ? (
                <div>
                  <h3 className="text-lg font-display font-semibold text-foreground mb-4">📹 Video Lesson</h3>
                  <video
                    ref={videoRef}
                    controls
                    className="w-full rounded-lg bg-black"
                    src={videoContent.content_url ?? undefined}
                    onEnded={handleVideoEnded}
                    onTimeUpdate={handleVideoTimeUpdate}
                  >
                    Your browser does not support the video tag.
                  </video>
                  <div className="mt-2 flex items-center justify-between text-sm text-muted-foreground">
                    <span>Watch progress: {videoProgress}%</span>
                    {slidesCompleted
                      ? <span className="flex items-center gap-1 text-green-600"><CheckCircle2 className="w-4 h-4" /> Complete</span>
                      : <span>Watch to 90% to unlock next step</span>}
                  </div>
                </div>
              ) : slidesContent ? (
                <div>
                  <h3 className="text-lg font-display font-semibold text-foreground mb-4">📊 Slide Presentation</h3>
                  <div className="bg-accent/20 rounded-lg p-4">
                    <iframe
                      src={slidesContent.content_url}
                      className="w-full h-[280px] sm:h-[400px] md:h-[500px] rounded-lg border border-border"
                      allowFullScreen
                      title="Slide presentation"
                      onLoad={handleSlideLoad}
                    />
                  </div>
                  {!slidesCompleted && slideLockDuration > 0 && (
                    <p className="text-sm text-muted-foreground mt-2 text-center">
                      View the slides for at least {slideLockDuration / 1000} seconds to unlock the next step.
                    </p>
                  )}
                </div>
              ) : (
                <div className="text-center py-8">
                  <BookOpen className="w-16 h-16 text-muted-foreground mx-auto mb-4" />
                  <h3 className="text-lg font-display font-semibold text-foreground mb-2">Module Content</h3>
                  <p className="text-muted-foreground">
                    No content available for "{trainingTitle}".
                  </p>
                </div>
              )}
            </>
          )}

          {/* Phase: Scenario (auto-navigated after slides) */}
          {activePhase === "scenario" && parsedScenario && (
            <ScenarioPlayer
              title={trainingTitle}
              description=""
              steps={parsedScenario.steps as ScenarioStep[]}
              onCompleted={() => setScenarioCompleted(true)}
              completed={scenarioCompleted}
            />
          )}
        </CardContent>
      </Card>
    </>
  );
}
