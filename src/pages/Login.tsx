import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { toast } from "sonner";
import { GraduationCap, Eye, EyeOff } from "lucide-react";
//test
//test - Login page main component
export default function Login() {
  //test - Email and password state management
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  //test - Forgot password and visibility state
  const [forgotMode, setForgotMode] = useState(false);
  const [resetSent, setResetSent] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  //test - Get auth sign in method and navigation
  const { signIn } = useAuth();
  const navigate = useNavigate();

  //test - Handle form submission for login
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    //test - Validate email and password fields
    if (!email.trim() || !password.trim()) {
      toast.error("Please fill in all fields");
      return;
    }
    setLoading(true);
    //test - Call signIn and handle response
    const { error } = await signIn(email, password);
    setLoading(false);
    //test - Check for authentication error
    if (error) {
      toast.error(error.message);
    } else {
      //test - Navigate to dashboard on success
      navigate("/dashboard");
    }
  };

  //test - Handle forgot password flow
  const handleForgotPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    //test - Validate email for password reset
    if (!email.trim()) {
      toast.error("Please enter your email address");
      return;
    }
    setLoading(true);
    //test - Call Supabase password reset API
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`,
    });
    setLoading(false);
    //test - Handle password reset response
    if (error) {
      toast.error(error.message);
    } else {
      //test - Show success message
      setResetSent(true);
    }
  };

  //test - Render forgot password view when in forgot mode
  if (forgotMode) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background p-4">
        <div className="w-full max-w-md animate-fade-in">
          {/* //test - Branding section */}
          <div className="flex items-center justify-center gap-2 mb-8">
            <div className="w-12 h-12 rounded-xl bg-primary flex items-center justify-center">
              <GraduationCap className="w-7 h-7 text-primary-foreground" />
            </div>
            <h1 className="text-2xl font-display font-bold text-foreground">RABT</h1>
          </div>
          {/* //test - Reset password card */}
          <Card className="glass-card">
            <CardHeader className="text-center">
              <CardTitle className="font-display text-xl">Reset Password</CardTitle>
              <CardDescription>Enter your email to receive a reset link</CardDescription>
            </CardHeader>
            {/* //test - Show success message or reset form */}
            {resetSent ? (
              <CardContent>
                <p className="text-sm text-center text-muted-foreground">
                  ✅ Check your inbox for a password reset link. Click it to set a new password.
                </p>
              </CardContent>
            ) : (
              <form onSubmit={handleForgotPassword}>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="email">Email</Label>
                    <Input
                      id="email"
                      type="email"
                      placeholder="you@example.com"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      required
                    />
                  </div>
                </CardContent>
                <CardFooter className="flex flex-col gap-3">
                  <Button type="submit" className="w-full" disabled={loading}>
                    {loading ? "Sending..." : "Send Reset Link"}
                  </Button>
                  <button
                    type="button"
                    onClick={() => setForgotMode(false)}
                    className="text-sm text-primary hover:underline"
                  >
                    Back to sign in
                  </button>
                </CardFooter>
              </form>
            )}
          </Card>
        </div>
      </div>
    );
  }

  //test - Render main login form
  return (
    <div className="flex min-h-screen items-center justify-center bg-background p-4">
      <div className="w-full max-w-md animate-fade-in">
        {/* //test - Branding header */}
        <div className="flex items-center justify-center gap-2 mb-8">
          <div className="w-12 h-12 rounded-xl bg-primary flex items-center justify-center">
            <GraduationCap className="w-7 h-7 text-primary-foreground" />
          </div>
          <h1 className="text-2xl font-display font-bold text-foreground">RABT</h1>
        </div>
        {/* //test - Login card container */}
        <Card className="glass-card">
          <CardHeader className="text-center">
            <CardTitle className="font-display text-xl">Welcome back</CardTitle>
            <CardDescription>Sign in to continue your training</CardDescription>
          </CardHeader>
          {/* //test - Login form */}
          <form onSubmit={handleSubmit}>
            <CardContent className="space-y-4">
              {/* //test - Email input field */}
              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  placeholder="you@example.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
              {/* //test - Password input field */}
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <Label htmlFor="password">Password</Label>
                  {/* //test - Forgot password button */}
                  <button
                    type="button"
                    onClick={() => setForgotMode(true)}
                    className="text-xs text-primary hover:underline"
                  >
                    Forgot password?
                  </button>
                </div>
                {/* //test - Password visibility toggle */}
                <div className="relative">
                  <Input
                    id="password"
                    type={showPassword ? "text" : "password"}
                    placeholder="••••••••"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    minLength={8}
                    className="pr-10"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((v) => !v)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                    tabIndex={-1}
                  >
                    {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>
            </CardContent>
            {/* //test - Form action buttons */}
            <CardFooter className="flex flex-col gap-3">
              {/* //test - Submit button with loading state */}
              <Button type="submit" className="w-full" disabled={loading}>
                {loading ? "Signing in..." : "Sign In"}
              </Button>
              {/* //test - Sign up link */}
              <p className="text-sm text-muted-foreground">
                Don't have an account?{" "}
                <Link to="/signup" className="text-primary font-medium hover:underline">
                  Sign up
                </Link>
              </p>
            </CardFooter>
          </form>
        </Card>
      </div>
    </div>
  );
}
