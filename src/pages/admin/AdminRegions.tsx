import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Plus, Trash2 } from "lucide-react";
import { toast } from "sonner";

interface Region {
  id: string;
  name: string;
  code: string;
  coordinates: Record<string, number> | null;
  parent_id: string | null;
}

export default function AdminRegions() {
  const [regions, setRegions] = useState<Region[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [showForm, setShowForm] = useState(false);

  // Form state
  const [form, setForm] = useState({
    name: "",
    code: "",
    parent_id: "",
    coordinates: "",
  });

  // Load regions
  useEffect(() => {
    const loadRegions = async () => {
      try {
        const { data, error } = await supabase
          .from("regions")
          .select("*")
          .order("name");

        if (error) throw error;
        setRegions((data || []) as Region[]);
      } catch (error) {
        console.error("Error loading regions:", error);
        toast.error("Failed to load regions");
      } finally {
        setLoading(false);
      }
    };

    loadRegions();
  }, []);

  const handleAddRegion = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.name || !form.code) {
      toast.error("Name and code are required");
      return;
    }

    setSaving(true);
    try {
      // Parse coordinates if provided
      let coordinates = null;
      if (form.coordinates.trim()) {
        try {
          coordinates = JSON.parse(form.coordinates);
        } catch {
          toast.error("Invalid JSON in coordinates field");
          setSaving(false);
          return;
        }
      }

      // `as never` bypasses the typed Insert overload until types.ts is
      // regenerated to include the regions row shape.
      const { error } = await supabase.from("regions").insert({
        name: form.name,
        code: form.code,
        parent_id: form.parent_id || null,
        coordinates: coordinates,
      } as never);

      if (error) throw error;

      toast.success("Region added");
      setForm({
        name: "",
        code: "",
        parent_id: "",
        coordinates: "",
      });
      setShowForm(false);

      // Reload
      const { data } = await supabase
        .from("regions")
        .select("*")
        .order("name");

      setRegions((data || []) as Region[]);
    } catch (error) {
      console.error("Error adding region:", error);
      toast.error("Failed to add region");
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteRegion = async (regionId: string) => {
    if (!confirm("Delete this region?")) return;

    try {
      const { error } = await supabase
        .from("regions")
        .delete()
        .eq("id", regionId);

      if (error) throw error;

      toast.success("Region deleted");
      setRegions((prev) => prev.filter((r) => r.id !== regionId));
    } catch (error) {
      console.error("Error deleting region:", error);
      toast.error("Failed to delete region");
    }
  };

  if (loading) {
    return (
      <div className="h-64 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <h1 className="text-3xl font-bold">Regions</h1>

      {/* Add Form */}
      {showForm && (
        <Card className="border-primary/20 bg-primary/5">
          <CardHeader>
            <CardTitle>Add Region</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleAddRegion} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="name">Name *</Label>
                  <Input
                    id="name"
                    value={form.name}
                    onChange={(e) =>
                      setForm({ ...form, name: e.target.value })
                    }
                    placeholder="e.g., Islamabad"
                    required
                    className="mt-1"
                  />
                </div>

                <div>
                  <Label htmlFor="code">Code *</Label>
                  <Input
                    id="code"
                    value={form.code}
                    onChange={(e) =>
                      setForm({ ...form, code: e.target.value })
                    }
                    placeholder="e.g., PKR-IS"
                    required
                    className="mt-1"
                  />
                </div>
              </div>

              <div>
                <Label htmlFor="parent_id">Parent Region (optional)</Label>
                <Select
                  value={form.parent_id}
                  onValueChange={(val) =>
                    setForm({ ...form, parent_id: val })
                  }
                >
                  <SelectTrigger className="mt-1">
                    <SelectValue placeholder="None" />
                  </SelectTrigger>
                  <SelectContent>
                    {regions.length > 0 && regions.map((region) => (
                      <SelectItem key={region.id} value={region.id}>
                        {region.name}
                      </SelectItem>
                    ))}
                    {regions.length === 0 && (
                      <SelectItem value="no-regions" disabled>
                        No other regions available
                      </SelectItem>
                    )}
                  </SelectContent>
                </Select>
              </div>

              <div>
                <Label htmlFor="coordinates">Coordinates JSON (optional)</Label>
                <Textarea
                  id="coordinates"
                  value={form.coordinates}
                  onChange={(e) =>
                    setForm({ ...form, coordinates: e.target.value })
                  }
                  placeholder='{"lat": 33.6844, "lng": 73.0479}'
                  className="mt-1 text-xs font-mono"
                />
              </div>

              <div className="flex gap-2">
                <Button type="submit" disabled={saving}>
                  {saving ? "Saving..." : "Save Region"}
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setShowForm(false)}
                >
                  Cancel
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* List */}
      {regions.length === 0 ? (
        <Card className="border-dashed">
          <CardContent className="pt-8 text-center">
            <p className="text-muted-foreground mb-4">No regions yet</p>
            <Button onClick={() => setShowForm(true)}>
              <Plus className="h-4 w-4 mr-2" />
              Add First Region
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {!showForm && (
            <Button onClick={() => setShowForm(true)} variant="outline">
              <Plus className="h-4 w-4 mr-2" />
              Add Region
            </Button>
          )}

          {regions.map((region) => {
            const parentName = regions.find(
              (r) => r.id === region.parent_id
            )?.name;

            return (
              <Card key={region.id} className="hover:border-primary/50">
                <CardContent className="pt-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <h3 className="font-semibold text-sm">{region.name}</h3>
                      <p className="text-xs text-muted-foreground">
                        Code: {region.code}
                        {parentName && ` • Under: ${parentName}`}
                      </p>
                      {region.coordinates && (
                        <p className="text-xs text-muted-foreground mt-1">
                          Coordinates: {JSON.stringify(region.coordinates)}
                        </p>
                      )}
                    </div>
                    <Button
                      size="sm"
                      variant="ghost"
                      onClick={() => handleDeleteRegion(region.id)}
                    >
                      <Trash2 className="h-4 w-4 text-red-500" />
                    </Button>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
