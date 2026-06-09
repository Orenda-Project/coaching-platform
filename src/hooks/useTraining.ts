/**
 * useTraining - React hook for training state management
 *
 * Manages:
 * - Training state (trainings, progress, loading, error)
 * - Training lifecycle (load, update progress, mark complete)
 * - Automatic error handling
 * - User-friendly error messages
 *
 * Usage:
 *   const { trainings, progress, loading, loadTrainings, updateProgress } = useTraining();
 *   await loadTrainings();
 *   await updateProgress("user-123", "training-1", { progress_percentage: 50 });
 */

import { useState, useCallback } from "react";
import {
  trainingApiClient,
  type Training,
  type UserProgress,
  type ApiError,
} from "@/lib/apiClients/trainingApiClient";

export interface UseTrainingState {
  trainings: Training[];
  progress: UserProgress | null;
  loading: boolean;
  error: ApiError | null;
}

export interface UseTrainingActions {
  loadTrainings: () => Promise<void>;
  updateProgress: (userId: string, trainingId: string, progress: Partial<UserProgress>) => Promise<void>;
  markTrainingComplete: (userId: string, trainingId: string) => Promise<void>;
  clearError: () => void;
  clearCache: () => void;
}

/**
 * Hook for training state management and API interactions
 *
 * Provides state management for training data, progress tracking, loading, and errors,
 * along with methods to perform training operations.
 */
export function useTraining(): UseTrainingState & UseTrainingActions {
  const [trainings, setTrainings] = useState<Training[]>([]);
  const [progress, setProgress] = useState<UserProgress | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<ApiError | null>(null);

  /**
   * Load all trainings
   */
  const loadTrainings = useCallback(async (): Promise<void> => {
    try {
      setLoading(true);
      setError(null);

      const data = await trainingApiClient.getTrainings();
      setTrainings(data);
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setError(apiError as ApiError);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  /**
   * Update training progress for a user
   */
  const updateProgress = useCallback(
    async (userId: string, trainingId: string, progressData: Partial<UserProgress>): Promise<void> => {
      try {
        setLoading(true);
        setError(null);

        const updated = await trainingApiClient.updateProgress(userId, trainingId, progressData);
        setProgress(updated);
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
   * Mark training as complete for a user
   */
  const markTrainingComplete = useCallback(
    async (userId: string, trainingId: string): Promise<void> => {
      try {
        setLoading(true);
        setError(null);

        const completed = await trainingApiClient.markComplete(userId, trainingId);
        setProgress(completed);
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
    trainingApiClient.clearCache();
  }, []);

  return {
    trainings,
    progress,
    loading,
    error,
    loadTrainings,
    updateProgress,
    markTrainingComplete,
    clearError,
    clearCache,
  };
}
