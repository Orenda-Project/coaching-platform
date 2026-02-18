import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { toast } from "sonner";
import { Plus, Trash2, FileVideo, Presentation } from "lucide-react";
import { Tables } from "@/integrations/supabase/types";

type Training = Tables<"trainings">;
type TrainingContent = Tables<"training_content">;

export default function AdminTrainingContent() {
  const [trainings, setTrainings] = useState<Training[]>([]);
  const [selectedTraining, setSelectedTraining] = useState<string>("");
  const [content, setContent] = useState<TrainingContent[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState({ format_type: "video", content_url: "" });

  useEffect(() => { loadTrainings(); }, []);
  useEffect(() => { if (selectedTraining) loadContent(); }, [selectedTraining]);

  const loadTrainings = async () => {
    setLoading(true);
    const { data } = await supabase.from("trainings").select("*").order("order_number");
    setTrainings(data || []);
    if (data?.length) setSelectedTraining(data[0].id);
    setLoading(false);
  };

  const loadContent = async () => {
    if (!selectedTraining) return;
    const { data } = await supabase.from("training_content").select("*").eq("training_id", selectedTraining);
    setContent(data || []);
  };

  const handleAdd = async () => {
    if (!form.content_url.trim()) { toast.error("Content URL is required"); return; }
    if (!selectedTraining) { toast.error("Select a training first"); return; }
    setSaving(true);
    const { error } = await supabase.from("training_content").insert({
      training_id: selectedTraining,
      format_type: form.format_type,
      content_url: form.content_url.trim(),
    });
    if (error) { toast.error("Failed to add content"); }
    else { toast.success("Content added!"); setForm({ format_type: "video", content_url: "" }); loadContent(); }
    setSaving(false);
  };

  const handleDelete = async (id: string) => {
    const { error } = await supabase.from("training_content").delete().eq("id", id);
    if (error) { toast.error("Failed to delete"); }
    else { toast.success("Content removed"); loadContent(); }
  };

  const selectedTrainingData = trainings.find((t) => t.id === selectedTraining);

  if (loading) return <div className="flex items-center justify-center h-64"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" /></div>;

  return (
    <div className="max-w-3xl">
      <div className="mb-6">
        <h1 className="text-2xl font-display font-bold text-foreground">Training Content</h1>
        <p className="text-muted-foreground text-sm mt-1">Manage slides and videos for each module</p>
      </div>

      {/* Training selector */}
      <div className="mb-6">
        <Label className="text-xs text-muted-foreground mb-1 block">Select Training Module</Label>
        <Select value={selectedTraining} onValueChange={setSelectedTraining}>
          <SelectTrigger className="w-full">
            <SelectValue placeholder="Choose a module" />
          </SelectTrigger>
          <SelectContent>
            {trainings.map((t, i) => (
              <SelectItem key={t.id} value={t.id}>#{i + 1} — {t.title}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {selectedTraining && (
        <>
          <Card className="mb-6 border-primary/30">
            <CardContent className="p-5 space-y-4">
              <h2 className="font-semibold text-foreground text-sm">Add Content to: <span className="text-primary">{selectedTrainingData?.title}</span></h2>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <Label className="text-xs text-muted-foreground mb-1 block">Content Type</Label>
                  <Select value={form.format_type} onValueChange={(v) => setForm({ ...form, format_type: v })}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="video">🎥 Video</SelectItem>
                      <SelectItem value="slide">📊 Slides (iframe)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <div>
                <Label className="text-xs text-muted-foreground mb-1 block">
                  {form.format_type === "video" ? "Video URL (MP4 or embed)" : "Slides Embed URL (Google Slides, Canva, etc.)"}
                </Label>
                <Input
                  value={form.content_url}
                  onChange={(e) => setForm({ ...form, content_url: e.target.value })}
                  placeholder={form.format_type === "video" ? "https://..." : "https://docs.google.com/presentation/..."}
                />
                <p className="text-xs text-muted-foreground mt-1">
                  {form.format_type === "slide"
                    ? "Use Google Slides publish link, Canva embed, or any iframe-compatible URL"
                    : "Direct MP4 link or video embed URL"}
                </p>
              </div>
              <Button onClick={handleAdd} disabled={saving} className="w-full">
                <Plus className="w-4 h-4 mr-1" /> {saving ? "Adding..." : "Add Content"}
              </Button>
            </CardContent>
          </Card>

          <div className="space-y-2">
            {content.length === 0 && (
              <Card className="border-dashed">
                <CardContent className="p-6 text-center text-muted-foreground text-sm">No content yet for this module.</CardContent>
              </Card>
            )}
            {content.map((c) => (
              <Card key={c.id}>
                <CardContent className="p-4 flex items-center gap-3">
                  <div className="w-8 h-8 rounded-lg bg-accent flex items-center justify-center shrink-0">
                    {c.format_type === "video" ? <FileVideo className="w-4 h-4 text-accent-foreground" /> : <Presentation className="w-4 h-4 text-accent-foreground" />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <span className="text-xs font-medium text-muted-foreground uppercase">{c.format_type}</span>
                    <p className="text-sm text-foreground truncate">{c.content_url}</p>
                  </div>
                  <button onClick={() => handleDelete(c.id)} className="text-muted-foreground hover:text-destructive p-1 shrink-0">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </CardContent>
              </Card>
            ))}
          </div>
        </>
      )}
    </div>
  );
}
