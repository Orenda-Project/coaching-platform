/**
 * useAssessment - React hook for assessment state management
 *
 * Manages:
 * - Assessment state (assessment, responses, loading, error)
 * - Assessment lifecycle (load, submit, history)
 * - Automatic error handling
 * - User-friendly error messages
 *
 * Usage:
 *   const { assessment, loading, error, loadAssessment, submitAssessment } = useAssessment();
 *   await loadAssessment("assessment-123");
 *   await submitAssessment("assessment-123", responses);
 */

import { useState, useCallback } from "react";
import {
  assessmentApiClient,
  type Assessment,
  type AssessmentResponse,
  type AssessmentResults,
  type ApiError,
} from "@/lib/apiClients/assessmentApiClient";

export interface UseAssessmentState {
  assessment: Assessment | null;
  loading: boolean;
  error: ApiError | null;
  responses: Record<string, string>;
}

export interface UseAssessmentActions {
  loadAssessment: (assessmentId: string) => Promise<void>;
  submitAssessment: (assessmentId: string, responses: Record<string, string>) => Promise<void>;
  getHistory: (userId: string, limit?: number) => Promise<AssessmentResponse>;
  getResults: (assessmentId: string) => Promise<AssessmentResults>;
  clearError: () => void;
  clearCache: () => void;
}

/**
 * Hook for assessment state management and API interactions
 *
 * Provides state management for assessment data, responses, loading, and errors,
 * along with methods to perform assessment operations.
 */
export function useAssessment(): UseAssessmentState & UseAssessmentActions {
  const [assessment, setAssessment] = useState<Assessment | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<ApiError | null>(null);
  const [responses, setResponses] = useState<Record<string, string>>({});

  /**
   * Load assessment by ID
   */
  const loadAssessment = useCallback(async (assessmentId: string): Promise<void> => {
    try {
      setLoading(true);
      setError(null);

      const data = await assessmentApiClient.getAssessment(assessmentId);
      setAssessment(data);
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setError(apiError as ApiError);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  /**
   * Submit assessment responses
   */
  const submitAssessment = useCallback(
    async (assessmentId: string, assessmentResponses: Record<string, string>): Promise<void> => {
      try {
        setLoading(true);
        setError(null);

        const updated = await assessmentApiClient.submitAssessment(
          assessmentId,
          assessmentResponses
        );

        setAssessment(updated);
        setResponses(assessmentResponses);
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
   * Get assessment history for a user
   */
  const getHistory = useCallback(
    async (userId: string, limit?: number): Promise<AssessmentResponse> => {
      try {
        setLoading(true);
        setError(null);

        return await assessmentApiClient.getAssessmentHistory(userId, limit);
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
   * Get assessment results
   */
  const getResults = useCallback(
    async (assessmentId: string): Promise<AssessmentResults> => {
      try {
        setLoading(true);
        setError(null);

        return await assessmentApiClient.getAssessmentResults(assessmentId);
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
    assessmentApiClient.clearCache();
  }, []);

  return {
    assessment,
    loading,
    error,
    responses,
    loadAssessment,
    submitAssessment,
    getHistory,
    getResults,
    clearError,
    clearCache,
  };
}
