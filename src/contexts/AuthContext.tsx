import { createContext, useContext, useEffect, useState, ReactNode } from "react";
import { Session, User, AuthError } from "@supabase/supabase-js";
import { supabase } from "@/integrations/supabase/client";
import { authApiClient, UserProfile } from "@/lib/apiClients/authApiClient";

type Profile = UserProfile;
type SignUpError = AuthError | Error | null;

interface AuthContextType {
  session: Session | null;
  user: User | null;
  profile: Profile | null;
  loading: boolean;
  signUp: (email: string, password: string, phone: string, fullName?: string) => Promise<{ error: SignUpError }>;
  signIn: (email: string, password: string) => Promise<{ error: AuthError | null }>;
  signOut: () => Promise<void>;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchProfile = async (userId: string) => {
    try {
      const data = await authApiClient.getProfile(userId);
      setProfile(data);
    } catch (err: unknown) {
      // Profile not found in PostgreSQL — auto-create for pre-migration Supabase users
      if ((err as { status?: number }).status === 404) {
        try {
          const { data: { session } } = await supabase.auth.getSession();
          const email = session?.user?.email;
          if (email) {
            const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:8000';
            const res = await fetch(`${apiUrl}/api/auth/signup`, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ email, user_id: userId }),
            });
            if (res.ok || res.status === 409) {
              // Profile created or user already exists — retry fetch
              const data = await authApiClient.getProfile(userId);
              setProfile(data);
              return;
            }
          }
        } catch (createErr) {
          console.error("Failed to auto-create profile:", createErr);
        }
      }
      console.error("Failed to fetch profile from backend:", err);
      setProfile(null);
    }
  };

  const refreshProfile = async () => {
    if (user) {
      authApiClient.clearCache();
      await fetchProfile(user.id);
    }
  };

  useEffect(() => {
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (_event, session) => {
        setSession(session);
        setUser(session?.user ?? null);
        if (session?.user) {
          setTimeout(() => fetchProfile(session.user.id), 0);
        } else {
          setProfile(null);
        }
        setLoading(false);
      }
    );

    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      if (session?.user) {
        fetchProfile(session.user.id);
      }
      setLoading(false);
    });

    return () => subscription.unsubscribe();
  }, []);

  const signUp = async (email: string, password: string, phone: string, fullName?: string) => {
    // Step 1: Create the auth user in Supabase
    const { data: signUpData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: window.location.origin,
      },
    });

    if (authError) {
      console.error('Signup error:', {
        message: authError.message,
        status: authError.status,
        details: (authError as Record<string, unknown>).details,
      });
      return { error: authError };
    }

    // Step 2: Create the profile in PostgreSQL via backend API
    if (signUpData.user?.id) {
      const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:8000';

      try {
        const response = await fetch(`${apiUrl}/api/auth/signup`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            email,
            full_name: fullName || null,
            phone,
            user_id: signUpData.user.id,
          }),
        });

        if (!response.ok) {
          const errorData = await response.json();
          const errorMessage = errorData.detail || `API error: ${response.status}`;
          console.error('Profile creation error:', { status: response.status, message: errorMessage });

          if (response.status === 409) {
            return { error: new Error('This phone number is already registered. Please use a different phone number.') };
          }
          if (response.status === 400) {
            return { error: new Error(errorMessage || 'Invalid profile data. Please try again.') };
          }
          return { error: new Error(errorMessage) };
        }

        const profileData = await response.json();
        console.log('Profile created successfully for user:', signUpData.user.id, profileData);
        await fetchProfile(signUpData.user.id);
      } catch (networkError) {
        console.error('Network error during profile creation:', networkError);
        return { error: new Error('Failed to create profile. Please check your connection and try again.') };
      }
    }

    return { error: null };
  };

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    return { error };
  };

  const signOut = async () => {
    await supabase.auth.signOut();
    setProfile(null);
  };

  return (
    <AuthContext.Provider value={{ session, user, profile, loading, signUp, signIn, signOut, refreshProfile }}>
      {children}
    </AuthContext.Provider>
  );
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error("useAuth must be used within AuthProvider");
  return context;
}
