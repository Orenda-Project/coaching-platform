import { useEffect, useState } from "react";
import { listModules, createModule, deleteModule } from "@/lib/apiClients/adminContentApiClient";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { toast } from "sonner";
import { Plus, Trash2, GripVertical, ChevronRight } from "lucide-react";
import { useNavigate } from "react-router-dom";

interface Module {
  id: string;
  title: string;
  description: string | null;
  desired_outcomes: string | null;
  competencies: string | null;
  is_mandatory: boolean;
  order_number: number;
  created_at: string;
  updated_at: string;
}

export default function AdminModules() {
  const [modules, setModules] = useState<Module[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({
    title: "", description: "", desired_outcomes: "", competencies: "", is_mandatory: false,
  });
  const navigate = useNavigate();

  useEffect(() => { loadModules(); }, []);

  const loadModules = async () => {
    setLoading(true);
    try {
      const result = await listModules();
      setModules((result.modules as Module[]) || []);
    } catch (err) {
      console.error("Failed to load modules:", err);
      toast.error("Failed to load modules");
    }
    setLoading(false);
  };

  const handleAdd = async () => {
    if (!form.title.trim()) { toast.error("Title is required"); return; }
    setSaving("new");
    try {
      await createModule({
        title: form.title.trim(),
        description: form.description.trim() || null,
        desired_outcomes: form.desired_outcomes.trim() || null,
        competencies: form.competencies.trim() || null,
        is_mandatory: form.is_mandatory,
        order_number: modules.length + 1,
      });
      toast.success("Module added!");
      setForm({ title: "", description: "", desired_outcomes: "", competencies: "", is_mandatory: false });
      setShowForm(false);
      loadModules();
    } catch {
      toast.error("Failed to add module");
    }
    setSaving(null);
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Delete this module and all its training units?")) return;
    setSaving(id);
    try {
      await deleteModule(id);
      toast.success("Module deleted");
      loadModules();
    } catch {
      toast.error("Failed to delete");
    }
    setSaving(null);
  };

  if (loading) return <div className="flex items-center justify-center h-64"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" /></div>;

  return (
    <div className="max-w-3xl">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-display font-bold text-foreground">Modules</h1>
          <p className="text-muted-foreground text-sm mt-1">{modules.length} module{modules.length !== 1 ? "s" : ""}</p>
        </div>
        <Button onClick={() => setShowForm(!showForm)}><Plus className="w-4 h-4 mr-1" /> Add Module</Button>
      </div>

      {showForm && (
        <Card className="mb-6 border-primary/30">
          <CardContent className="p-5 space-y-4">
            <h2 className="font-semibold text-foreground">New Module</h2>
            <div>
              <Label className="text-xs text-muted-foreground mb-1 block">Title *</Label>
              <Input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="Module title" />
            </div>
            <div>
              <Label className="text-xs text-muted-foreground mb-1 block">Description</Label>
              <Textarea value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} placeholder="Brief description..." rows={2} />
            </div>
            <div>
              <Label className="text-xs text-muted-foreground mb-1 block">Competencies</Label>
              <Textarea value={form.competencies} onChange={(e) => setForm({ ...form, competencies: e.target.value })} placeholder="Comma-separated competencies..." rows={2} />
            </div>
            <div>
              <Label className="text-xs text-muted-foreground mb-1 block">Desired Outcomes</Label>
              <Textarea value={form.desired_outcomes} onChange={(e) => setForm({ ...form, desired_outcomes: e.target.value })} placeholder="Outcomes..." rows={3} />
            </div>
            <div className="flex items-center gap-3">
              <Switch checked={form.is_mandatory} onCheckedChange={(v) => setForm({ ...form, is_mandatory: v })} id="is-mandatory" />
              <Label htmlFor="is-mandatory" className="text-sm text-foreground">Mandatory for all personas</Label>
            </div>
            <div className="flex gap-2 justify-end">
              <Button variant="outline" onClick={() => setShowForm(false)}>Cancel</Button>
              <Button onClick={handleAdd} disabled={saving === "new"}>{saving === "new" ? "Adding..." : "Add Module"}</Button>
            </div>
          </CardContent>
        </Card>
      )}

      {modules.length === 0 && !showForm && (
        <Card className="border-dashed">
          <CardContent className="p-8 text-center text-muted-foreground">No modules yet. Click "Add Module" to start.</CardContent>
        </Card>
      )}

      <div className="space-y-2">
        {modules.map((m, idx) => (
          <Card key={m.id} className="overflow-hidden hover:shadow-md transition-shadow cursor-pointer" onClick={() => navigate(`/admin/modules/${m.id}/units`)}>
            <CardContent className="p-4 flex items-center gap-3">
              <GripVertical className="w-4 h-4 text-muted-foreground shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded">#{idx + 1}</span>
                  <span className="font-medium text-foreground text-sm">{m.title}</span>
                  {m.is_mandatory
                    ? <span className="text-xs bg-secondary/20 text-secondary-foreground px-2 py-0.5 rounded">Mandatory</span>
                    : <span className="text-xs bg-accent text-accent-foreground px-2 py-0.5 rounded">Optional</span>
                  }
                </div>
                {m.description && <p className="text-xs text-muted-foreground mt-1 truncate">{m.description}</p>}
              </div>
              <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
              <button onClick={(e) => { e.stopPropagation(); handleDelete(m.id); }} disabled={saving === m.id} className="text-muted-foreground hover:text-destructive p-1 shrink-0">
                <Trash2 className="w-4 h-4" />
              </button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
