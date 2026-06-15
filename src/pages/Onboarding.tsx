import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { authApiClient } from "@/lib/apiClients/authApiClient";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { toast } from "sonner";
import { GraduationCap, MapPin, Building2, Users, ArrowRight, CheckCircle2 } from "lucide-react";

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
const SUB_REGIONS = ["Nilore", "Tarnol", "Sihala", "B.K", "Urban-I", "Urban-II"] as const;
const emptyQualification = (): Qualification => ({ degree_type: "", degree: "", passing_year: "" });
const emptyExperience = (): Experience => ({ org: "", designation: "", joining: "", leaving: "", current: false });

export default function Onboarding() {
  const navigate = useNavigate();
  const { user, profile, refreshProfile } = useAuth();
  const [region, setRegion] = useState("");
  const [subRegion, setSubRegion] = useState("");
  const [school, setSchool] = useState("");
  const [teachers, setTeachers] = useState("");
  const [qualifications, setQualifications] = useState<Qualification[]>([]);
  const [experiences, setExperiences] = useState<Experience[]>([]);
  const [loading, setLoading] = useState(false);
  const submitting = useRef(false);
  const navigated = useRef(false);
/* //test */
  const addQualification = () => setQualifications((prev) => [...prev, emptyQualification()]);
  const removeQualification = (idx: number) => setQualifications((prev) => prev.filter((_, i) => i !== idx));
  const updateQualification = (idx: number, field: keyof Qualification, value: string) =>
    setQualifications((prev) => prev.map((q, i) => (i === idx ? { ...q, [field]: value } : q)));

  const addExperience = () => setExperiences((prev) => [...prev, emptyExperience()]);
  const removeExperience = (idx: number) => setExperiences((prev) => prev.filter((_, i) => i !== idx));
  const updateExperience = (idx: number, field: keyof Experience, value: string | boolean) =>
    setExperiences((prev) => prev.map((e, i) => (i === idx ? { ...e, [field]: value } : e)));

  // If already onboarded (and not mid-submit), redirect to dashboard — only once
  useEffect(() => {
    if (profile?.region && !submitting.current && !navigated.current) {
      navigated.current = true;
      navigate("/dashboard");
    }
  }, [profile, navigate]);

  const regions = [
    { value: "islamabad", label: "Islamabad (ICT)" },
    { value: "balochistan", label: "Balochistan" },
    { value: "punjab", label: "Punjab" },
    { value: "rawalpindi", label: "Rawalpindi (Rwp)" },
  ];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!region.trim()) {
      toast.error("Region is required");
      return;
    }

    if (region === "islamabad" && !subRegion.trim()) {
      toast.error("Sub-region is required for Islamabad");
      return;
    }

    if (!user?.id) {
      toast.error("User not authenticated");
      return;
    }

    setLoading(true);
    submitting.current = true;
    try {
      await authApiClient.updateProfile(user.id, {
        region: region,
        sub_region: subRegion,
        school_id: school,
        teacher_ids: teachers
          .split(",")
          .map((t) => t.trim())
          .filter((t) => t.length > 0),
        qualifications: qualifications.filter((q) => q.degree_type || q.degree || q.passing_year),
        experiences: experiences.filter((e) => e.org || e.designation || e.joining),
      });

      toast.success("Onboarding complete! Welcome to RABT");
      navigated.current = true;
      await refreshProfile();
      navigate("/dashboard");
    } catch (error: unknown) {
      submitting.current = false;
      console.error("Onboarding error:", error);
      toast.error(error instanceof Error ? error.message : "Failed to complete onboarding");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-background p-4">
      <div className="w-full max-w-2xl animate-fade-in">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="flex items-center justify-center gap-2 mb-4">
            <div className="w-12 h-12 rounded-xl bg-primary flex items-center justify-center">
              <GraduationCap className="w-7 h-7 text-primary-foreground" />
            </div>
            <h1 className="text-2xl font-display font-bold text-foreground">RABT</h1>
          </div>
          <h2 className="text-xl font-semibold text-foreground">Complete Your Profile</h2>
          <p className="text-muted-foreground text-sm mt-2">
            Help us personalize your coaching journey
          </p>
        </div>

        <div className="grid grid-cols-3 gap-4 mb-8">
          {/* Progress steps */}
          {[
            { icon: CheckCircle2, label: "Account Created", done: true },
            { icon: Users, label: "Profile Setup", done: true },
            { icon: ArrowRight, label: "Ready to Learn", done: false }
          ].map((step, idx) => {
            const Icon = step.icon;
            return (
              <div key={idx} className="flex flex-col items-center gap-2 text-center">
                <div
                  className={`w-10 h-10 rounded-full flex items-center justify-center ${
                    step.done ? "bg-primary/10" : "bg-muted"
                  }`}
                >
                  <Icon className={`w-5 h-5 ${step.done ? "text-green-600" : "text-blue-600"}`} />
                </div>
                <p className="text-xs font-medium text-foreground">{step.label}</p>
              </div>
            );
          })}
        </div>

        <Card className="glass-card mb-6">
          <CardHeader>
            <CardTitle className="font-display text-lg">Tell us about your role</CardTitle>
            <CardDescription>
              This helps us create a personalized training experience tailored to your context
            </CardDescription>
          </CardHeader>

          <form onSubmit={handleSubmit}>
            <CardContent className="space-y-5">
              {/* Region */}
              <div className="space-y-2">
                <Label htmlFor="region" className="flex items-center gap-2">
                  <MapPin className="w-4 h-4 text-blue-600" />
                  Region *
                </Label>
                <select
                  id="region"
                  value={region}
                  onChange={(e) => setRegion(e.target.value)}
                  required
                  className="w-full px-3 py-2 border border-input rounded-md bg-background text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="">Select your region...</option>
                  {regions.map((r) => (
                    <option key={r.value} value={r.value}>
                      {r.label}
                    </option>
                  ))}
                </select>
              </div>

              {/* Sub-Region (only for Islamabad) */}
              {region === "islamabad" && (
                <div className="space-y-2">
                  <Label htmlFor="subRegion" className="flex items-center gap-2">
                    <MapPin className="w-4 h-4 text-purple-600" />
                    Sub-Region *
                  </Label>
                  <select
                    id="subRegion"
                    value={subRegion}
                    onChange={(e) => setSubRegion(e.target.value)}
                    required
                    className="w-full px-3 py-2 border border-input rounded-md bg-background text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                  >
                    <option value="">Select your sub-region...</option>
                    {SUB_REGIONS.map((sr) => (
                      <option key={sr} value={sr}>
                        {sr}
                      </option>
                    ))}
                  </select>
                  <p className="text-xs text-muted-foreground">
                    Choose the sub-region where you work
                  </p>
                </div>
              )}

              {/* School */}
              <div className="space-y-2">
                <Label htmlFor="school" className="flex items-center gap-2">
                  <Building2 className="w-4 h-4 text-green-600" />
                  School Name <span className="text-muted-foreground font-normal text-xs">(Optional)</span>
                </Label>
                <Input
                  id="school"
                  placeholder="Enter your school name"
                  value={school}
                  onChange={(e) => setSchool(e.target.value)}
                />
                <p className="text-xs text-muted-foreground">
                  This helps us understand your school context and provide relevant training
                </p>
              </div>

              {/* Teachers */}
              <div className="space-y-2">
                <Label htmlFor="teachers" className="flex items-center gap-2">
                  <Users className="w-4 h-4 text-purple-600" />
                  Teachers You Coach (Optional)
                </Label>
                <Input
                  id="teachers"
                  placeholder="Enter teacher names separated by commas"
                  value={teachers}
                  onChange={(e) => setTeachers(e.target.value)}
                />
                <p className="text-xs text-muted-foreground">
                  E.g., "Ahmed Khan, Fatima Ahmed, Hassan Ali" (you can add more later)
                </p>
              </div>

              {/* Qualifications */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <Label className="flex items-center gap-2">
                    <GraduationCap className="w-4 h-4 text-indigo-600" />
                    Qualifications <span className="text-muted-foreground font-normal text-xs">(Optional)</span>
                  </Label>
                  <Button type="button" variant="outline" size="sm" onClick={addQualification}>
                    + Add Qualification
                  </Button>
                </div>
                {qualifications.length === 0 && (
                  <p className="text-xs text-muted-foreground">No qualifications added yet.</p>
                )}
                {qualifications.map((q, idx) => (
                  <div key={idx} className="border border-border rounded-md p-3 space-y-2 bg-muted/30">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold text-muted-foreground">Qualification {idx + 1}</span>
                      <button type="button" onClick={() => removeQualification(idx)} className="text-muted-foreground hover:text-destructive text-lg leading-none">×</button>
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
                        <Input className="mt-1" placeholder="e.g. Education" value={q.degree} onChange={(e) => updateQualification(idx, "degree", e.target.value)} />
                      </div>
                      <div>
                        <Label className="text-xs">Passing Year</Label>
                        <Input className="mt-1" placeholder="e.g. 2018" maxLength={4} value={q.passing_year} onChange={(e) => updateQualification(idx, "passing_year", e.target.value)} />
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              {/* Experiences */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <Label className="flex items-center gap-2">
                    <Building2 className="w-4 h-4 text-orange-600" />
                    Work Experience <span className="text-muted-foreground font-normal text-xs">(Optional)</span>
                  </Label>
                  <Button type="button" variant="outline" size="sm" onClick={addExperience}>
                    + Add Experience
                  </Button>
                </div>
                {experiences.length === 0 && (
                  <p className="text-xs text-muted-foreground">No experience added yet.</p>
                )}
                {experiences.map((exp, idx) => (
                  <div key={idx} className="border border-border rounded-md p-3 space-y-2 bg-muted/30">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold text-muted-foreground">Experience {idx + 1}</span>
                      <button type="button" onClick={() => removeExperience(idx)} className="text-muted-foreground hover:text-destructive text-lg leading-none">×</button>
                    </div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                      <div>
                        <Label className="text-xs">Organisation</Label>
                        <Input className="mt-1" placeholder="e.g. Taleemabad" value={exp.org} onChange={(e) => updateExperience(idx, "org", e.target.value)} />
                      </div>
                      <div>
                        <Label className="text-xs">Designation</Label>
                        <Input className="mt-1" placeholder="e.g. Head Teacher" value={exp.designation} onChange={(e) => updateExperience(idx, "designation", e.target.value)} />
                      </div>
                      <div>
                        <Label className="text-xs">Joining (YYYY-MM)</Label>
                        <Input className="mt-1" placeholder="e.g. 2020-06" value={exp.joining} onChange={(e) => updateExperience(idx, "joining", e.target.value)} />
                      </div>
                      {!exp.current && (
                        <div>
                          <Label className="text-xs">Leaving (YYYY-MM)</Label>
                          <Input className="mt-1" placeholder="e.g. 2023-12" value={exp.leaving} onChange={(e) => updateExperience(idx, "leaving", e.target.value)} />
                        </div>
                      )}
                    </div>
                    <div className="flex items-center gap-2 mt-1">
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
              </div>

              {/* Info box */}
              <div className="bg-muted p-4 rounded-lg border border-border">
                <p className="text-sm font-semibold text-foreground mb-2">Why we need this info:</p>
                <ul className="text-xs text-muted-foreground space-y-1">
                  <li>✓ Personalize your training to your school context</li>
                  <li>✓ Create relevant observation templates</li>
                  <li>✓ Generate contextual reports</li>
                  <li>✓ Track impact across your school</li>
                </ul>
              </div>
            </CardContent>

            <div className="px-6 pb-6 flex flex-col gap-3">
              <Button type="submit" className="w-full" disabled={loading || !user} size="lg">
                {loading ? "Setting up..." : "Complete Profile & Start Training"}
              </Button>
              <p className="text-xs text-muted-foreground text-center">
                You can update this information anytime in your settings
              </p>
            </div>
          </form>
        </Card>
      </div>
    </div>
  );
}
