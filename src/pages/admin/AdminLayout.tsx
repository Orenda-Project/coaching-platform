import { Link, Outlet, useLocation, useNavigate } from "react-router-dom";
import { GraduationCap, ClipboardList, HelpCircle, ArrowLeft, Shield, Layers, Database, MapPin, BarChart2, MessageCircle, Menu, X, AlertCircle } from "lucide-react";
import { cn } from "@/lib/utils";
import { useAdminRole } from "@/hooks/useAdminRole";
import { useState } from "react";

const navItems = [
  { label: "Analytics", icon: BarChart2, path: "/admin/analytics" },
  { label: "Feedback", icon: MessageCircle, path: "/admin/feedback" },
  { label: "Field Issues", icon: AlertCircle, path: "/admin/field-issues" },
  { label: "Baseline Questions", icon: ClipboardList, path: "/admin/baseline-questions" },
  { label: "Modules", icon: Layers, path: "/admin/modules" },
  { label: "Quiz Questions", icon: HelpCircle, path: "/admin/quiz-questions" },
  { label: "Regions", icon: MapPin, path: "/admin/regions" },
  { label: "Seed Data", icon: Database, path: "/admin/seed" },
];

export default function AdminLayout() {
  const { isAdmin, loading } = useAdminRole();
  const location = useLocation();
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  if (loading) return (
    <div className="flex min-h-screen items-center justify-center bg-background">
      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
    </div>
  );

  if (!isAdmin) return (
    <div className="flex min-h-screen items-center justify-center bg-background flex-col gap-4">
      <Shield className="w-16 h-16 text-muted-foreground" />
      <h1 className="text-2xl font-display font-bold text-foreground">Access Denied</h1>
      <p className="text-muted-foreground">You don't have admin privileges.</p>
      <button onClick={() => navigate("/dashboard")} className="text-primary underline">Go to Dashboard</button>
    </div>
  );

  const isActive = (path: string) => location.pathname === path || location.pathname.startsWith(path + "/");

  return (
    <div className="h-screen bg-background flex flex-col md:flex-row">
      {/* Mobile Header */}
      <div className="md:hidden bg-card border-b border-border p-4 flex items-center justify-between flex-shrink-0">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
            <GraduationCap className="w-4 h-4 text-primary-foreground" />
          </div>
          <div>
            <p className="font-display font-bold text-sm text-foreground">RABT Admin</p>
          </div>
        </div>
        <button
          onClick={() => setSidebarOpen(!sidebarOpen)}
          className="p-2 hover:bg-accent rounded-lg transition-colors"
        >
          {sidebarOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
        </button>
      </div>

      {/* Sidebar - Collapsible on mobile, fixed on desktop */}
      <aside
        className={cn(
          "absolute md:static top-16 left-0 right-0 md:top-0 w-full md:w-64 md:h-screen bg-card border-b md:border-b-0 md:border-r border-border flex flex-col transition-all duration-300",
          sidebarOpen ? "flex" : "hidden md:flex"
        )}
      >
        <div className="hidden md:flex p-4 border-b border-border items-center gap-2 flex-shrink-0">
          <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
            <GraduationCap className="w-4 h-4 text-primary-foreground" />
          </div>
          <div>
            <p className="font-display font-bold text-sm text-foreground">RABT</p>
            <p className="text-xs text-muted-foreground">Admin Panel</p>
          </div>
        </div>

        <nav className="flex-1 p-3 space-y-1 overflow-y-auto">
          {navItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              onClick={() => setSidebarOpen(false)}
              className={cn(
                "flex items-center gap-3 px-4 py-3 rounded-lg text-sm transition-colors",
                isActive(item.path)
                  ? "bg-primary text-primary-foreground font-medium"
                  : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
              )}
            >
              <item.icon className="w-5 h-5 shrink-0" />
              <span>{item.label}</span>
            </Link>
          ))}
        </nav>

        <div className="p-3 border-t border-border flex-shrink-0">
          <Link
            to="/dashboard"
            onClick={() => setSidebarOpen(false)}
            className="flex items-center gap-2 px-4 py-3 rounded-lg text-sm text-muted-foreground hover:bg-accent hover:text-accent-foreground transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
            <span>Back to Dashboard</span>
          </Link>
        </div>
      </aside>

      <main className="flex-1 p-4 md:p-8 overflow-y-auto">
        <Outlet />
      </main>
    </div>
  );
}
