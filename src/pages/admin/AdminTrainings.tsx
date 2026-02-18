import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { toast } from "sonner";
import { Plus, Trash2, GripVertical } from "lucide-react";
import { Tables } from "@/integrations/supabase/types";

type Training = Tables<"trainings">;

export default function AdminTrainings() {
  const [trainings, setTrainings] = useState<Training[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ title: "", description: "", is_common: true, persona_required: "" });

  useEffect(() => { loadTrainings(); }, []);

  const loadTrainings = async () => {
    setLoading(true);
    const { data } = await supabase.from("trainings").select("*").order("order_number");
    setTrainings(data || []);
    setLoading(false);
  };

  const handleAdd = async () => {
    if (!form.title.trim()) { toast.error("Title is required"); return; }
    setSaving("new");
    const { error } = await supabase.from("trainings").insert({
      title: form.title.trim(),
      description: form.description.trim() || null,
      is_common: form.is_common,
      persona_required: (!form.is_common && form.persona_required) ? form.persona_required : null,
      order_number: trainings.length + 1,
    });
    if (error) { toast.error("Failed to add training"); }
    else { toast.success("Training module added!"); setForm({ title: "", description: "", is_common: true, persona_required: "" }); setShowForm(false); loadTrainings(); }
    setSaving(null);
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Delete this training module? This will also remove all associated content and quiz data.")) return;
    setSaving(id);
    const { error } = await supabase.from("trainings").delete().eq("id", id);
    if (error) { toast.error("Failed to delete"); }
    else { toast.success("Training deleted"); loadTrainings(); }
    setSaving(null);
  };

  if (loading) return <div className="flex items-center justify-center h-64"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" /></div>;

  return (
    <div className="max-w-3xl">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-display font-bold text-foreground">Training Modules</h1>
          <p className="text-muted-foreground text-sm mt-1">{trainings.length} module{trainings.length !== 1 ? "s" : ""}</p>
        </div>
        <Button onClick={() => setShowForm(!showForm)}><Plus className="w-4 h-4 mr-1" /> Add Module</Button>
      </div>

      {showForm && (
        <Card className="mb-6 border-primary/30">
          <CardContent className="p-5 space-y-4">
            <h2 className="font-semibold text-foreground">New Training Module</h2>
            <div>
              <Label className="text-xs text-muted-foreground mb-1 block">Title *</Label>
              <Input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="Module title" />
            </div>
            <div>
              <Label className="text-xs text-muted-foreground mb-1 block">Description</Label>
              <Textarea value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} placeholder="Brief description..." rows={2} />
            </div>
            <div className="flex items-center gap-3">
              <Switch checked={form.is_common} onCheckedChange={(v) => setForm({ ...form, is_common: v })} id="is-common" />
              <Label htmlFor="is-common" className="text-sm text-foreground">Available to all personas</Label>
            </div>
            {!form.is_common && (
              <div>
                <Label className="text-xs text-muted-foreground mb-1 block">Persona Required</Label>
                <Select value={form.persona_required} onValueChange={(v) => setForm({ ...form, persona_required: v })}>
                  <SelectTrigger><SelectValue placeholder="Select persona" /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="A">Persona A</SelectItem>
                    <SelectItem value="B">Persona B</SelectItem>
                    <SelectItem value="C">Persona C</SelectItem>
                    <SelectItem value="D">Persona D</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            )}
            <div className="flex gap-2 justify-end">
              <Button variant="outline" onClick={() => setShowForm(false)}>Cancel</Button>
              <Button onClick={handleAdd} disabled={saving === "new"}>{saving === "new" ? "Adding..." : "Add Module"}</Button>
            </div>
          </CardContent>
        </Card>
      )}

      {trainings.length === 0 && !showForm && (
        <Card className="border-dashed">
          <CardContent className="p-8 text-center text-muted-foreground">No training modules yet. Click "Add Module" to start.</CardContent>
        </Card>
      )}

      <div className="space-y-2">
        {trainings.map((t, idx) => (
          <Card key={t.id} className="overflow-hidden">
            <CardContent className="p-4 flex items-center gap-3">
              <GripVertical className="w-4 h-4 text-muted-foreground shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded">#{idx + 1}</span>
                  <span className="font-medium text-foreground text-sm">{t.title}</span>
                  {t.is_common
                    ? <span className="text-xs bg-secondary/20 text-secondary-foreground px-2 py-0.5 rounded">All</span>
                    : <span className="text-xs bg-accent text-accent-foreground px-2 py-0.5 rounded">Persona {t.persona_required}</span>
                  }
                </div>
                {t.description && <p className="text-xs text-muted-foreground mt-1 truncate">{t.description}</p>}
              </div>
              <button onClick={() => handleDelete(t.id)} disabled={saving === t.id} className="text-muted-foreground hover:text-destructive p-1 shrink-0">
                <Trash2 className="w-4 h-4" />
              </button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
