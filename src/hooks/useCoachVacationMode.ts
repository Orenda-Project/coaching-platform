import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";

interface VacationModeStatus {
  isVacationModeActive: boolean;
  loading: boolean;
  error: string | null;
}

/**
 * Hook to check if coach vacation mode is active.
 *
 * When vacation_mode_active = true:
 *   - Coaches see ALL 6 modules (vacation engagement)
 *
 * When vacation_mode_active = false:
 *   - Coaches see persona-based trainings only (Module 1 + weak_modules)
 *
 * Coach role itself stays in user_roles table (never deleted).
 * This flag only controls Dashboard filtering logic.
 */
export const useCoachVacationMode = (): VacationModeStatus => {
  const [isVacationModeActive, setIsVacationModeActive] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const checkVacationMode = async () => {
      try {
        const { data, error: dbError } = await supabase
          .from("coach_vacation_config")
          .select("vacation_mode_active")
          .eq("id", 1)
          .single();

        if (dbError) {
          console.warn("Failed to fetch vacation mode config:", dbError.message);
          setError(dbError.message);
          setIsVacationModeActive(false);
        } else if (data) {
          setIsVacationModeActive(data.vacation_mode_active ?? false);
        }
      } catch (err) {
        const message = err instanceof Error ? err.message : "Unknown error";
        console.warn("Coach vacation mode check failed:", message);
        setError(message);
        setIsVacationModeActive(false);
      } finally {
        setLoading(false);
      }
    };

    checkVacationMode();
  }, []);

  return { isVacationModeActive, loading, error };
};
