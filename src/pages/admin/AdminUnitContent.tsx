import { useEffect, useState, useRef } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { toast } from "sonner";
import { Plus, Trash2, FileVideo, Presentation, ArrowLeft, Upload } from "lucide-react";
import { Tables } from "@/integrations/supabase/types";
import { Progress } from "@/components/ui/progress";

type TrainingContent = Tables<"training_content">;

export default function AdminUnitContent() {
  const { unitId } = useParams<{ unitId: string }>();
  const navigate = useNavigate();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [unitTitle, setUnitTitle] = useState("");
  const [moduleId, setModuleId] = useState<string | null>(null);
  const [content, setContent] = useState<TrainingContent[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [form, setForm] = useState({ format_type: "video", content_url: "" });

  useEffect(() => { loadData(); }, [unitId]);

  const loadData = async () => {
    if (!unitId) return;
    setLoading(true);
    const [{ data: unit }, { data: contentData }] = await Promise.all([
      supabase.from("trainings").select("title, module_id").eq("id", unitId).single(),
      supabase.from("training_content").select("*").eq("training_id", unitId),
    ]);
    setUnitTitle((unit as any)?.title || "");
    setModuleId((unit as any)?.module_id || null);
    setContent(contentData || []);
    setLoading(false);
  };

  const handleVideoUpload = async (file: File) => {
    if (!unitId) return;
    setUploading(true);
    setUploadProgress(0);

    const fileExt = file.name.split(".").pop();
    const filePath = `${unitId}/${Date.now()}.${fileExt}`;

    const { data, error } = await supabase.storage
      .from("training-videos")
      .upload(filePath, file, { upsert: false });

    if (error) {
      toast.error("Failed to upload video: " + error.message);
      setUploading(false);
      return;
    }

    const { data: urlData } = supabase.storage.from("training-videos").getPublicUrl(filePath);
    const publicUrl = urlData.publicUrl;

    // Save content record
    const { error: insertError } = await supabase.from("training_content").insert({
      training_id: unitId,
      format_type: "video",
      content_url: publicUrl,
    });

    if (insertError) toast.error("Video uploaded but failed to save record");
    else toast.success("Video uploaded successfully!");

    setUploading(false);
    setUploadProgress(100);
    loadData();
  };

  const handleAddUrl = async () => {
    if (!form.content_url.trim()) { toast.error("Content URL is required"); return; }
    if (!unitId) return;
    setSaving(true);
    const { error } = await supabase.from("training_content").insert({
      training_id: unitId,
      format_type: form.format_type,
      content_url: form.content_url.trim(),
    });
    if (error) toast.error("Failed to add content");
    else { toast.success("Content added!"); setForm({ format_type: "video", content_url: "" }); loadData(); }
    setSaving(false);
  };

  const handleDelete = async (id: string) => {
    const { error } = await supabase.from("training_content").delete().eq("id", id);
    if (error) toast.error("Failed to delete");
    else { toast.success("Content removed"); loadData(); }
  };

  if (loading) return <div className="flex items-center justify-center h-64"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" /></div>;

  return (
    <div className="max-w-3xl">
      <Button variant="ghost" size="sm" className="mb-4" onClick={() => moduleId ? navigate(`/admin/modules/${moduleId}/units`) : navigate("/admin/modules")}>
        <ArrowLeft className="w-4 h-4 mr-1" /> Back to Units
      </Button>

      <div className="mb-6">
        <h1 className="text-2xl font-display font-bold text-foreground">{unitTitle}</h1>
        <p className="text-muted-foreground text-sm mt-1">Manage slides and videos for this unit</p>
      </div>

      {/* Video Upload */}
      <Card className="mb-6 border-primary/30">
        <CardContent className="p-5 space-y-4">
          <h2 className="font-semibold text-foreground text-sm">Upload Video</h2>
          <div
            className="border-2 border-dashed border-border rounded-lg p-8 text-center hover:border-primary/50 transition-colors cursor-pointer"
            onClick={() => fileInputRef.current?.click()}
          >
            <Upload className="w-10 h-10 text-muted-foreground mx-auto mb-2" />
            <p className="text-sm text-muted-foreground">Click to upload a video file (MP4, WebM, MOV)</p>
            <p className="text-xs text-muted-foreground mt-1">Max 500MB</p>
          </div>
          <input
            ref={fileInputRef}
            type="file"
            accept="video/mp4,video/webm,video/ogg,video/quicktime"
            className="hidden"
            onChange={(e) => {
              const file = e.target.files?.[0];
              if (file) handleVideoUpload(file);
              e.target.value = "";
            }}
          />
          {uploading && (
            <div>
              <p className="text-sm text-muted-foreground mb-1">Uploading...</p>
              <Progress value={uploadProgress} className="h-2" />
            </div>
          )}
        </CardContent>
      </Card>

      {/* URL-based content */}
      <Card className="mb-6 border-border">
        <CardContent className="p-5 space-y-4">
          <h2 className="font-semibold text-foreground text-sm">Add Content by URL</h2>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <Label className="text-xs text-muted-foreground mb-1 block">Content Type</Label>
              <Select value={form.format_type} onValueChange={(v) => setForm({ ...form, format_type: v })}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="video">🎥 Video URL</SelectItem>
                  <SelectItem value="slide">📊 Slides (iframe)</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <div>
            <Label className="text-xs text-muted-foreground mb-1 block">
              {form.format_type === "video" ? "Video URL" : "Slides Embed URL"}
            </Label>
            <Input
              value={form.content_url}
              onChange={(e) => setForm({ ...form, content_url: e.target.value })}
              placeholder={form.format_type === "video" ? "https://..." : "https://docs.google.com/presentation/..."}
            />
          </div>
          <Button onClick={handleAddUrl} disabled={saving} className="w-full">
            <Plus className="w-4 h-4 mr-1" /> {saving ? "Adding..." : "Add Content"}
          </Button>
        </CardContent>
      </Card>

      {/* Existing content */}
      <div className="space-y-2">
        {content.length === 0 && (
          <Card className="border-dashed">
            <CardContent className="p-6 text-center text-muted-foreground text-sm">No content yet for this unit.</CardContent>
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
    </div>
  );
}
