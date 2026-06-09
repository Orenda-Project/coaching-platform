/**
 * useAnalytics Hook Tests
 *
 * Tests for the analytics hook:
 * - Event logging
 * - Metrics fetching and updates
 * - Module analytics
 * - Dashboard data
 * - Error handling
 * - Loading states
 */

/* eslint-disable @typescript-eslint/no-explicit-any */

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import { useAnalytics } from "../useAnalytics";
import * as analyticsClient from "../../lib/apiClients/analyticsApiClient";

// Mock the analytics client
vi.mock("../../lib/apiClients/analyticsApiClient");

describe("useAnalytics", () => {
  const mockUserId = "user-123";
  const mockMetrics = {
    id: "metrics-1",
    user_id: mockUserId,
    quiz_attempts: 5,
    modules_passed: 3,
    total_score: 425.5,
    created_at: "2026-01-01T00:00:00Z",
    updated_at: "2026-01-01T00:00:00Z",
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  // ===== logEvent tests =====
  describe("logEvent", () => {
    it("should log an event successfully", async () => {
      const mockEvent = {
        id: "event-1",
        user_id: mockUserId,
        event_type: "quiz_completed",
        event_data: { score: 85 },
        timestamp: "2026-01-01T00:00:00Z",
      };

      vi.spyOn(analyticsClient, "analyticsApiClient", "get").mockReturnValue({
        logEvent: vi.fn().mockResolvedValue(mockEvent),
      } as any);

      const { result } = renderHook(() => useAnalytics(mockUserId));

      const loggedEvent = await result.current.logEvent({
        event_type: "quiz_completed",
        event_data: { score: 85 },
      });

      expect(loggedEvent).toEqual(mockEvent);
    });

    it("should handle event logging errors", async () => {
      const error = new Error("Network error");

      vi.spyOn(analyticsClient, "analyticsApiClient", "get").mockReturnValue({
        logEvent: vi.fn().mockRejectedValue(error),
      } as any);

      const { result } = renderHook(() => useAnalytics(mockUserId));

      await expect(
        result.current.logEvent({
          event_type: "quiz_completed",
          event_data: { score: 85 },
        })
      ).rejects.toThrow("Network error");
    });
  });

  // ===== getMetrics tests =====
  describe("getMetrics", () => {
    it("should fetch user metrics", async () => {
      vi.spyOn(analyticsClient, "analyticsApiClient", "get").mockReturnValue({
        getMetrics: vi.fn().mockResolvedValue(mockMetrics),
      } as any);

      const { result } = renderHook(() => useAnalytics(mockUserId));

      const metrics = await result.current.getMetrics();

      expect(metrics).toEqual(mockMetrics);
    });

    it("should handle fetch errors", async () => {
      const error = new Error("Not found");

      vi.spyOn(analyticsClient, "analyticsApiClient", "get").mockReturnValue({
        getMetrics: vi.fn().mockRejectedValue(error),
      } as any);

      const { result } = renderHook(() => useAnalytics(mockUserId));

      await expect(result.current.getMetrics()).rejects.toThrow("Not found");
    });
  });

  // ===== updateMetrics tests =====
  describe("updateMetrics", () => {
    it("should update user metrics", async () => {
      const updates = { quiz_attempts: 10 };
      const updatedMetrics = { ...mockMetrics, ...updates };

      vi.spyOn(analyticsClient, "analyticsApiClient", "get").mockReturnValue({
        updateMetrics: vi.fn().mockResolvedValue(updatedMetrics),
      } as any);

      const { result } = renderHook(() => useAnalytics(mockUserId));

      const metrics = await result.current.updateMetrics(updates);

      expect(metrics.quiz_attempts).toBe(10);
    });
  });

  // ===== incrementMetric tests =====
  describe("incrementMetric", () => {
    it("should increment a metric", async () => {
      const updatedMetrics = { ...mockMetrics, quiz_attempts: 6 };

      vi.spyOn(analyticsClient, "analyticsApiClient", "get").mockReturnValue({
        incrementMetric: vi.fn().mockResolvedValue(updatedMetrics),
      } as any);

      const { result } = renderHook(() => useAnalytics(mockUserId));

      const metrics = await result.current.incrementMetric(
        "quiz_attempts",
        1
      );

      expect(metrics.quiz_attempts).toBe(6);
    });
  });

  // ===== getModuleAnalytics tests =====
  describe("getModuleAnalytics", () => {
    it("should fetch module analytics", async () => {
      const mockModuleAnalytics = {
        module_id: "module-1",
        total_views: 150,
        quiz_completions: 120,
        average_score: 82.5,
        learner_count: 100,
      };

      vi.spyOn(analyticsClient, "analyticsApiClient", "get").mockReturnValue({
        getModuleAnalytics: vi.fn().mockResolvedValue(mockModuleAnalytics),
      } as any);

      const { result } = renderHook(() => useAnalytics(mockUserId));

      const analytics = await result.current.getModuleAnalytics("module-1");

      expect(analytics.module_id).toBe("module-1");
      expect(analytics.average_score).toBe(82.5);
    });
  });

  // ===== getDashboard tests =====
  describe("getDashboard", () => {
    it("should fetch dashboard data", async () => {
      const mockDashboard = {
        user_id: mockUserId,
        total_events: 25,
        metrics: mockMetrics,
        recent_events: [],
        summary: {
          learning_streak: 5,
          average_quiz_score: 85,
          modules_in_progress: 2,
        },
      };

      vi.spyOn(analyticsClient, "analyticsApiClient", "get").mockReturnValue({
        getDashboard: vi.fn().mockResolvedValue(mockDashboard),
      } as any);

      const { result } = renderHook(() => useAnalytics(mockUserId));

      const dashboard = await result.current.getDashboard();

      expect(dashboard.user_id).toBe(mockUserId);
      expect(dashboard.total_events).toBe(25);
    });
  });
});
