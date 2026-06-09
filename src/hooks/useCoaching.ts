/**
 * useCoaching - React hook for coaching/teacher management
 *
 * Manages:
 * - Teacher DC scores retrieval
 * - Loading and error states
 * - Cache management
 *
 * Usage:
 *   const { teachers, loading, error, loadTeachers } = useCoaching();
 *   await loadTeachers("sub-region-name");
 */

import { useState, useCallback } from "react";
import {
  coachingApiClient,
  type TeacherDCScoreRow,
  type ApiError,
} from "@/lib/apiClients/coachingApiClient";

export interface UseCoachingState {
  teachers: TeacherDCScoreRow[];
  loading: boolean;
  error: ApiError | null;
}

export interface UseCoachingActions {
  loadTeachers: (region?: string) => Promise<void>;
  clearError: () => void;
  clearCache: () => void;
}

/**
 * Hook for coaching API interactions
 *
 * Provides state management for teachers list, loading, and errors,
 * along with methods to fetch teacher data.
 */
export function useCoaching(): UseCoachingState & UseCoachingActions {
  const [teachers, setTeachers] = useState<TeacherDCScoreRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<ApiError | null>(null);

  /**
   * Load teachers from a specific region
   */
  const loadTeachers = useCallback(
    async (region?: string): Promise<void> => {
      try {
        setLoading(true);
        setError(null);

        const response = await coachingApiClient.getTeacherDCScores(region);
        setTeachers(response.teachers);
      } catch (err) {
        const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
        setError(apiError as ApiError);
        throw err;
      } finally {
        setLoading(false);
      }
    },
    []
  );

  /**
   * Clear error state
   */
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  /**
   * Clear API cache
   */
  const clearCache = useCallback(() => {
    coachingApiClient.clearCache();
  }, []);

  return {
    teachers,
    loading,
    error,
    loadTeachers,
    clearError,
    clearCache,
  };
}
