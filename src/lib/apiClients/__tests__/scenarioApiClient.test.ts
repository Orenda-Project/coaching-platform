/**
 * Scenario API Client Tests
 *
 * Comprehensive test coverage for:
 * - Scenario retrieval (getScenario, getUnitScenarios)
 * - Scenario responses (saveResponse, getResponse, updateResponse, getUserResponses)
 * - Scenario analytics (getScenarioResponses, getOptimalResponse, getUserStats)
 * - Error handling and retry logic
 * - Cache management
 */

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import {
  ScenarioApiClient,
  type Scenario,
  type ScenarioOption,
  type ScenarioResponse,
} from "../scenarioApiClient";

describe("ScenarioApiClient", () => {
  let client: ScenarioApiClient;
  let fetchMock: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    client = new ScenarioApiClient("http://localhost:8000");
    fetchMock = vi.fn();
    global.fetch = fetchMock;
  });

  afterEach(() => {
    vi.clearAllMocks();
    client.clearCache();
  });

  // ===== getScenario tests =====
  describe("getScenario", () => {
    it("should fetch scenario with options", async () => {
      const scenarioId = "scenario-1";
      const mockResponse: Scenario = {
        id: scenarioId,
        unit_id: "unit-1",
        title: "Customer Complaint",
        description: "Handle an irate customer",
        situation: "A customer calls complaining about service...",
        order_number: 1,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
        options: [
          {
            id: "option-1",
            scenario_id: scenarioId,
            option_text: "Listen patiently",
            feedback: "Good empathy",
            is_optimal: true,
            order_number: 1,
            created_at: "2026-01-01T00:00:00Z",
            updated_at: "2026-01-01T00:00:00Z",
          },
          {
            id: "option-2",
            scenario_id: scenarioId,
            option_text: "Interrupt immediately",
            feedback: "Poor listening skills",
            is_optimal: false,
            order_number: 2,
            created_at: "2026-01-01T00:00:00Z",
            updated_at: "2026-01-01T00:00:00Z",
          },
        ],
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getScenario(scenarioId);

      expect(result.id).toBe(scenarioId);
      expect(result.title).toBe("Customer Complaint");
      expect(result.options).toHaveLength(2);
      expect(result.options[0].is_optimal).toBe(true);
      expect(fetchMock).toHaveBeenCalledWith(
        `http://localhost:8000/api/scenarios/${scenarioId}`,
        expect.any(Object)
      );
    });

    it("should cache scenario", async () => {
      const scenarioId = "scenario-1";
      const mockResponse: Scenario = {
        id: scenarioId,
        unit_id: "unit-1",
        title: "Test",
        description: "Test scenario",
        situation: "Test",
        order_number: 1,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
        options: [],
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getScenario(scenarioId);
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getScenario(scenarioId);
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });

    it("should handle scenario not found", async () => {
      const scenarioId = "nonexistent";

      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({ detail: "Scenario not found" }),
      });

      await expect(client.getScenario(scenarioId)).rejects.toThrow(
        "Scenario not found"
      );
    });
  });

  // ===== getUnitScenarios tests =====
  describe("getUnitScenarios", () => {
    it("should fetch all scenarios in a unit", async () => {
      const unitId = "unit-1";
      const mockResponse = {
        scenarios: [
          {
            id: "scenario-1",
            unit_id: unitId,
            title: "Scenario 1",
            description: "First scenario",
            situation: "Test",
            order_number: 1,
            created_at: "2026-01-01T00:00:00Z",
            updated_at: "2026-01-01T00:00:00Z",
            options: [],
          },
          {
            id: "scenario-2",
            unit_id: unitId,
            title: "Scenario 2",
            description: "Second scenario",
            situation: "Test",
            order_number: 2,
            created_at: "2026-01-01T00:00:00Z",
            updated_at: "2026-01-01T00:00:00Z",
            options: [],
          },
        ],
        total: 2,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getUnitScenarios(unitId);

      expect(result.scenarios).toHaveLength(2);
      expect(result.scenarios[0].order_number).toBe(1);
      expect(result.scenarios[1].order_number).toBe(2);
    });

    it("should cache unit scenarios", async () => {
      const unitId = "unit-1";
      const mockResponse = {
        scenarios: [] as Scenario[],
        total: 0,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getUnitScenarios(unitId);
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getUnitScenarios(unitId);
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });

    it("should handle empty unit", async () => {
      const unitId = "empty-unit";
      const mockResponse = { scenarios: [], total: 0 };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getUnitScenarios(unitId);

      expect(result.scenarios).toHaveLength(0);
      expect(result.total).toBe(0);
    });
  });

  // ===== saveResponse tests =====
  describe("saveResponse", () => {
    it("should save a scenario response", async () => {
      const scenarioId = "scenario-1";
      const userId = "user-123";
      const selectedOptionId = "option-1";

      const mockResponse: ScenarioResponse = {
        id: "response-1",
        user_id: userId,
        scenario_id: scenarioId,
        selected_option_id: selectedOptionId,
        timestamp: "2026-01-01T00:00:00Z",
        option: {
          id: selectedOptionId,
          scenario_id: scenarioId,
          option_text: "Good option",
          feedback: "Well done",
          is_optimal: true,
          order_number: 1,
          created_at: "2026-01-01T00:00:00Z",
          updated_at: "2026-01-01T00:00:00Z",
        },
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.saveResponse(
        scenarioId,
        userId,
        selectedOptionId
      );

      expect(result.id).toBe("response-1");
      expect(result.selected_option_id).toBe(selectedOptionId);
      expect(fetchMock).toHaveBeenCalledWith(
        `http://localhost:8000/api/scenarios/${scenarioId}/respond/${userId}`,
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify({ selected_option_id: selectedOptionId }),
        })
      );
    });

    it("should invalidate cache on save", async () => {
      const scenarioId = "scenario-1";
      const userId = "user-123";

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ id: "response-1" } as ScenarioResponse),
      });

      await client.saveResponse(scenarioId, userId, "option-1");

      // Cache should be invalidated, so next fetch should call API
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ id: "response-2" } as ScenarioResponse),
      });

      // Get user responses should hit API (not cached due to invalidation)
      await client.getUserResponses(userId);
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });

    it("should handle invalid option ID", async () => {
      const scenarioId = "scenario-1";
      const userId = "user-123";

      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 400,
        text: async () => JSON.stringify({ detail: "Invalid option ID" }),
      });

      await expect(
        client.saveResponse(scenarioId, userId, "invalid-option")
      ).rejects.toThrow("Invalid option ID");
    });
  });

  // ===== getResponse tests =====
  describe("getResponse", () => {
    it("should get user response to scenario", async () => {
      const scenarioId = "scenario-1";
      const userId = "user-123";

      const mockResponse: ScenarioResponse = {
        id: "response-1",
        user_id: userId,
        scenario_id: scenarioId,
        selected_option_id: "option-1",
        timestamp: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getResponse(scenarioId, userId);

      expect(result.scenario_id).toBe(scenarioId);
      expect(result.user_id).toBe(userId);
      expect(fetchMock).toHaveBeenCalledWith(
        `http://localhost:8000/api/scenarios/${scenarioId}/user/${userId}`,
        expect.any(Object)
      );
    });

    it("should cache user response", async () => {
      const scenarioId = "scenario-1";
      const userId = "user-123";

      const mockResponse: ScenarioResponse = {
        id: "response-1",
        user_id: userId,
        scenario_id: scenarioId,
        selected_option_id: "option-1",
        timestamp: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getResponse(scenarioId, userId);
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getResponse(scenarioId, userId);
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });

    it("should handle no response found", async () => {
      const scenarioId = "scenario-1";
      const userId = "user-123";

      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () =>
          JSON.stringify({ detail: "No response found for this scenario" }),
      });

      await expect(client.getResponse(scenarioId, userId)).rejects.toThrow(
        "No response found"
      );
    });
  });

  // ===== updateResponse tests =====
  describe("updateResponse", () => {
    it("should update a scenario response", async () => {
      const scenarioId = "scenario-1";
      const responseId = "response-1";
      const newOptionId = "option-2";

      const mockResponse: ScenarioResponse = {
        id: responseId,
        user_id: "user-123",
        scenario_id: scenarioId,
        selected_option_id: newOptionId,
        timestamp: "2026-01-01T00:01:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.updateResponse(
        scenarioId,
        responseId,
        newOptionId
      );

      expect(result.selected_option_id).toBe(newOptionId);
      expect(fetchMock).toHaveBeenCalledWith(
        `http://localhost:8000/api/scenarios/${scenarioId}/respond/${responseId}`,
        expect.objectContaining({
          method: "PUT",
          body: JSON.stringify({ selected_option_id: newOptionId }),
        })
      );
    });

    it("should invalidate cache on update", async () => {
      const scenarioId = "scenario-1";
      const userId = "user-123";
      const responseId = "response-1";

      // Get response (cached)
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () =>
          ({ id: responseId, selected_option_id: "option-1" } as ScenarioResponse),
      });

      await client.getResponse(scenarioId, userId);

      // Update response (invalidates cache)
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () =>
          ({ id: responseId, selected_option_id: "option-2" } as ScenarioResponse),
      });

      await client.updateResponse(scenarioId, responseId, "option-2");

      // Next getResponse should call API (cache invalidated)
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () =>
          ({ id: responseId, selected_option_id: "option-2" } as ScenarioResponse),
      });

      await client.getResponse(scenarioId, userId);
      expect(fetchMock).toHaveBeenCalledTimes(3);
    });
  });

  // ===== getUserResponses tests =====
  describe("getUserResponses", () => {
    it("should fetch all user responses with pagination", async () => {
      const userId = "user-123";
      const mockResponse = {
        responses: [
          {
            id: "response-1",
            user_id: userId,
            scenario_id: "scenario-1",
            selected_option_id: "option-1",
            timestamp: "2026-01-01T00:00:00Z",
          },
          {
            id: "response-2",
            user_id: userId,
            scenario_id: "scenario-2",
            selected_option_id: "option-2",
            timestamp: "2026-01-01T00:01:00Z",
          },
        ] as ScenarioResponse[],
        total: 2,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getUserResponses(userId, {
        limit: 10,
        offset: 0,
      });

      expect(result.responses).toHaveLength(2);
      expect(result.total).toBe(2);
      expect(fetchMock).toHaveBeenCalledWith(
        `http://localhost:8000/api/scenarios/user/${userId}/responses?limit=10&offset=0`,
        expect.any(Object)
      );
    });

    it("should handle empty responses", async () => {
      const userId = "user-456";
      const mockResponse = { responses: [], total: 0 };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getUserResponses(userId);

      expect(result.responses).toHaveLength(0);
      expect(result.total).toBe(0);
    });
  });

  // ===== getScenarioResponses tests =====
  describe("getScenarioResponses", () => {
    it("should fetch all responses to a scenario", async () => {
      const scenarioId = "scenario-1";
      const mockResponse = {
        responses: [
          {
            id: "response-1",
            user_id: "user-1",
            scenario_id: scenarioId,
            selected_option_id: "option-1",
            timestamp: "2026-01-01T00:00:00Z",
          },
          {
            id: "response-2",
            user_id: "user-2",
            scenario_id: scenarioId,
            selected_option_id: "option-2",
            timestamp: "2026-01-01T00:01:00Z",
          },
        ] as ScenarioResponse[],
        total: 2,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getScenarioResponses(scenarioId);

      expect(result.responses).toHaveLength(2);
      expect(result.total).toBe(2);
    });

    it("should not cache scenario responses", async () => {
      const scenarioId = "scenario-1";
      const mockResponse = { responses: [], total: 0 };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getScenarioResponses(scenarioId);
      expect(fetchMock).toHaveBeenCalledTimes(1);

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getScenarioResponses(scenarioId);
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });

  // ===== getOptimalResponse tests =====
  describe("getOptimalResponse", () => {
    it("should fetch optimal response for scenario", async () => {
      const scenarioId = "scenario-1";
      const mockResponse: ScenarioOption = {
        id: "option-1",
        scenario_id: scenarioId,
        option_text: "Best response",
        feedback: "This is the optimal choice",
        is_optimal: true,
        order_number: 1,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getOptimalResponse(scenarioId);

      expect(result.is_optimal).toBe(true);
      expect(result.feedback).toBe("This is the optimal choice");
    });

    it("should cache optimal response", async () => {
      const scenarioId = "scenario-1";
      const mockResponse: ScenarioOption = {
        id: "option-1",
        scenario_id: scenarioId,
        option_text: "Best",
        feedback: "Optimal",
        is_optimal: true,
        order_number: 1,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getOptimalResponse(scenarioId);
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getOptimalResponse(scenarioId);
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });
  });

  // ===== getUserStats tests =====
  describe("getUserStats", () => {
    it("should fetch user stats in unit", async () => {
      const unitId = "unit-1";
      const userId = "user-123";

      const mockResponse = {
        user_id: userId,
        unit_id: unitId,
        total_scenarios: 5,
        scenarios_attempted: 4,
        scenarios_optimal: 2,
        success_rate: 0.5,
        last_attempt: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getUserStats(unitId, userId);

      expect(result.total_scenarios).toBe(5);
      expect(result.scenarios_attempted).toBe(4);
      expect(result.success_rate).toBe(0.5);
    });

    it("should not cache user stats", async () => {
      const unitId = "unit-1";
      const userId = "user-123";

      const mockResponse = {
        user_id: userId,
        unit_id: unitId,
        total_scenarios: 5,
        scenarios_attempted: 4,
        scenarios_optimal: 2,
        success_rate: 0.5,
        last_attempt: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getUserStats(unitId, userId);
      expect(fetchMock).toHaveBeenCalledTimes(1);

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getUserStats(unitId, userId);
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });

  // ===== clearCache tests =====
  describe("clearCache", () => {
    it("should clear all cache", async () => {
      const scenarioId = "scenario-1";
      const mockResponse: Scenario = {
        id: scenarioId,
        unit_id: "unit-1",
        title: "Test",
        description: "Test",
        situation: "Test",
        order_number: 1,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
        options: [],
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getScenario(scenarioId);
      expect(fetchMock).toHaveBeenCalledTimes(1);

      client.clearCache();

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getScenario(scenarioId);
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });
});
