import { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { FileText, Headphones, Video, BookOpen } from "lucide-react";
import { Tables } from "@/integrations/supabase/types";

type TrainingContent = Tables<"training_content">;

interface TrainingContentViewerProps {
  trainingId: string;
  trainingTitle: string;
}

export default function TrainingContentViewer({ trainingId, trainingTitle }: TrainingContentViewerProps) {
  const [contents, setContents] = useState<TrainingContent[]>([]);
  const [selectedFormat, setSelectedFormat] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      const { data } = await supabase
        .from("training_content")
        .select("*")
        .eq("training_id", trainingId);
      setContents(data || []);
      setLoading(false);
    };
    load();
  }, [trainingId]);

  const selectedContent = contents.find((c) => c.format_type === selectedFormat);
  const availableFormats = contents.map((c) => c.format_type);

  const formatConfig: Record<string, { icon: typeof FileText; label: string }> = {
    slide: { icon: FileText, label: "Slides" },
    audio: { icon: Headphones, label: "Audio" },
    video: { icon: Video, label: "Video" },
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
      <Card className="glass-card mb-6">
        <CardHeader>
          <CardTitle className="text-lg font-display">Select Learning Format</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-3 gap-3">
            {Object.entries(formatConfig).map(([key, { icon: Icon, label }]) => {
              const available = availableFormats.includes(key);
              return (
                <button
                  key={key}
                  disabled={!available}
                  onClick={() => setSelectedFormat(key)}
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
          ) : selectedContent.format_type === "video" ? (
            <div>
              <h3 className="text-lg font-display font-semibold text-foreground mb-4">📹 Video Lesson</h3>
              <video
                controls
                className="w-full rounded-lg bg-black"
                src={selectedContent.content_url}
              >
                Your browser does not support the video tag.
              </video>
            </div>
          ) : selectedContent.format_type === "audio" ? (
            <div>
              <h3 className="text-lg font-display font-semibold text-foreground mb-4">🎧 Audio Lesson</h3>
              <div className="flex items-center justify-center p-8 bg-accent/20 rounded-lg">
                <div className="text-center">
                  <Headphones className="w-16 h-16 text-primary mx-auto mb-4" />
                  <audio controls className="w-full max-w-md" src={selectedContent.content_url}>
                    Your browser does not support the audio element.
                  </audio>
                </div>
              </div>
            </div>
          ) : (
            <div>
              <h3 className="text-lg font-display font-semibold text-foreground mb-4">📊 Slide Presentation</h3>
              <div className="bg-accent/20 rounded-lg p-4">
                <iframe
                  src={selectedContent.content_url}
                  className="w-full h-[400px] rounded-lg border border-border"
                  allowFullScreen
                  title="Slide presentation"
                />
              </div>
            </div>
          )}
        </CardContent>
      </Card>
    </>
  );
}
