/**
 * useScenario Hook Tests
 *
 * Tests for the scenario hook:
 * - Scenario fetching
 * - Response management (save, update, retrieve)
 * - User stats
 * - Error handling
 * - Loading states
 */

/* eslint-disable @typescript-eslint/no-explicit-any */

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import { renderHook } from "@testing-library/react";
import { useScenario } from "../useScenario";
import * as scenarioClient from "../../lib/apiClients/scenarioApiClient";

// Mock the scenario client
vi.mock("../../lib/apiClients/scenarioApiClient");

describe("useScenario", () => {
  const mockUserId = "user-123";
  const mockScenarioId = "scenario-1";
  const mockUnitId = "unit-1";

  const mockScenario = {
    id: mockScenarioId,
    unit_id: mockUnitId,
    title: "Customer Complaint",
    description: "Handle customer",
    situation: "A customer calls...",
    order_number: 1,
    created_at: "2026-01-01T00:00:00Z",
    updated_at: "2026-01-01T00:00:00Z",
    options: [
      {
        id: "option-1",
        scenario_id: mockScenarioId,
        option_text: "Listen",
        feedback: "Good",
        is_optimal: true,
        order_number: 1,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      },
    ],
  };

  const mockResponse = {
    id: "response-1",
    user_id: mockUserId,
    scenario_id: mockScenarioId,
    selected_option_id: "option-1",
    timestamp: "2026-01-01T00:00:00Z",
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  // ===== getScenario tests =====
  describe("getScenario", () => {
    it("should fetch scenario with options", async () => {
      vi.spyOn(scenarioClient, "scenarioApiClient", "get").mockReturnValue({
        getScenario: vi.fn().mockResolvedValue(mockScenario),
      } as any);

      const { result } = renderHook(() => useScenario(mockScenarioId, mockUserId));

      const scenario = await result.current.getScenario();

      expect(scenario.id).toBe(mockScenarioId);
      expect(scenario.options).toHaveLength(1);
    });

    it("should handle fetch errors", async () => {
      const error = new Error("Scenario not found");

      vi.spyOn(scenarioClient, "scenarioApiClient", "get").mockReturnValue({
        getScenario: vi.fn().mockRejectedValue(error),
      } as any);

      const { result } = renderHook(() => useScenario(mockScenarioId, mockUserId));

      await expect(result.current.getScenario()).rejects.toThrow(
        "Scenario not found"
      );
    });
  });

  // ===== getUnitScenarios tests =====
  describe("getUnitScenarios", () => {
    it("should fetch unit scenarios", async () => {
      const mockResponse = {
        scenarios: [mockScenario],
        total: 1,
      };

      vi.spyOn(scenarioClient, "scenarioApiClient", "get").mockReturnValue({
        getUnitScenarios: vi.fn().mockResolvedValue(mockResponse),
      } as any);

      const { result } = renderHook(() => useScenario(mockScenarioId, mockUserId));

      const response = await result.current.getUnitScenarios(mockUnitId);

      expect(response.scenarios).toHaveLength(1);
      expect(response.total).toBe(1);
    });
  });

  // ===== saveResponse tests =====
  describe("saveResponse", () => {
    it("should save a response", async () => {
      vi.spyOn(scenarioClient, "scenarioApiClient", "get").mockReturnValue({
        saveResponse: vi.fn().mockResolvedValue(mockResponse),
      } as any);

      const { result } = renderHook(() => useScenario(mockScenarioId, mockUserId));

      const response = await result.current.saveResponse("option-1");

      expect(response.id).toBe("response-1");
      expect(response.selected_option_id).toBe("option-1");
    });

    it("should handle save errors", async () => {
      const error = new Error("Invalid option");

      vi.spyOn(scenarioClient, "scenarioApiClient", "get").mockReturnValue({
        saveResponse: vi.fn().mockRejectedValue(error),
      } as any);

      const { result } = renderHook(() => useScenario(mockScenarioId, mockUserId));

      await expect(result.current.saveResponse("invalid")).rejects.toThrow(
        "Invalid option"
      );
    });
  });

  // ===== getResponse tests =====
  describe("getResponse", () => {
    it("should fetch user response", async () => {
      vi.spyOn(scenarioClient, "scenarioApiClient", "get").mockReturnValue({
        getResponse: vi.fn().mockResolvedValue(mockResponse),
      } as any);

      const { result } = renderHook(() => useScenario(mockScenarioId, mockUserId));

      const response = await result.current.getResponse();

      expect(response.scenario_id).toBe(mockScenarioId);
      expect(response.user_id).toBe(mockUserId);
    });

    it("should handle not found error", async () => {
      const error = new Error("No response found");

      vi.spyOn(scenarioClient, "scenarioApiClient", "get").mockReturnValue({
        getResponse: vi.fn().mockRejectedValue(error),
      } as any);

      const { result } = renderHook(() => useScenario(mockScenarioId, mockUserId));

      await expect(result.current.getResponse()).rejects.toThrow(
        "No response found"
      );
    });
  });

  // ===== updateResponse tests =====
  describe("updateResponse", () => {
    it("should update response", async () => {
      const updatedResponse = { ...mockResponse, selected_option_id: "option-2" };

      vi.spyOn(scenarioClient, "scenarioApiClient", "get").mockReturnValue({
        updateResponse: vi.fn().mockResolvedValue(updatedResponse),
      } as any);

      const { result } = renderHook(() => useScenario(mockScenarioId, mockUserId));

      const response = await result.current.updateResponse(
        "response-1",
        "option-2"
      );

      expect(response.selected_option_id).toBe("option-2");
    });
  });

  // ===== getUserResponses tests =====
  describe("getUserResponses", () => {
    it("should fetch user responses", async () => {
      const mockUserResponses = {
        responses: [mockResponse],
        total: 1,
      };

      vi.spyOn(scenarioClient, "scenarioApiClient", "get").mockReturnValue({
        getUserResponses: vi.fn().mockResolvedValue(mockUserResponses),
      } as any);

      const { result } = renderHook(() => useScenario(mockScenarioId, mockUserId));

      const responses = await result.current.getUserResponses();

      expect(responses.responses).toHaveLength(1);
      expect(responses.total).toBe(1);
    });
  });

  // ===== getOptimalResponse tests =====
  describe("getOptimalResponse", () => {
    it("should fetch optimal option", async () => {
      const mockOptimalOption = mockScenario.options![0];

      vi.spyOn(scenarioClient, "scenarioApiClient", "get").mockReturnValue({
        getOptimalResponse: vi.fn().mockResolvedValue(mockOptimalOption),
      } as any);

      const { result } = renderHook(() => useScenario(mockScenarioId, mockUserId));

      const option = await result.current.getOptimalResponse();

      expect(option.is_optimal).toBe(true);
      expect(option.feedback).toBe("Good");
    });
  });

  // ===== getUserStats tests =====
  describe("getUserStats", () => {
    it("should fetch user stats", async () => {
      const mockStats = {
        user_id: mockUserId,
        unit_id: mockUnitId,
        total_scenarios: 5,
        scenarios_attempted: 4,
        scenarios_optimal: 2,
        success_rate: 0.5,
        last_attempt: "2026-01-01T00:00:00Z",
      };

      vi.spyOn(scenarioClient, "scenarioApiClient", "get").mockReturnValue({
        getUserStats: vi.fn().mockResolvedValue(mockStats),
      } as any);

      const { result } = renderHook(() => useScenario(mockScenarioId, mockUserId));

      const stats = await result.current.getUserStats(mockUnitId);

      expect(stats.total_scenarios).toBe(5);
      expect(stats.success_rate).toBe(0.5);
    });
  });
});
