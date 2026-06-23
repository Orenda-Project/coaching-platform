import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { authApiClient } from "@/lib/apiClients/authApiClient";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { PersonaBadge } from "@/components/PersonaBadge";
import { ArrowLeft, User, Mail, Phone, School, BookOpen, Trophy, Edit2, Save, X, GraduationCap, Building2, MapPin } from "lucide-react";
import { toast } from "sonner";

interface Qualification {
  degree_type: string;
  degree: string;
  passing_year: string;
}

interface Experience {
  org: string;
  designation: string;
  joining: string;
  leaving: string;
  current: boolean;
}

const DEGREE_TYPES = ["Bachelors", "Masters", "MPhil", "PhD", "Diploma", "Other"] as const;

const REGIONS = [
  { value: "islamabad", label: "Islamabad (ICT)" },
  { value: "balochistan", label: "Balochistan" },
  { value: "punjab", label: "Punjab" },
  { value: "rawalpindi", label: "Rawalpindi (Rwp)" },
] as const;
const SUB_REGIONS = ["Nilore", "Tarnol", "Sihala", "B.K", "Urban-I", "Urban-II"] as const;
const PUNJAB_CLUSTERS = [
  "Cluster Aorangabad",
  "Cluster Chab",
  "Cluster Dakhnair",
  "Cluster Injra",
  "Cluster Jand",
  "Cluster Mithial",
  "Cluster Nara",
  "Cluster Salmanabad",
  "Cluster Tarap",
  "Cluster Thatta",
  "Cluster Ziyarat",
] as const;
const PINDI_MARKAZES = [
  "Addyala",
  "Adiala",
  "Bagga Sheikhan",
  "Bassali",
  "Bassali W-EE",
  "Cantt",
  "Chak Beli Khan",
  "Chaklala",
  "Chakri",
  "Chakri W-EE",
  "Chauntra",
  "Chountra",
  "Jhatta Hathial",
  "Jhatta Hathial W",
  "Kolian Hameed",
  "Lodhran",
  "Pirwadai",
  "Pirwadhai",
  "Raika Maira",
  "RWP Cantt",
  "Saddar Berooni",
  "Shakrial",
  "Sihal",
] as const;

const emptyQualification = (): Qualification => ({ degree_type: "", degree: "", passing_year: "" });
const emptyExperience = (): Experience => ({ org: "", designation: "", joining: "", leaving: "", current: false });

function formatMonthYear(yyyymm: string): string {
  if (!yyyymm) return "";
  const [year, month] = yyyymm.split("-");
  if (!month) return year;
  const date = new Date(Number(year), Number(month) - 1);
  return date.toLocaleDateString("en-US", { month: "short", year: "numeric" });
}

export default function Profile() {
  const { user, profile, refreshProfile, setProfile } = useAuth();
  const navigate = useNavigate();
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);

  // Form state
  const [form, setForm] = useState({ full_name: "", phone: "", school_id: "", region: "", sub_region: "", punjab_cluster: "", rawalpindi_cluster: "" });
  const [qualifications, setQualifications] = useState<Qualification[]>([]);
  const [experiences, setExperiences] = useState<Experience[]>([]);

  // Load profile data
  useEffect(() => {
    if (profile) {
      setForm({
        full_name: profile.full_name || "",
        phone: profile.phone || "",
        school_id: profile.school_id || "",
        region: profile.region || "",
        sub_region: (profile as unknown as Record<string, unknown>).sub_region as string || "",
        punjab_cluster: (profile as unknown as Record<string, unknown>).punjab_cluster as string || "",
        rawalpindi_cluster: (profile as unknown as Record<string, unknown>).rawalpindi_cluster as string || "",
      });
      setQualifications(Array.isArray(profile.qualifications) ? (profile.qualifications as unknown as Qualification[]) : []);
      setExperiences(Array.isArray(profile.experiences) ? (profile.experiences as unknown as Experience[]) : []);
    }
  }, [profile]);

  const addQualification = () => setQualifications((p) => [...p, emptyQualification()]);
  const removeQualification = (idx: number) => setQualifications((p) => p.filter((_, i) => i !== idx));
  const updateQualification = (idx: number, field: keyof Qualification, value: string) =>
    setQualifications((p) => p.map((q, i) => (i === idx ? { ...q, [field]: value } : q)));

  const addExperience = () => setExperiences((p) => [...p, emptyExperience()]);
  const removeExperience = (idx: number) => setExperiences((p) => p.filter((_, i) => i !== idx));
  const updateExperience = (idx: number, field: keyof Experience, value: string | boolean) =>
    setExperiences((p) => p.map((e, i) => (i === idx ? { ...e, [field]: value } : e)));

  const handleSave = async () => {
    if (!user) return;

    setSaving(true);
    try {
      await authApiClient.updateProfile(user.id, {
        full_name: form.full_name,
        phone: form.phone,
        school_id: form.school_id,
        region: form.region,
        sub_region: form.region === "islamabad" ? form.sub_region : null,
        punjab_cluster: form.region === "punjab" ? form.punjab_cluster : null,
        rawalpindi_cluster: form.region === "rawalpindi" ? form.rawalpindi_cluster : null,
        qualifications: qualifications,
        experiences: experiences,
      });

      // Update context directly from form so UI reflects the save immediately,
      // independent of whether the API response has the new cluster columns yet.
      setProfile({
        ...profile,
        full_name: form.full_name || null,
        phone: form.phone || null,
        school_id: form.school_id || null,
        region: form.region || null,
        sub_region: form.region === "islamabad" ? (form.sub_region || null) : null,
        punjab_cluster: form.region === "punjab" ? (form.punjab_cluster || null) : null,
        rawalpindi_cluster: form.region === "rawalpindi" ? (form.rawalpindi_cluster || null) : null,
      });
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
        region: profile.region || "",
        sub_region: (profile as unknown as Record<string, unknown>).sub_region as string || "",
        punjab_cluster: (profile as unknown as Record<string, unknown>).punjab_cluster as string || "",
        rawalpindi_cluster: (profile as unknown as Record<string, unknown>).rawalpindi_cluster as string || "",
      });
      setQualifications(Array.isArray(profile.qualifications) ? (profile.qualifications as unknown as Qualification[]) : []);
      setExperiences(Array.isArray(profile.experiences) ? (profile.experiences as unknown as Experience[]) : []);
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

                <div>
                  <Label htmlFor="region">Region</Label>
                  <select
                    id="region"
                    value={form.region}
                    onChange={(e) => {
                      const newRegion = e.target.value;
                      setForm({
                        ...form,
                        region: newRegion,
                        sub_region:         newRegion === "islamabad"  ? form.sub_region         : "",
                        punjab_cluster:     newRegion === "punjab"     ? form.punjab_cluster     : "",
                        rawalpindi_cluster: newRegion === "rawalpindi" ? form.rawalpindi_cluster : "",
                      });
                    }}
                    className="mt-1 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                  >
                    <option value="">Select region</option>
                    {REGIONS.map((r) => (
                      <option key={r.value} value={r.value}>{r.label}</option>
                    ))}
                  </select>
                </div>

                {form.region === "islamabad" && (
                <div>
                  <Label htmlFor="sub_region">Sub-Region</Label>
                  <select
                    id="sub_region"
                    value={form.sub_region}
                    onChange={(e) => setForm({ ...form, sub_region: e.target.value })}
                    className="mt-1 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                  >
                    <option value="">Select sub-region</option>
                    {SUB_REGIONS.map((sr) => (
                      <option key={sr} value={sr}>{sr}</option>
                    ))}
                  </select>
                </div>
                )}

                {form.region === "punjab" && (
                  <div>
                    <Label htmlFor="punjab_cluster">Punjab Cluster</Label>
                    <select
                      id="punjab_cluster"
                      value={form.punjab_cluster}
                      onChange={(e) => setForm({ ...form, punjab_cluster: e.target.value })}
                      className="mt-1 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                    >
                      <option value="">Select cluster</option>
                      {PUNJAB_CLUSTERS.map((c) => (
                        <option key={c} value={c}>{c}</option>
                      ))}
                    </select>
                  </div>
                )}

                {form.region === "rawalpindi" && (
                  <div>
                    <Label htmlFor="rawalpindi_cluster">Pindi Cluster (Markaz)</Label>
                    <select
                      id="rawalpindi_cluster"
                      value={form.rawalpindi_cluster}
                      onChange={(e) => setForm({ ...form, rawalpindi_cluster: e.target.value })}
                      className="mt-1 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                    >
                      <option value="">Select markaz</option>
                      {PINDI_MARKAZES.map((m) => (
                        <option key={m} value={m}>{m}</option>
                      ))}
                    </select>
                  </div>
                )}

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

                <div>
                  <p className="text-xs font-semibold text-muted-foreground uppercase mb-1">
                    Region
                  </p>
                  <p className="text-sm font-medium text-foreground">
                    {REGIONS.find((r) => r.value === form.region)?.label || "Not set"}
                  </p>
                </div>

                {form.region === "islamabad" && (
                  <div>
                    <p className="text-xs font-semibold text-muted-foreground uppercase mb-1">
                      Sub-Region
                    </p>
                    <p className="text-sm font-medium text-foreground">
                      {form.sub_region || "Not set"}
                    </p>
                  </div>
                )}

                {form.region === "punjab" && (
                  <div>
                    <p className="text-xs font-semibold text-muted-foreground uppercase mb-1">
                      Punjab Cluster
                    </p>
                    <p className="text-sm font-medium text-foreground">
                      {form.punjab_cluster || "Not set"}
                    </p>
                  </div>
                )}

                {form.region === "rawalpindi" && (
                  <div>
                    <p className="text-xs font-semibold text-muted-foreground uppercase mb-1">
                      Pindi Cluster
                    </p>
                    <p className="text-sm font-medium text-foreground">
                      {form.rawalpindi_cluster || "Not set"}
                    </p>
                  </div>
                )}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Qualifications Card */}
        <Card className="border-0 shadow-md">
          <CardHeader className="border-b">
            <CardTitle className="flex items-center gap-2">
              <GraduationCap className="h-5 w-5 text-indigo-600" />
              Qualifications
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-6 space-y-4">
            {editing ? (
              <div className="space-y-3">
                {qualifications.map((q, idx) => (
                  <div key={idx} className="border border-border rounded-md p-3 space-y-2 bg-muted/30">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold text-muted-foreground">Qualification {idx + 1}</span>
                      <button type="button" onClick={() => removeQualification(idx)} className="text-muted-foreground hover:text-destructive">
                        <X className="h-3 w-3" />
                      </button>
                    </div>
                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
                      <div>
                        <Label className="text-xs">Degree Type</Label>
                        <select
                          value={q.degree_type}
                          onChange={(e) => updateQualification(idx, "degree_type", e.target.value)}
                          className="mt-1 w-full px-3 py-2 border border-input rounded-md bg-background text-foreground text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                        >
                          <option value="">Select type...</option>
                          {DEGREE_TYPES.map((dt) => <option key={dt} value={dt}>{dt}</option>)}
                        </select>
                      </div>
                      <div>
                        <Label className="text-xs">Degree / Field</Label>
                        <Input className="mt-1" value={q.degree} onChange={(e) => updateQualification(idx, "degree", e.target.value)} placeholder="e.g. Education" />
                      </div>
                      <div>
                        <Label className="text-xs">Passing Year</Label>
                        <Input className="mt-1" maxLength={4} value={q.passing_year} onChange={(e) => updateQualification(idx, "passing_year", e.target.value)} placeholder="e.g. 2018" />
                      </div>
                    </div>
                  </div>
                ))}
                <Button type="button" variant="outline" size="sm" onClick={addQualification}>+ Add Qualification</Button>
              </div>
            ) : (
              <div className="space-y-2">
                {qualifications.length === 0 ? (
                  <p className="text-sm text-muted-foreground">No qualifications added.</p>
                ) : (
                  [...qualifications]
                    .sort((a, b) => Number(b.passing_year || 0) - Number(a.passing_year || 0))
                    .map((q, idx) => (
                      <div key={idx} className="flex items-center gap-3 py-2 border-b last:border-0">
                        <span className="text-xs font-semibold px-2 py-1 rounded-full bg-indigo-100 text-indigo-700 shrink-0">{q.degree_type || "\u2014"}</span>
                        <span className="text-sm font-medium text-foreground flex-1 min-w-0 truncate">{q.degree || "\u2014"}</span>
                        <span className="text-xs text-muted-foreground shrink-0">{q.passing_year || "\u2014"}</span>
                      </div>
                    ))
                )}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Experiences Card */}
        <Card className="border-0 shadow-md">
          <CardHeader className="border-b">
            <CardTitle className="flex items-center gap-2">
              <Building2 className="h-5 w-5 text-orange-600" />
              Work Experience
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-6 space-y-4">
            {editing ? (
              <div className="space-y-3">
                {experiences.map((exp, idx) => (
                  <div key={idx} className="border border-border rounded-md p-3 space-y-2 bg-muted/30">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold text-muted-foreground">Experience {idx + 1}</span>
                      <button type="button" onClick={() => removeExperience(idx)} className="text-muted-foreground hover:text-destructive">
                        <X className="h-3 w-3" />
                      </button>
                    </div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                      <div>
                        <Label className="text-xs">Organisation</Label>
                        <Input className="mt-1" value={exp.org} onChange={(e) => updateExperience(idx, "org", e.target.value)} placeholder="e.g. Taleemabad" />
                      </div>
                      <div>
                        <Label className="text-xs">Designation</Label>
                        <Input className="mt-1" value={exp.designation} onChange={(e) => updateExperience(idx, "designation", e.target.value)} placeholder="e.g. Head Teacher" />
                      </div>
                      <div>
                        <Label className="text-xs">Joining (YYYY-MM)</Label>
                        <Input className="mt-1" value={exp.joining} onChange={(e) => updateExperience(idx, "joining", e.target.value)} placeholder="e.g. 2020-06" />
                      </div>
                      {!exp.current && (
                        <div>
                          <Label className="text-xs">Leaving (YYYY-MM)</Label>
                          <Input className="mt-1" value={exp.leaving} onChange={(e) => updateExperience(idx, "leaving", e.target.value)} placeholder="e.g. 2023-12" />
                        </div>
                      )}
                    </div>
                    <div className="flex items-center gap-2">
                      <input
                        type="checkbox"
                        id={`current-${idx}`}
                        checked={exp.current}
                        onChange={(e) => updateExperience(idx, "current", e.target.checked)}
                        className="h-4 w-4 rounded border-input"
                      />
                      <label htmlFor={`current-${idx}`} className="text-xs text-foreground">Currently Employed Here</label>
                    </div>
                  </div>
                ))}
                <Button type="button" variant="outline" size="sm" onClick={addExperience}>+ Add Experience</Button>
              </div>
            ) : (
              <div className="space-y-2">
                {experiences.length === 0 ? (
                  <p className="text-sm text-muted-foreground">No work experience added.</p>
                ) : (
                  [...experiences]
                    .sort((a, b) => (b.joining > a.joining ? 1 : -1))
                    .map((exp, idx) => (
                      <div key={idx} className="flex items-start gap-3 py-2 border-b last:border-0">
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-semibold text-foreground truncate">{exp.designation || "\u2014"}</p>
                          <p className="text-xs text-muted-foreground truncate">{exp.org || "\u2014"}</p>
                        </div>
                        <div className="text-xs text-muted-foreground text-right shrink-0">
                          <span>{formatMonthYear(exp.joining)}</span>
                          <span className="mx-1">{"\u2013"}</span>
                          <span>{exp.current ? "Present" : formatMonthYear(exp.leaving)}</span>
                        </div>
                      </div>
                    ))
                )}
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
                      <p key={idx} className="text-sm font-medium text-foreground">
                        {"\u2022"} {module}
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
                  {profile.persona === "A" && <span className="text-xs font-medium text-green-700">Advanced</span>}
                  {profile.persona === "B" && <span className="text-xs font-medium text-blue-700">Intermediate</span>}
                  {profile.persona === "C" && <span className="text-xs font-medium text-yellow-700">Developing</span>}
                  {profile.persona === "D" && <span className="text-xs font-medium text-orange-700">Entry-level</span>}
                  {!profile.persona && <span className="text-xs font-medium text-muted-foreground">Not assigned</span>}
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
