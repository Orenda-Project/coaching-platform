/**
 * Analytics API Client Tests
 *
 * Comprehensive test coverage for:
 * - Event logging (log, getEvents, getEventsByType)
 * - Metrics management (getMetrics, updateMetrics, incrementMetric)
 * - Analytics aggregation (getModuleAnalytics, getDashboard, getAllAnalytics)
 * - Error handling and retry logic
 * - Cache management
 */

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import {
  AnalyticsApiClient,
  type AnalyticsEvent,
  type UserMetrics,
  type DashboardData,
} from "../analyticsApiClient";

describe("AnalyticsApiClient", () => {
  let client: AnalyticsApiClient;
  let fetchMock: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    client = new AnalyticsApiClient("http://localhost:8000");
    fetchMock = vi.fn();
    global.fetch = fetchMock;
  });

  afterEach(() => {
    vi.clearAllMocks();
    client.clearCache();
  });

  // ===== logEvent tests =====
  describe("logEvent", () => {
    it("should log an event successfully", async () => {
      const userId = "user-123";
      const eventData = {
        event_type: "quiz_completed",
        event_data: {
          module_id: "module-1",
          score: 85,
          duration_seconds: 300,
        },
      };

      const mockResponse: AnalyticsEvent = {
        id: "event-1",
        user_id: userId,
        event_type: "quiz_completed",
        event_data: eventData.event_data,
        timestamp: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.logEvent(userId, eventData);

      expect(result).toEqual(mockResponse);
      expect(fetchMock).toHaveBeenCalledWith(
        `http://localhost:8000/api/analytics/events/${userId}`,
        expect.objectContaining({
          method: "POST",
          headers: expect.objectContaining({
            "Content-Type": "application/json",
          }),
          body: JSON.stringify(eventData),
        })
      );
    });

    it("should handle event logging errors", async () => {
      const userId = "user-123";
      const eventData = {
        event_type: "quiz_completed",
        event_data: { score: 85 },
      };

      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 400,
        text: async () => JSON.stringify({ detail: "Invalid event type" }),
      });

      await expect(client.logEvent(userId, eventData)).rejects.toThrow(
        "Invalid event type"
      );
    });

    it("should retry on network errors", async () => {
      const userId = "user-123";
      const eventData = {
        event_type: "quiz_completed",
        event_data: { score: 85 },
      };

      fetchMock
        .mockRejectedValueOnce(new Error("Network error"))
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ id: "event-1" } as AnalyticsEvent),
        });

      const result = await client.logEvent(userId, eventData);

      expect(result).toBeDefined();
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });

  // ===== getEvents tests =====
  describe("getEvents", () => {
    it("should fetch user events with pagination", async () => {
      const userId = "user-123";
      const mockResponse = {
        events: [
          {
            id: "event-1",
            user_id: userId,
            event_type: "quiz_completed",
            event_data: { score: 85 },
            timestamp: "2026-01-01T00:00:00Z",
          },
          {
            id: "event-2",
            user_id: userId,
            event_type: "module_viewed",
            event_data: { module_id: "module-1" },
            timestamp: "2026-01-01T00:01:00Z",
          },
        ],
        total: 2,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getEvents(userId, { limit: 10, offset: 0 });

      expect(result.events).toHaveLength(2);
      expect(result.total).toBe(2);
      expect(fetchMock).toHaveBeenCalledWith(
        `http://localhost:8000/api/analytics/events/${userId}?limit=10&offset=0`,
        expect.any(Object)
      );
    });

    it("should handle empty events list", async () => {
      const userId = "user-123";
      const mockResponse = { events: [], total: 0 };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getEvents(userId);

      expect(result.events).toHaveLength(0);
      expect(result.total).toBe(0);
    });

    it("should cache events", async () => {
      const userId = "user-123";
      const mockResponse = {
        events: [{ id: "event-1" } as AnalyticsEvent],
        total: 1,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getEvents(userId);
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getEvents(userId);
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });
  });

  // ===== getEventsByType tests =====
  describe("getEventsByType", () => {
    it("should filter events by type", async () => {
      const userId = "user-123";
      const eventType = "quiz_completed";
      const mockResponse = {
        events: [
          {
            id: "event-1",
            event_type: "quiz_completed",
            event_data: { score: 85 },
          } as AnalyticsEvent,
        ],
        total: 1,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getEventsByType(userId, eventType);

      expect(result.events).toHaveLength(1);
      expect(result.events[0].event_type).toBe("quiz_completed");
      expect(fetchMock).toHaveBeenCalledWith(
        `http://localhost:8000/api/analytics/events/${userId}/type/${eventType}`,
        expect.any(Object)
      );
    });

    it("should handle no events of type", async () => {
      const userId = "user-123";
      const eventType = "nonexistent_type";
      const mockResponse = { events: [], total: 0 };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getEventsByType(userId, eventType);

      expect(result.events).toHaveLength(0);
      expect(result.total).toBe(0);
    });
  });

  // ===== getMetrics tests =====
  describe("getMetrics", () => {
    it("should fetch user metrics", async () => {
      const userId = "user-123";
      const mockResponse: UserMetrics = {
        id: "metrics-1",
        user_id: userId,
        quiz_attempts: 5,
        modules_passed: 3,
        total_score: 425.5,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getMetrics(userId);

      expect(result.user_id).toBe(userId);
      expect(result.quiz_attempts).toBe(5);
      expect(result.modules_passed).toBe(3);
      expect(result.total_score).toBe(425.5);
    });

    it("should cache metrics", async () => {
      const userId = "user-123";
      const mockResponse: UserMetrics = {
        id: "metrics-1",
        user_id: userId,
        quiz_attempts: 5,
        modules_passed: 3,
        total_score: 425.5,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getMetrics(userId);
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getMetrics(userId);
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });

    it("should handle 404 when metrics not found", async () => {
      const userId = "user-123";

      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({ detail: "Metrics not found" }),
      });

      await expect(client.getMetrics(userId)).rejects.toThrow(
        "Metrics not found"
      );
    });
  });

  // ===== updateMetrics tests =====
  describe("updateMetrics", () => {
    it("should update user metrics", async () => {
      const userId = "user-123";
      const updates = {
        quiz_attempts: 10,
        modules_passed: 5,
        total_score: 500,
      };

      const mockResponse: UserMetrics = {
        id: "metrics-1",
        user_id: userId,
        ...updates,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.updateMetrics(userId, updates);

      expect(result.quiz_attempts).toBe(10);
      expect(result.modules_passed).toBe(5);
      expect(result.total_score).toBe(500);
      expect(fetchMock).toHaveBeenCalledWith(
        `http://localhost:8000/api/analytics/metrics/${userId}`,
        expect.objectContaining({
          method: "PUT",
          body: JSON.stringify(updates),
        })
      );
    });

    it("should invalidate metrics cache on update", async () => {
      const userId = "user-123";
      const mockMetrics: UserMetrics = {
        id: "metrics-1",
        user_id: userId,
        quiz_attempts: 5,
        modules_passed: 3,
        total_score: 425.5,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockMetrics,
      });

      await client.getMetrics(userId);

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ ...mockMetrics, quiz_attempts: 10 }),
      });

      await client.updateMetrics(userId, { quiz_attempts: 10 });

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ ...mockMetrics, quiz_attempts: 10 }),
      });

      const result = await client.getMetrics(userId);
      expect(result.quiz_attempts).toBe(10);
      expect(fetchMock).toHaveBeenCalledTimes(3);
    });
  });

  // ===== incrementMetric tests =====
  describe("incrementMetric", () => {
    it("should increment a metric", async () => {
      const userId = "user-123";
      const metricName = "quiz_attempts";
      const increment = 1;

      const mockResponse: UserMetrics = {
        id: "metrics-1",
        user_id: userId,
        quiz_attempts: 6,
        modules_passed: 3,
        total_score: 425.5,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.incrementMetric(
        userId,
        metricName as keyof UserMetrics,
        increment
      );

      expect(result.quiz_attempts).toBe(6);
      expect(fetchMock).toHaveBeenCalledWith(
        `http://localhost:8000/api/analytics/metrics/${userId}/increment`,
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify({ metric_name: metricName, increment }),
        })
      );
    });

    it("should handle invalid metric name", async () => {
      const userId = "user-123";

      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 400,
        text: async () => JSON.stringify({ detail: "Invalid metric name" }),
      });

      await expect(
        client.incrementMetric(userId, "invalid_metric" as keyof UserMetrics, 1)
      ).rejects.toThrow("Invalid metric name");
    });
  });

  // ===== getModuleAnalytics tests =====
  describe("getModuleAnalytics", () => {
    it("should fetch module-level analytics", async () => {
      const moduleId = "module-1";
      const mockResponse = {
        module_id: moduleId,
        total_views: 150,
        quiz_completions: 120,
        average_score: 82.5,
        learner_count: 100,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getModuleAnalytics(moduleId);

      expect(result.module_id).toBe(moduleId);
      expect(result.total_views).toBe(150);
      expect(result.average_score).toBe(82.5);
    });

    it("should cache module analytics", async () => {
      const moduleId = "module-1";
      const mockResponse = {
        module_id: moduleId,
        total_views: 150,
        quiz_completions: 120,
        average_score: 82.5,
        learner_count: 100,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getModuleAnalytics(moduleId);
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getModuleAnalytics(moduleId);
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });
  });

  // ===== getDashboard tests =====
  describe("getDashboard", () => {
    it("should fetch dashboard data for user", async () => {
      const userId = "user-123";
      const mockResponse: DashboardData = {
        user_id: userId,
        total_events: 25,
        metrics: {
          quiz_attempts: 5,
          modules_passed: 3,
          total_score: 425.5,
        } as UserMetrics,
        recent_events: [
          {
            id: "event-1",
            event_type: "quiz_completed",
            timestamp: "2026-01-01T00:00:00Z",
          } as AnalyticsEvent,
        ],
        summary: {
          learning_streak: 5,
          average_quiz_score: 85,
          modules_in_progress: 2,
        },
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getDashboard(userId);

      expect(result.user_id).toBe(userId);
      expect(result.total_events).toBe(25);
      expect(result.metrics.quiz_attempts).toBe(5);
      expect(result.recent_events).toHaveLength(1);
    });

    it("should not cache dashboard data", async () => {
      const userId = "user-123";
      const mockResponse: DashboardData = {
        user_id: userId,
        total_events: 25,
        metrics: {
          quiz_attempts: 5,
          modules_passed: 3,
          total_score: 425.5,
        } as UserMetrics,
        recent_events: [],
        summary: {
          learning_streak: 5,
          average_quiz_score: 85,
          modules_in_progress: 2,
        },
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getDashboard(userId);
      expect(fetchMock).toHaveBeenCalledTimes(1);

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getDashboard(userId);
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });

  // ===== getAllAnalytics tests =====
  describe("getAllAnalytics", () => {
    it("should fetch all analytics (admin only)", async () => {
      const mockResponse = {
        analytics: [
          {
            id: "event-1",
            event_type: "quiz_completed",
            user_id: "user-1",
          } as AnalyticsEvent,
        ],
        total: 100,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getAllAnalytics({ limit: 50, offset: 0 });

      expect(result.analytics).toHaveLength(1);
      expect(result.total).toBe(100);
      expect(fetchMock).toHaveBeenCalledWith(
        `http://localhost:8000/api/analytics/?limit=50&offset=0`,
        expect.any(Object)
      );
    });

    it("should handle pagination in getAllAnalytics", async () => {
      const mockResponse = {
        analytics: [],
        total: 0,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getAllAnalytics({
        limit: 100,
        offset: 100,
      });

      expect(fetchMock).toHaveBeenCalledWith(
        `http://localhost:8000/api/analytics/?limit=100&offset=100`,
        expect.any(Object)
      );
    });
  });

  // ===== clearCache tests =====
  describe("clearCache", () => {
    it("should clear all cache", async () => {
      const userId = "user-123";
      const mockMetrics: UserMetrics = {
        id: "metrics-1",
        user_id: userId,
        quiz_attempts: 5,
        modules_passed: 3,
        total_score: 425.5,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockMetrics,
      });

      await client.getMetrics(userId);
      expect(fetchMock).toHaveBeenCalledTimes(1);

      client.clearCache();

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockMetrics,
      });

      await client.getMetrics(userId);
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });
});
