import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/contexts/AuthContext";

export function useCoachRole() {
  const { user } = useAuth();
  const [isCoach, setIsCoach] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) {
      setLoading(false);
      return;
    }

    supabase
      .from("user_roles")
      .select("role")
      .eq("user_id", user.id)
      .eq("role", "coach")
      .maybeSingle()
      .then(({ data, error }) => {
        if (error) {
          // Migration 20260515000004 may not be applied yet
          // Error: "invalid input value for enum app_role: 'coach'"
          console.warn('Coach role check failed (migration may not be applied):', error.message);
        }
        setIsCoach(!!data);
        setLoading(false);
      })
      .catch((err) => {
        console.warn('Coach role query error:', err.message);
        setLoading(false);
      });
  }, [user]);

  return { isCoach, loading };
}
