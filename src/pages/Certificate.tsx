import { useEffect, useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { PersonaBadge } from "@/components/PersonaBadge";
import { ArrowLeft, Download, GraduationCap, Award } from "lucide-react";
import { Tables } from "@/integrations/supabase/types";

type Certificate = Tables<"certificates">;

export default function CertificatePage() {
  const navigate = useNavigate();
  const { user, profile } = useAuth();
  const [certificate, setCertificate] = useState<Certificate | null>(null);
  const [loading, setLoading] = useState(true);
  const certRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    loadCertificate();
  }, [user]);

  const loadCertificate = async () => {
    if (!user) return;
    const { data } = await supabase
      .from("certificates")
      .select("*")
      .eq("user_id", user.id)
      .maybeSingle();
    setCertificate(data);
    setLoading(false);
  };

  const handleDownload = () => {
    if (!certRef.current) return;
    // Use print CSS to generate PDF
    const printWindow = window.open("", "_blank");
    if (!printWindow) {
      toast("Please allow popups to download the certificate");
      return;
    }
    printWindow.document.write(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Certificate - CoachCert</title>
        <style>
          @import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300..700&family=DM+Sans:wght@400;500;600;700&display=swap');
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { font-family: 'DM Sans', sans-serif; display: flex; align-items: center; justify-content: center; min-height: 100vh; background: white; }
          .cert { width: 800px; padding: 60px; border: 3px solid #1a2b5c; position: relative; text-align: center; }
          .cert::before { content: ''; position: absolute; inset: 8px; border: 1px solid #d4a843; }
          h1 { font-family: 'Space Grotesk', sans-serif; font-size: 36px; color: #1a2b5c; margin-bottom: 10px; }
          h2 { font-family: 'Space Grotesk', sans-serif; font-size: 24px; color: #333; margin: 20px 0 5px; }
          .name { font-family: 'Space Grotesk', sans-serif; font-size: 32px; color: #1a2b5c; margin: 15px 0; border-bottom: 2px solid #d4a843; display: inline-block; padding-bottom: 5px; }
          .details { color: #666; font-size: 14px; margin: 8px 0; }
          .cert-id { color: #999; font-size: 11px; margin-top: 30px; }
          .icon { font-size: 48px; margin-bottom: 15px; }
          @media print { body { print-color-adjust: exact; } }
        </style>
      </head>
      <body>
        <div class="cert">
          <div class="icon">🏆</div>
          <h1>Certificate of Completion</h1>
          <p class="details">CoachCert Training & Certification Platform</p>
          <h2>This certifies that</h2>
          <div class="name">${profile?.full_name || profile?.phone || "Coach"}</div>
          <p class="details">has successfully completed the Coach Training & Certification Program</p>
          <p class="details">Persona: ${certificate?.persona || profile?.persona || "N/A"} | Score: ${profile?.endline_score ? Math.round(profile.endline_score) + '%' : 'N/A'}</p>
          <p class="details">Date: ${certificate ? new Date(certificate.issued_at).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' }) : new Date().toLocaleDateString()}</p>
          <br/><br/>
          <p class="details">____________________________</p>
          <p class="details">Authorized Signature</p>
          <p class="cert-id">Certificate ID: ${certificate?.certificate_id || 'N/A'}</p>
        </div>
        <script>window.onload = () => { window.print(); }</script>
      </body>
      </html>
    `);
    printWindow.document.close();
  };

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  if (!certificate) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <Card className="glass-card p-8 text-center max-w-md">
          <Award className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
          <h2 className="font-display text-xl font-bold text-foreground mb-2">No Certificate Yet</h2>
          <p className="text-muted-foreground mb-4">Complete all training modules and pass the endline assessment to earn your certificate.</p>
          <Button onClick={() => navigate("/dashboard")}>Back to Dashboard</Button>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b border-border bg-card">
        <div className="container flex items-center justify-between h-16 px-4">
          <div className="flex items-center gap-2">
            <div className="w-9 h-9 rounded-lg bg-primary flex items-center justify-center">
              <GraduationCap className="w-5 h-5 text-primary-foreground" />
            </div>
            <span className="font-display font-bold text-lg text-foreground">CoachCert</span>
          </div>
          <Button variant="ghost" size="sm" onClick={() => navigate("/dashboard")}>
            <ArrowLeft className="w-4 h-4 mr-1" /> Dashboard
          </Button>
        </div>
      </header>

      <main className="container px-4 py-8 max-w-2xl">
        <div className="animate-fade-in">
          <div className="flex items-center justify-between mb-6">
            <h1 className="text-2xl font-display font-bold text-foreground">Your Certificate</h1>
            <Button onClick={handleDownload}>
              <Download className="w-4 h-4 mr-1" /> Download PDF
            </Button>
          </div>

          {/* Certificate preview */}
          <Card className="glass-card overflow-hidden" ref={certRef}>
            <div className="p-8 sm:p-12 text-center border-4 border-primary m-3 relative">
              <div className="absolute inset-2 border border-secondary pointer-events-none" />
              <Award className="w-16 h-16 text-secondary mx-auto mb-4" />
              <h2 className="text-3xl font-display font-bold text-primary mb-2">Certificate of Completion</h2>
              <p className="text-sm text-muted-foreground mb-6">CoachCert Training & Certification Platform</p>
              <p className="text-muted-foreground mb-2">This certifies that</p>
              <h3 className="text-2xl font-display font-bold text-foreground mb-1 border-b-2 border-secondary inline-block pb-1 px-4">
                {profile?.full_name || profile?.phone || "Coach"}
              </h3>
              <p className="text-muted-foreground mt-4 mb-2">
                has successfully completed the Coach Training & Certification Program
              </p>
              <div className="flex items-center justify-center gap-4 mt-4 mb-6">
                {profile?.persona && <PersonaBadge persona={profile.persona} size="md" showDescription />}
                <span className="text-sm text-muted-foreground">
                  Score: {profile?.endline_score ? `${Math.round(profile.endline_score)}%` : "N/A"}
                </span>
              </div>
              <p className="text-sm text-muted-foreground">
                {new Date(certificate.issued_at).toLocaleDateString("en-US", {
                  year: "numeric", month: "long", day: "numeric",
                })}
              </p>
              <div className="mt-8">
                <div className="w-40 border-b border-foreground/30 mx-auto mb-1" />
                <p className="text-xs text-muted-foreground">Authorized Signature</p>
              </div>
              <p className="text-xs text-muted-foreground mt-6">Certificate ID: {certificate.certificate_id}</p>
            </div>
          </Card>
        </div>
      </main>
    </div>
  );
}

function toast(msg: string) {
  // Fallback simple toast
  alert(msg);
}
