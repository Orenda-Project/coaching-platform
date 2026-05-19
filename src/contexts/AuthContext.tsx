import { createContext, useContext, useEffect, useState, ReactNode } from "react";
import { Session, User, AuthError } from "@supabase/supabase-js";
import { supabase } from "@/integrations/supabase/client";
import { Tables } from "@/integrations/supabase/types";
//test
//test - Auth context type definitions and context setup
type Profile = Tables<"profiles">;
type SignUpError = AuthError | Error | null;

//test - Auth context interface definition
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

//test - Create auth context
const AuthContext = createContext<AuthContextType | undefined>(undefined);

//test - AuthProvider component for auth state management
export function AuthProvider({ children }: { children: ReactNode }) {
  //test - Session and user state management
  const [session, setSession] = useState<Session | null>(null);
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);

  //test - Fetch user profile from database
  const fetchProfile = async (userId: string) => {
    //test - Query profiles table for user
    const { data } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", userId)
      .single();
    //test - Update profile state
    setProfile(data);
  };

  //test - Refresh profile method
  const refreshProfile = async () => {
    //test - Fetch profile if user is logged in
    if (user) await fetchProfile(user.id);
  };

  //test - Initialize auth state on mount
  useEffect(() => {
    //test - Subscribe to auth state changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (_event, session) => {
        //test - Update session and user state
        setSession(session);
        setUser(session?.user ?? null);
        //test - Fetch profile when user logs in
        if (session?.user) {
          setTimeout(() => fetchProfile(session.user.id), 0);
        } else {
          //test - Clear profile on logout
          setProfile(null);
        }
        setLoading(false);
      }
    );

    //test - Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      if (session?.user) {
        fetchProfile(session.user.id);
      }
      setLoading(false);
    });

    //test - Cleanup subscription on unmount
    return () => subscription.unsubscribe();
  }, []);

  //test - Sign up method with email, password, phone and optional full name
  const signUp = async (email: string, password: string, phone: string, fullName?: string) => {
    //test - Create auth user in Supabase
    // Step 1: Create the auth user
    const { data: signUpData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: window.location.origin,
      },
    });

    //test - Check for auth errors
    if (authError) {
      //test - Log signup error
      console.error('Signup error:', {
        message: authError.message,
        status: authError.status,
        details: (authError as any).details,
      });
      return { error: authError };
    }

    //test - Create profile in database (step 2)
    // Step 2: Create the profile row (no longer handled by trigger)
    // Note: We use admin context here because the user session may not be fully initialized yet
    // The user_id in the insert ensures we're creating the correct profile
    if (signUpData.user?.id) {
      //test - Wait for auth user creation in database
      // Give the database a moment to fully create the auth user
      await new Promise(resolve => setTimeout(resolve, 500));

      //test - Insert user profile
      // Create profile with admin/service role context
      // This bypasses RLS but ensures the profile gets created even if user isn't confirmed yet
      const { error: profileError } = await supabase
        .from('profiles')
        .insert({
          id: signUpData.user.id,
          phone,
          full_name: fullName || null,
        });

      //test - Handle profile creation errors
      if (profileError) {
        //test - Log profile error
        console.error('Profile creation error:', {
          message: profileError.message,
          code: (profileError as any).code,
          details: (profileError as any).details,
        });

        //test - Handle specific database errors
        // Handle specific database errors
        const code = (profileError as any).code;
        if (code === '23505') {
          //test - Handle duplicate key violation
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

      //test - Log successful profile creation
      console.log('Profile created successfully for user:', signUpData.user.id);
    }

    //test - Return success
    return { error: null };
  };

  //test - Sign in method with email and password
  const signIn = async (email: string, password: string) => {
    //test - Authenticate user with Supabase
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    return { error };
  };

  //test - Sign out method to clear auth session
  const signOut = async () => {
    //test - Clear profile and sign out from Supabase
    await supabase.auth.signOut();
    setProfile(null);
  };

  //test - Provide auth context to children
  return (
    //test - AuthContext provider with all auth methods and state
    <AuthContext.Provider value={{ session, user, profile, loading, signUp, signIn, signOut, refreshProfile }}>
      {children}
    </AuthContext.Provider>
  );
}

// eslint-disable-next-line react-refresh/only-export-components
//test - useAuth hook for accessing auth context
export function useAuth() {
  //test - Get auth context from provider
  const context = useContext(AuthContext);
  if (!context) throw new Error("useAuth must be used within AuthProvider");
  return context;
}
