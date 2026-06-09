/**
 * useScenario Hook
 *
 * React hook for managing scenario data and responses
 *
 * Features:
 * - Fetch scenario details
 * - Save and update user responses
 * - Retrieve user's response history
 * - Get scenario statistics
 * - Error handling
 *
 * Usage:
 *   const { getScenario, saveResponse, getUserStats } = useScenario(scenarioId, userId);
 *   const scenario = await getScenario();
 *   const response = await saveResponse(selectedOptionId);
 *   const stats = await getUserStats(unitId);
 */

import { useCallback } from "react";
import { scenarioApiClient } from "@/lib/apiClients/scenarioApiClient";
import type {
  Scenario,
  ScenarioOption,
  ScenarioResponse,
  UserStats,
  ScenariosResponse,
  ResponsesResponse,
  PaginationOptions,
} from "@/lib/apiClients/scenarioApiClient";

interface UseScenarioReturn {
  getScenario: () => Promise<Scenario>;
  getUnitScenarios: (unitId: string, options?: PaginationOptions) => Promise<ScenariosResponse>;
  saveResponse: (selectedOptionId: string) => Promise<ScenarioResponse>;
  getResponse: () => Promise<ScenarioResponse>;
  updateResponse: (responseId: string, newOptionId: string) => Promise<ScenarioResponse>;
  getUserResponses: (options?: PaginationOptions) => Promise<ResponsesResponse>;
  getScenarioResponses: (options?: PaginationOptions) => Promise<ResponsesResponse>;
  getOptimalResponse: () => Promise<ScenarioOption>;
  getUserStats: (unitId: string) => Promise<UserStats>;
}

/**
 * Hook for scenario operations
 */
export function useScenario(scenarioId: string, userId: string): UseScenarioReturn {
  /**
   * Get scenario with options
   */
  const getScenario = useCallback(async (): Promise<Scenario> => {
    return scenarioApiClient.getScenario(scenarioId);
  }, [scenarioId]);

  /**
   * Get all scenarios in a unit
   */
  const getUnitScenarios = useCallback(
    async (
      unitId: string,
      options?: PaginationOptions
    ): Promise<ScenariosResponse> => {
      return scenarioApiClient.getUnitScenarios(unitId, options);
    },
    []
  );

  /**
   * Save user response to scenario
   */
  const saveResponse = useCallback(
    async (selectedOptionId: string): Promise<ScenarioResponse> => {
      return scenarioApiClient.saveResponse(scenarioId, userId, selectedOptionId);
    },
    [scenarioId, userId]
  );

  /**
   * Get user's response to this scenario
   */
  const getResponse = useCallback(async (): Promise<ScenarioResponse> => {
    return scenarioApiClient.getResponse(scenarioId, userId);
  }, [scenarioId, userId]);

  /**
   * Update user response
   */
  const updateResponse = useCallback(
    async (responseId: string, newOptionId: string): Promise<ScenarioResponse> => {
      return scenarioApiClient.updateResponse(scenarioId, responseId, newOptionId);
    },
    [scenarioId]
  );

  /**
   * Get all user responses
   */
  const getUserResponses = useCallback(
    async (options?: PaginationOptions): Promise<ResponsesResponse> => {
      return scenarioApiClient.getUserResponses(userId, options);
    },
    [userId]
  );

  /**
   * Get all responses to this scenario
   */
  const getScenarioResponses = useCallback(
    async (options?: PaginationOptions): Promise<ResponsesResponse> => {
      return scenarioApiClient.getScenarioResponses(scenarioId, options);
    },
    [scenarioId]
  );

  /**
   * Get optimal response for scenario
   */
  const getOptimalResponse = useCallback(async (): Promise<ScenarioOption> => {
    return scenarioApiClient.getOptimalResponse(scenarioId);
  }, [scenarioId]);

  /**
   * Get user stats in unit
   */
  const getUserStats = useCallback(
    async (unitId: string): Promise<UserStats> => {
      return scenarioApiClient.getUserStats(unitId, userId);
    },
    [userId]
  );

  return {
    getScenario,
    getUnitScenarios,
    saveResponse,
    getResponse,
    updateResponse,
    getUserResponses,
    getScenarioResponses,
    getOptimalResponse,
    getUserStats,
  };
}
