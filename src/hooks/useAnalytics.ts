import { useCallback } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/contexts/AuthContext";

export type AnalyticsEventType =
  | "scenario_viewed"
  | "decision_submitted"
  | "feedback_viewed"
  | "read_more_clicked"
  | "tab_visible"
  | "tab_hidden";

export interface TrackEventParams {
  event_type: AnalyticsEventType;
  scenario_id?: string;
  unit_id?: string;
  metadata?: Record<string, unknown>;
}

/**
 * useAnalytics hook for fire-and-forget event tracking.
 * Events are logged to the analytics_events table.
 * This hook silently handles failures and never throws errors.
 */
export function useAnalytics() {
  const { user } = useAuth();

  const track = useCallback(
    ({ event_type, scenario_id, unit_id, metadata }: TrackEventParams) => {
      if (!user) return;

      // Fire-and-forget: do not await or surface errors to caller
      supabase
        .from("analytics_events")
        .insert({
          user_id: user.id,
          event_type,
          scenario_id: scenario_id ?? null,
          unit_id: unit_id ?? null,
          metadata: metadata ?? {},
        } as Record<string, unknown>) // Use type assertion for new table until full sync
        .then(({ error }) => {
          if (error) {
            console.warn("[analytics]", error.message);
          }
        });
    },
    [user]
  );

  return { track };
}
