import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { Button } from "@/components/ui/button";
import { GraduationCap, ArrowRight, Award, BookOpen, CheckCircle2 } from "lucide-react";

export default function Index() {
  const { session, loading } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!loading && session) {
      navigate("/dashboard");
    }
  }, [session, loading]); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <div className="min-h-screen bg-background">
      {/* Hero */}
      <div className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-primary/5 via-transparent to-secondary/5" />
        <div className="container px-4 py-20 md:py-32 relative">
          <div className="max-w-2xl mx-auto text-center animate-fade-in">
            <div className="flex items-center justify-center gap-3 mb-6">
              <div className="w-14 h-14 rounded-2xl bg-primary flex items-center justify-center">
                <GraduationCap className="w-8 h-8 text-primary-foreground" />
              </div>
            </div>
            <h1 className="text-4xl md:text-5xl font-display font-bold text-foreground mb-4 tracking-tight">
              Coach Training &<br />Certification Platform
            </h1>
            <p className="text-lg text-muted-foreground mb-8 max-w-lg mx-auto">
              Complete your personalized training journey, pass assessments, and earn your coaching certification.
            </p>
            <div className="flex items-center justify-center gap-3">
              <Button size="lg" onClick={() => navigate("/signup")}>
                Get Started <ArrowRight className="w-4 h-4 ml-1" />
              </Button>
              <Button variant="outline" size="lg" onClick={() => navigate("/login")}>
                Sign In
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Features */}
      <div className="container px-4 py-16">
        <div className="grid md:grid-cols-3 gap-6 max-w-4xl mx-auto">
          {[
            { icon: BookOpen, title: "Personalized Training", desc: "Modules tailored to your skill level with slides, audio, and video formats." },
            { icon: CheckCircle2, title: "Rigorous Assessment", desc: "Baseline & endline assessments with persona-based learning paths." },
            { icon: Award, title: "Earn Your Certificate", desc: "Downloadable PDF certificate upon successful completion." },
          ].map(({ icon: Icon, title, desc }, i) => (
            <div
              key={title}
              className="text-center p-6 rounded-xl glass-card animate-fade-in"
              style={{ animationDelay: `${i * 0.15}s` }}
            >
              <div className="w-12 h-12 rounded-xl bg-accent flex items-center justify-center mx-auto mb-4">
                <Icon className="w-6 h-6 text-accent-foreground" />
              </div>
              <h3 className="font-display font-semibold text-foreground mb-2">{title}</h3>
              <p className="text-sm text-muted-foreground">{desc}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Footer */}
      <footer className="border-t border-border py-8">
        <div className="container px-4 text-center">
          <p className="text-sm text-muted-foreground">© 2026 RABT. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
