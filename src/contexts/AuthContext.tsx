import { createContext, useContext, useEffect, useState, ReactNode } from "react";
import { Session, User, AuthError } from "@supabase/supabase-js";
import { supabase } from "@/integrations/supabase/client";
import { Tables } from "@/integrations/supabase/types";

type Profile = Tables<"profiles">;
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
    const { data } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", userId)
      .single();
    setProfile(data);
  };

  const refreshProfile = async () => {
    if (user) await fetchProfile(user.id);
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
    // Uses the REST API endpoint which queries PostgreSQL directly
    // This ensures PostgreSQL is the single source of truth for user profiles
    if (signUpData.user?.id) {
      const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:8000';

      try {
        const response = await fetch(`${apiUrl}/api/auth/signup`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            email,
            full_name: fullName || null,
            phone,
          }),
        });

        if (!response.ok) {
          const errorData = await response.json();
          const errorMessage = errorData.detail || `API error: ${response.status}`;
          console.error('Profile creation error:', {
            status: response.status,
            message: errorMessage,
          });

          // Handle specific HTTP errors
          if (response.status === 409) {
            const userFriendlyError = new Error('This phone number is already registered. Please use a different phone number.');
            return { error: userFriendlyError };
          }
          if (response.status === 400) {
            const userFriendlyError = new Error(errorMessage || 'Invalid profile data. Please try again.');
            return { error: userFriendlyError };
          }

          const apiError = new Error(errorMessage);
          return { error: apiError };
        }

        const profileData = await response.json();
        console.log('Profile created successfully for user:', signUpData.user.id, profileData);

        // Fetch the profile to populate the context
        await fetchProfile(signUpData.user.id);
      } catch (networkError) {
        console.error('Network error during profile creation:', networkError);
        const error = new Error('Failed to create profile. Please check your connection and try again.');
        return { error };
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
