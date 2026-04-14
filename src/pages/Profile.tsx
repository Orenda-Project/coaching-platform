import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { PersonaBadge } from "@/components/PersonaBadge";
import { ArrowLeft, User, Mail, Phone, School, BookOpen, Trophy, Edit2, Save, X } from "lucide-react";
import { toast } from "sonner";

export default function Profile() {
  const { user, profile, refreshProfile } = useAuth();
  const navigate = useNavigate();
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);

  // Form state
  const [form, setForm] = useState({
    full_name: "",
    phone: "",
    school_id: "",
  });

  // Load profile data
  useEffect(() => {
    if (profile) {
      setForm({
        full_name: profile.full_name || "",
        phone: profile.phone || "",
        school_id: profile.school_id || "",
      });
    }
  }, [profile]);

  const handleSave = async () => {
    if (!user) return;

    setSaving(true);
    try {
      const { error } = await supabase
        .from("profiles")
        .update({
          full_name: form.full_name,
          phone: form.phone,
          school_id: form.school_id,
        })
        .eq("id", user.id);

      if (error) throw error;

      await refreshProfile();
      setEditing(false);
      toast.success("Profile updated successfully");
    } catch (error) {
      console.error("Error updating profile:", error);
      toast.error("Failed to update profile");
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
    if (profile) {
      setForm({
        full_name: profile.full_name || "",
        phone: profile.phone || "",
        school_id: profile.school_id || "",
      });
    }
    setEditing(false);
  };

  if (!profile || !user) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="sticky top-0 z-10 bg-background border-b shadow-sm">
        <div className="max-w-3xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => navigate("/dashboard")}
            >
              <ArrowLeft className="h-4 w-4 mr-2" />
              Back to Dashboard
            </Button>
            <h1 className="text-2xl font-bold text-foreground">My Profile</h1>
          </div>
          {!editing && (
            <Button
              onClick={() => setEditing(true)}
              variant="outline"
              size="sm"
            >
              <Edit2 className="h-4 w-4 mr-2" />
              Edit
            </Button>
          )}
        </div>
      </div>

      {/* Content */}
      <div className="max-w-3xl mx-auto px-4 py-8 space-y-6">
        {/* Profile Card - Identity */}
        <Card className="border-0 shadow-md">
          <CardHeader className="border-b">
            <CardTitle className="flex items-center gap-2">
              <User className="h-5 w-5 text-primary" />
              Personal Information
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-6 space-y-6">
            {editing ? (
              <div className="space-y-4">
                <div>
                  <Label htmlFor="full_name">Full Name</Label>
                  <Input
                    id="full_name"
                    value={form.full_name}
                    onChange={(e) =>
                      setForm({ ...form, full_name: e.target.value })
                    }
                    placeholder="Enter your full name"
                    className="mt-1"
                  />
                </div>

                <div>
                  <Label htmlFor="phone">Phone Number</Label>
                  <Input
                    id="phone"
                    type="tel"
                    value={form.phone}
                    onChange={(e) =>
                      setForm({ ...form, phone: e.target.value })
                    }
                    placeholder="Enter your phone number"
                    className="mt-1"
                  />
                </div>

                <div>
                  <Label htmlFor="school_id">School Name / ID</Label>
                  <Input
                    id="school_id"
                    value={form.school_id}
                    onChange={(e) =>
                      setForm({ ...form, school_id: e.target.value })
                    }
                    placeholder="Enter your school name or ID"
                    className="mt-1"
                  />
                </div>

                <div className="flex gap-2 pt-4 border-t">
                  <Button
                    onClick={handleSave}
                    disabled={saving}
                    className="flex-1"
                  >
                    <Save className="h-4 w-4 mr-2" />
                    {saving ? "Saving..." : "Save Changes"}
                  </Button>
                  <Button
                    onClick={handleCancel}
                    variant="outline"
                    className="flex-1"
                  >
                    <X className="h-4 w-4 mr-2" />
                    Cancel
                  </Button>
                </div>
              </div>
            ) : (
              <div className="space-y-4">
                <div>
                  <p className="text-xs font-semibold text-muted-foreground uppercase mb-1">
                    Full Name
                  </p>
                  <p className="text-sm font-medium text-foreground">
                    {form.full_name || "Not set"}
                  </p>
                </div>

                <div>
                  <p className="text-xs font-semibold text-muted-foreground uppercase mb-1">
                    Phone Number
                  </p>
                  <p className="text-sm font-medium text-foreground">
                    {form.phone || "Not set"}
                  </p>
                </div>

                <div>
                  <p className="text-xs font-semibold text-muted-foreground uppercase mb-1">
                    School Name / ID
                  </p>
                  <p className="text-sm font-medium text-foreground">
                    {form.school_id || "Not set"}
                  </p>
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Account Card - Email & Auth */}
        <Card className="border-0 shadow-md">
          <CardHeader className="border-b">
            <CardTitle className="flex items-center gap-2">
              <Mail className="h-5 w-5 text-blue-600" />
              Account Information
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-6 space-y-4">
            <div>
              <p className="text-xs font-semibold text-muted-foreground uppercase mb-1">
                Email Address
              </p>
              <p className="text-sm font-medium text-foreground">{user.email}</p>
            </div>

            <div>
              <p className="text-xs font-semibold text-muted-foreground uppercase mb-1">
                Account Created
              </p>
              <p className="text-sm font-medium text-foreground">
                {new Date(user.created_at!).toLocaleDateString("en-US", {
                  year: "numeric",
                  month: "long",
                  day: "numeric",
                })}
              </p>
            </div>
          </CardContent>
        </Card>

        {/* Learning Profile Card */}
        <Card className="border-0 shadow-md">
          <CardHeader className="border-b">
            <CardTitle className="flex items-center gap-2">
              <BookOpen className="h-5 w-5 text-amber-600" />
              Learning Profile
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-6 space-y-6">
            {/* Persona */}
            <div>
              <p className="text-xs font-semibold text-muted-foreground uppercase mb-2">
                Assigned Persona
              </p>
              {profile.persona ? (
                <div className="flex items-center gap-2">
                  <PersonaBadge persona={profile.persona} />
                  <span className="text-sm text-muted-foreground">
                    {profile.persona === "A" && "Advanced Coach"}
                    {profile.persona === "B" && "Intermediate Coach"}
                    {profile.persona === "C" && "Developing Coach"}
                    {profile.persona === "D" && "Entry-level Coach"}
                  </span>
                </div>
              ) : (
                <p className="text-sm text-muted-foreground">
                  Complete baseline assessment to be assigned a persona
                </p>
              )}
            </div>

            {/* Baseline Status */}
            <div className="border-t pt-4">
              <div className="flex items-center justify-between mb-2">
                <p className="text-xs font-semibold text-muted-foreground uppercase">
                  Baseline Assessment
                </p>
                {profile.baseline_completed && (
                  <span className="text-xs px-2 py-1 rounded-full bg-muted text-muted-foreground font-medium">
                    Completed
                  </span>
                )}
              </div>
              {profile.baseline_completed ? (
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-foreground">Score:</span>
                    <span className="text-sm font-semibold text-primary">
                      {profile.baseline_score}%
                    </span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-foreground">Attempts:</span>
                    <span className="text-sm font-semibold">
                      {profile.baseline_attempt_count || 1}
                    </span>
                  </div>
                </div>
              ) : (
                <p className="text-sm text-muted-foreground">Not completed</p>
              )}
            </div>

            {/* Endline Status */}
            <div className="border-t pt-4">
              <div className="flex items-center justify-between mb-2">
                <p className="text-xs font-semibold text-muted-foreground uppercase">
                  Endline Assessment
                </p>
                {profile.endline_completed && (
                  <span className="text-xs px-2 py-1 rounded-full bg-muted text-muted-foreground font-medium">
                    Completed
                  </span>
                )}
              </div>
              {profile.endline_completed ? (
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-foreground">Score:</span>
                    <span className="text-sm font-semibold text-primary">
                      {profile.endline_score}%
                    </span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-foreground">Attempts:</span>
                    <span className="text-sm font-semibold">
                      {profile.endline_attempt_count || 0}
                    </span>
                  </div>
                </div>
              ) : (
                <p className="text-sm text-muted-foreground">Not completed</p>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Progress Metrics Card */}
        <Card className="border-0 shadow-md">
          <CardHeader className="border-b">
            <CardTitle className="flex items-center gap-2">
              <Trophy className="h-5 w-5 text-purple-600" />
              Progress Metrics
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-6 space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="bg-muted p-4 rounded-lg">
                <p className="text-xs font-semibold text-muted-foreground uppercase mb-1">
                  Weak Modules
                </p>
                {profile.weak_modules && profile.weak_modules.length > 0 ? (
                  <div className="space-y-1">
                    {profile.weak_modules.map((module, idx) => (
                      <p
                        key={idx}
                        className="text-sm font-medium text-foreground"
                      >
                        • {module}
                      </p>
                    ))}
                  </div>
                ) : (
                  <p className="text-sm text-muted-foreground">None identified</p>
                )}
              </div>

              <div className="bg-muted p-4 rounded-lg">
                <p className="text-xs font-semibold text-muted-foreground uppercase mb-1">
                  Achievement Level
                </p>
                <div className="flex items-center gap-2">
                  {profile.persona && (
                    <span className="text-2xl font-bold text-primary">
                      {profile.persona}
                    </span>
                  )}
                  {profile.persona === "A" && (
                    <span className="text-xs font-medium text-green-700">
                      Advanced
                    </span>
                  )}
                  {profile.persona === "B" && (
                    <span className="text-xs font-medium text-blue-700">
                      Intermediate
                    </span>
                  )}
                  {profile.persona === "C" && (
                    <span className="text-xs font-medium text-yellow-700">
                      Developing
                    </span>
                  )}
                  {profile.persona === "D" && (
                    <span className="text-xs font-medium text-orange-700">
                      Entry-level
                    </span>
                  )}
                  {!profile.persona && (
                    <span className="text-xs font-medium text-muted-foreground">
                      Not assigned
                    </span>
                  )}
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
