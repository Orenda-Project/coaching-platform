import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { toast } from "sonner";
import { GraduationCap, MapPin, Building2, Users, ArrowRight, CheckCircle2 } from "lucide-react";

export default function Onboarding() {
  const navigate = useNavigate();
  const { user, profile, refreshProfile } = useAuth();
  const [region, setRegion] = useState("");
  const [school, setSchool] = useState("");
  const [teachers, setTeachers] = useState("");
  const [loading, setLoading] = useState(false);

  // If already onboarded, redirect to dashboard
  useEffect(() => {
    if (profile?.school_id) {
      navigate("/dashboard");
    }
  }, [profile, navigate]);

  const regions = [
    { value: "north", label: "North" },
    { value: "central", label: "Central" },
    { value: "south", label: "South" },
    { value: "east", label: "East" },
    { value: "west", label: "West" }
  ];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!region.trim() || !school.trim()) {
      toast.error("Region and school are required");
      return;
    }

    if (!user?.id) {
      toast.error("User not authenticated");
      return;
    }

    setLoading(true);
    try {
      const { error } = await supabase
        .from("profiles")
        .update({
          region: region,
          school_id: school,
          teacher_ids: teachers
            .split(",")
            .map((t) => t.trim())
            .filter((t) => t.length > 0),
          updated_at: new Date().toISOString()
        })
        .eq("id", user.id)
        .select();

      if (error) {
        console.error("Onboarding update error:", error);
        throw error;
      }

      toast.success("Onboarding complete! Welcome to CoachCert");
      await refreshProfile();
      navigate("/dashboard");
    } catch (error: any) {
      console.error("Onboarding error:", error);
      toast.error(error.message || "Failed to complete onboarding");
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
            <h1 className="text-2xl font-display font-bold text-foreground">CoachCert</h1>
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
                  Region / Cluster *
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

              {/* School */}
              <div className="space-y-2">
                <Label htmlFor="school" className="flex items-center gap-2">
                  <Building2 className="w-4 h-4 text-green-600" />
                  School Name *
                </Label>
                <Input
                  id="school"
                  placeholder="Enter your school name"
                  value={school}
                  onChange={(e) => setSchool(e.target.value)}
                  required
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
