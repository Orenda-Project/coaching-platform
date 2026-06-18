import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { listModules, listTrainings, createTraining, deleteTraining } from "@/lib/apiClients/adminContentApiClient";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { toast } from "sonner";
import { Plus, Trash2, GripVertical, ArrowLeft, ChevronRight } from "lucide-react";

interface Training {
  id: string;
  module_id: string;
  title: string;
  description: string | null;
  order_number: number;
  is_common: boolean;
  persona_required: string | null;
  main_concepts: string | null;
}

interface Module {
  id: string;
  title: string;
}

export default function AdminModuleUnits() {
  const { moduleId } = useParams<{ moduleId: string }>();
  const navigate = useNavigate();
  const [module, setModule] = useState<Module | null>(null);
  const [units, setUnits] = useState<Training[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({
    title: "", description: "", main_concepts: "", is_common: true, persona_required: "",
  });

  useEffect(() => { loadData(); }, [moduleId]); // eslint-disable-line react-hooks/exhaustive-deps

  const loadData = async () => {
    if (!moduleId) return;
    setLoading(true);
    try {
      const [modulesResult, trainingsResult] = await Promise.all([
        listModules(),
        listTrainings(moduleId),
      ]);
      const mod = (modulesResult.modules as Module[]).find((m) => m.id === moduleId) || null;
      setModule(mod);
      setUnits((trainingsResult.trainings as Training[]) || []);
    } catch (err) {
      console.error("Failed to load data:", err);
      toast.error("Failed to load data");
    }
    setLoading(false);
  };

  const handleAdd = async () => {
    if (!form.title.trim()) { toast.error("Title is required"); return; }
    setSaving("new");
    try {
      await createTraining({
        title: form.title.trim(),
        description: form.description.trim() || null,
        main_concepts: form.main_concepts.trim() || null,
        is_common: form.is_common,
        persona_required: (!form.is_common && form.persona_required) ? form.persona_required : null,
        module_id: moduleId,
        order_number: units.length + 1,
      });
      toast.success("Training unit added!");
      setForm({ title: "", description: "", main_concepts: "", is_common: true, persona_required: "" });
      setShowForm(false);
      loadData();
    } catch {
      toast.error("Failed to add unit");
    }
    setSaving(null);
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Delete this training unit and all its content?")) return;
    setSaving(id);
    try {
      await deleteTraining(id);
      toast.success("Unit deleted");
      loadData();
    } catch {
      toast.error("Failed to delete");
    }
    setSaving(null);
  };

  if (loading) return <div className="flex items-center justify-center h-64"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" /></div>;

  return (
    <div className="max-w-3xl">
      <Button variant="ghost" size="sm" className="mb-4" onClick={() => navigate("/admin/modules")}>
        <ArrowLeft className="w-4 h-4 mr-1" /> Back to Modules
      </Button>

      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-display font-bold text-foreground">{module?.title || "Module"}</h1>
          <p className="text-muted-foreground text-sm mt-1">{units.length} training unit{units.length !== 1 ? "s" : ""}</p>
        </div>
        <Button onClick={() => setShowForm(!showForm)}><Plus className="w-4 h-4 mr-1" /> Add Unit</Button>
      </div>

      {showForm && (
        <Card className="mb-6 border-primary/30">
          <CardContent className="p-5 space-y-4">
            <h2 className="font-semibold text-foreground">New Training Unit</h2>
            <div>
              <Label className="text-xs text-muted-foreground mb-1 block">Title *</Label>
              <Input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="Unit title" />
            </div>
            <div>
              <Label className="text-xs text-muted-foreground mb-1 block">Description</Label>
              <Textarea value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} placeholder="Brief description..." rows={2} />
            </div>
            <div>
              <Label className="text-xs text-muted-foreground mb-1 block">Main Concepts</Label>
              <Textarea value={form.main_concepts} onChange={(e) => setForm({ ...form, main_concepts: e.target.value })} placeholder="Key concepts covered..." rows={2} />
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
              <Button onClick={handleAdd} disabled={saving === "new"}>{saving === "new" ? "Adding..." : "Add Unit"}</Button>
            </div>
          </CardContent>
        </Card>
      )}

      {units.length === 0 && !showForm && (
        <Card className="border-dashed">
          <CardContent className="p-8 text-center text-muted-foreground">No training units yet. Click "Add Unit" to start.</CardContent>
        </Card>
      )}

      <div className="space-y-2">
        {units.map((u, idx) => (
          <Card key={u.id} className="overflow-hidden hover:shadow-md transition-shadow cursor-pointer" onClick={() => navigate(`/admin/units/${u.id}/content`)}>
            <CardContent className="p-4 flex items-center gap-3">
              <GripVertical className="w-4 h-4 text-muted-foreground shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded">#{idx + 1}</span>
                  <span className="font-medium text-foreground text-sm">{u.title}</span>
                  {u.is_common
                    ? <span className="text-xs bg-secondary/20 text-secondary-foreground px-2 py-0.5 rounded">All</span>
                    : <span className="text-xs bg-accent text-accent-foreground px-2 py-0.5 rounded">Persona {u.persona_required}</span>
                  }
                </div>
                {u.description && <p className="text-xs text-muted-foreground mt-1 truncate">{u.description}</p>}
              </div>
              <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
              <button onClick={(e) => { e.stopPropagation(); handleDelete(u.id); }} disabled={saving === u.id} className="text-muted-foreground hover:text-destructive p-1 shrink-0">
                <Trash2 className="w-4 h-4" />
              </button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
