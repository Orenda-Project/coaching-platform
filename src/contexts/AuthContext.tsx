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
    // Step 1: Create the auth user
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

    // Step 2: Create the profile row using RPC function with elevated privileges
    // The RPC function uses SECURITY DEFINER to bypass RLS, allowing profile creation
    // immediately after signup even before email verification or session is fully active
    if (signUpData.user?.id) {
      // Give the database a moment to fully create the auth user
      await new Promise(resolve => setTimeout(resolve, 500));

      // Call RPC function that uses SECURITY DEFINER (bypasses RLS)
      const { data: profileData, error: profileError } = await supabase.rpc(
        'create_profile_after_signup',
        {
          user_id: signUpData.user.id,
          phone_value: phone,
          full_name_value: fullName || null,
        }
      );

      if (profileError) {
        console.error('Profile creation error:', {
          message: profileError.message,
          code: (profileError as Record<string, unknown>).code,
          details: (profileError as Record<string, unknown>).details,
        });

        // Handle specific database errors
        const code = (profileError as Record<string, unknown>).code;
        if (code === '23505') {
          // Duplicate key violation
          const message = profileError.message || '';
          if (message.includes('phone')) {
            const userFriendlyError = new Error('This phone number is already registered. Please use a different phone number.');
            return { error: userFriendlyError };
          }
          if (message.includes('profiles_pkey') || message.includes('id')) {
            // This shouldn't happen but handle gracefully
            const userFriendlyError = new Error('An account with this information already exists. Please try again.');
            return { error: userFriendlyError };
          }
        }

        return { error: profileError };
      }

      console.log('Profile created successfully for user:', signUpData.user.id, profileData);
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
