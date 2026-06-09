/**
 * useObservation - React hook for observation management
 *
 * Manages:
 * - Observation list state
 * - Loading and error states
 * - Create, read, update, delete operations
 * - Cache management
 *
 * Usage:
 *   const { observations, loading, error, createObservation } = useObservation();
 *   await createObservation("user-456", "2026-06-09", "Notes");
 */

import { useState, useCallback } from "react";
import {
  observationApiClient,
  type Observation,
  type UpdateObservationPayload,
  type ApiError,
} from "@/lib/apiClients/observationApiClient";

export interface UseObservationState {
  observations: Observation[];
  loading: boolean;
  error: ApiError | null;
}

export interface UseObservationActions {
  loadObservations: (userId: string, limit?: number, offset?: number) => Promise<void>;
  createObservation: (userId: string, date: string, notes: string) => Promise<Observation>;
  updateObservation: (observationId: string, data: UpdateObservationPayload) => Promise<Observation>;
  deleteObservation: (observationId: string) => Promise<void>;
  clearError: () => void;
  clearCache: () => void;
}

/**
 * Hook for observation API interactions
 *
 * Provides state management for observations list, loading, and errors,
 * along with methods to perform CRUD operations.
 */
export function useObservation(): UseObservationState & UseObservationActions {
  const [observations, setObservations] = useState<Observation[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<ApiError | null>(null);

  /**
   * Load all observations for a user
   */
  const loadObservations = useCallback(
    async (userId: string, limit: number = 100, offset: number = 0): Promise<void> => {
      try {
        setLoading(true);
        setError(null);

        const response = await observationApiClient.getUserObservations(userId, limit, offset);
        setObservations(response.observations);
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
   * Create a new observation
   */
  const createObservation = useCallback(
    async (userId: string, date: string, notes: string): Promise<Observation> => {
      try {
        setLoading(true);
        setError(null);

        const newObservation = await observationApiClient.createObservation(
          userId,
          date,
          notes
        );

        // Add to observations list
        setObservations((prev) => [...prev, newObservation]);

        return newObservation;
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
   * Update an observation
   */
  const updateObservation = useCallback(
    async (observationId: string, data: UpdateObservationPayload): Promise<Observation> => {
      try {
        setLoading(true);
        setError(null);

        const updated = await observationApiClient.updateObservation(observationId, data);

        // Update in observations list
        setObservations((prev) =>
          prev.map((obs) => (obs.id === observationId ? updated : obs))
        );

        return updated;
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
   * Delete an observation
   */
  const deleteObservation = useCallback(async (observationId: string): Promise<void> => {
    try {
      setLoading(true);
      setError(null);

      await observationApiClient.deleteObservation(observationId);

      // Remove from observations list
      setObservations((prev) => prev.filter((obs) => obs.id !== observationId));
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setError(apiError as ApiError);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

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
    observationApiClient.clearCache();
  }, []);

  return {
    observations,
    loading,
    error,
    loadObservations,
    createObservation,
    updateObservation,
    deleteObservation,
    clearError,
    clearCache,
  };
}
