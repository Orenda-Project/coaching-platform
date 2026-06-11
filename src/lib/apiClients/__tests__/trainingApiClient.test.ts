/**
 * Training API Client Tests
 *
 * Comprehensive test coverage for:
 * - All API methods (get, getContent, getProgress, updateProgress, markComplete)
 * - Error handling and retry logic
 * - Cache management
 */

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import {
  TrainingApiClient,
  type Training,
  type TrainingContent,
  type UserProgress,
} from "../trainingApiClient";

describe("TrainingApiClient", () => {
  let client: TrainingApiClient;
  let fetchMock: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    client = new TrainingApiClient("http://localhost:8000");
    fetchMock = vi.fn();
    global.fetch = fetchMock;
  });

  afterEach(() => {
    vi.clearAllMocks();
    client.clearCache();
  });

  // ===== getTrainings tests =====
  describe("getTrainings", () => {
    it("should fetch all trainings", async () => {
      const mockResponse: Training[] = [
        {
          id: "training-1",
          title: "Module 1",
          description: "First module",
          order_number: 1,
          is_common: true,
          persona_required: null,
          created_at: "2026-01-01T00:00:00Z",
          updated_at: "2026-01-01T00:00:00Z",
        },
        {
          id: "training-2",
          title: "Module 2",
          description: "Second module",
          order_number: 2,
          is_common: false,
          persona_required: "A",
          created_at: "2026-01-01T00:00:00Z",
          updated_at: "2026-01-01T00:00:00Z",
        },
      ];

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getTrainings();

      expect(result).toHaveLength(2);
      expect(result[0].id).toBe("training-1");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/trainings",
        expect.objectContaining({
          headers: expect.objectContaining({
            "Content-Type": "application/json",
          }),
        })
      );
    });

    it("should cache trainings", async () => {
      const mockResponse: Training[] = [];

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getTrainings();
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getTrainings();
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });

    it("should handle errors", async () => {
      fetchMock.mockResolvedValue({
        ok: false,
        status: 500,
        text: async () => JSON.stringify({
          detail: "Server error",
        }),
      });

      await expect(client.getTrainings()).rejects.toThrow();
    });
  });

  // ===== getTraining tests =====
  describe("getTraining", () => {
    it("should fetch a specific training", async () => {
      const mockResponse: Training = {
        id: "training-1",
        title: "Module 1",
        description: "First module",
        order_number: 1,
        is_common: true,
        persona_required: null,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getTraining("training-1");

      expect(result.id).toBe("training-1");
      expect(result.title).toBe("Module 1");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/trainings/training-1",
        expect.objectContaining({
          headers: expect.objectContaining({
            "Content-Type": "application/json",
          }),
        })
      );
    });

    it("should cache training by ID", async () => {
      const mockResponse: Training = {
        id: "training-1",
        title: "Module 1",
        description: "First module",
        order_number: 1,
        is_common: true,
        persona_required: null,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getTraining("training-1");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getTraining("training-1");
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });

    it("should handle not found error", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({
          detail: "Training not found",
        }),
      });

      await expect(client.getTraining("nonexistent")).rejects.toThrow(
        "Training not found"
      );
    });
  });

  // ===== getTrainingContent tests =====
  describe("getTrainingContent", () => {
    it("should fetch training content", async () => {
      const mockResponse: TrainingContent = {
        training_id: "training-1",
        slides: [
          {
            id: "slide-1",
            order: 1,
            title: "Slide 1",
            content: "Content 1",
          },
        ],
        videos: [
          {
            id: "video-1",
            order: 1,
            url: "https://example.com/video.mp4",
            duration: 300,
          },
        ],
        materials: [],
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getTrainingContent("training-1");

      expect(result.training_id).toBe("training-1");
      expect(result.slides).toHaveLength(1);
      expect(result.videos).toHaveLength(1);
    });

    it("should cache training content", async () => {
      const mockResponse: TrainingContent = {
        training_id: "training-1",
        slides: [],
        videos: [],
        materials: [],
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getTrainingContent("training-1");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getTrainingContent("training-1");
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });
  });

  // ===== getUserProgress tests =====
  describe("getUserProgress", () => {
    it("should fetch user progress", async () => {
      const mockResponse: UserProgress = {
        user_id: "user-123",
        training_id: "training-1",
        started: true,
        completed: false,
        progress_percentage: 50,
        last_accessed: "2026-01-01T00:00:00Z",
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getUserProgress("user-123", "training-1");

      expect(result.user_id).toBe("user-123");
      expect(result.progress_percentage).toBe(50);
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/trainings/training-1/progress/user-123",
        expect.objectContaining({
          headers: expect.objectContaining({
            "Content-Type": "application/json",
          }),
        })
      );
    });

    it("should cache progress by user and training", async () => {
      const mockResponse: UserProgress = {
        user_id: "user-123",
        training_id: "training-1",
        started: true,
        completed: false,
        progress_percentage: 50,
        last_accessed: "2026-01-01T00:00:00Z",
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getUserProgress("user-123", "training-1");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getUserProgress("user-123", "training-1");
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });
  });

  // ===== updateProgress tests =====
  describe("updateProgress", () => {
    it("should update user progress", async () => {
      const mockResponse: UserProgress = {
        user_id: "user-123",
        training_id: "training-1",
        started: true,
        completed: false,
        progress_percentage: 75,
        last_accessed: "2026-01-01T00:00:00Z",
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.updateProgress(
        "user-123",
        "training-1",
        { progress_percentage: 75 }
      );

      expect(result.progress_percentage).toBe(75);
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/trainings/training-1/progress/user-123",
        expect.objectContaining({
          method: "PUT",
          body: JSON.stringify({ progress_percentage: 75 }),
        })
      );
    });

    it("should invalidate cache on update", async () => {
      const mockProgress: UserProgress = {
        user_id: "user-123",
        training_id: "training-1",
        started: true,
        completed: false,
        progress_percentage: 50,
        last_accessed: "2026-01-01T00:00:00Z",
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
      };

      const updatedProgress = { ...mockProgress, progress_percentage: 75 };

      // Cache the progress
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockProgress,
      });
      await client.getUserProgress("user-123", "training-1");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      // Update it
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => updatedProgress,
      });
      await client.updateProgress("user-123", "training-1", {
        progress_percentage: 75,
      });
      expect(fetchMock).toHaveBeenCalledTimes(2);

      // Next get should use cache (already set by update)
      await client.getUserProgress("user-123", "training-1");
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });

    it("should retry on server error", async () => {
      const mockResponse: UserProgress = {
        user_id: "user-123",
        training_id: "training-1",
        started: true,
        completed: false,
        progress_percentage: 75,
        last_accessed: "2026-01-01T00:00:00Z",
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
      };

      fetchMock
        .mockResolvedValueOnce({ ok: false, status: 500, text: async () => "" })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

      const result = await client.updateProgress("user-123", "training-1", {
        progress_percentage: 75,
      });

      expect(result.progress_percentage).toBe(75);
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });

  // ===== markComplete tests =====
  describe("markComplete", () => {
    it("should mark training as complete", async () => {
      const mockResponse: UserProgress = {
        user_id: "user-123",
        training_id: "training-1",
        started: true,
        completed: true,
        progress_percentage: 100,
        last_accessed: "2026-01-01T00:00:00Z",
        started_at: "2026-01-01T00:00:00Z",
        completed_at: "2026-01-01T01:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.markComplete("user-123", "training-1");

      expect(result.completed).toBe(true);
      expect(result.progress_percentage).toBe(100);
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/trainings/training-1/progress/user-123/complete",
        expect.objectContaining({
          method: "POST",
        })
      );
    });

    it("should invalidate cache on mark complete", async () => {
      const mockProgress: UserProgress = {
        user_id: "user-123",
        training_id: "training-1",
        started: true,
        completed: false,
        progress_percentage: 80,
        last_accessed: "2026-01-01T00:00:00Z",
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
      };

      const completedProgress = {
        ...mockProgress,
        completed: true,
        progress_percentage: 100,
        completed_at: "2026-01-01T01:00:00Z",
      };

      // Cache the progress
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockProgress,
      });
      await client.getUserProgress("user-123", "training-1");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      // Mark complete
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => completedProgress,
      });
      await client.markComplete("user-123", "training-1");
      expect(fetchMock).toHaveBeenCalledTimes(2);

      // Next get should use cache
      await client.getUserProgress("user-123", "training-1");
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });

    it("should retry on server error", async () => {
      const mockResponse: UserProgress = {
        user_id: "user-123",
        training_id: "training-1",
        started: true,
        completed: true,
        progress_percentage: 100,
        last_accessed: "2026-01-01T00:00:00Z",
        started_at: "2026-01-01T00:00:00Z",
        completed_at: "2026-01-01T01:00:00Z",
      };

      fetchMock
        .mockResolvedValueOnce({ ok: false, status: 500, text: async () => "" })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

      const result = await client.markComplete("user-123", "training-1");

      expect(result.completed).toBe(true);
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });

  // ===== Retry logic tests =====
  describe("Retry Logic", () => {
    it("should fail after max retries exceeded", async () => {
      fetchMock.mockResolvedValue({
        ok: false,
        status: 500,
        text: async () => "",
      });

      await expect(client.getTrainings()).rejects.toThrow();

      expect(fetchMock).toHaveBeenCalledTimes(3);
    });

    it("should not retry on 4xx errors", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 400,
        text: async () => JSON.stringify({ detail: "Bad request" }),
      });

      await expect(client.getTrainings()).rejects.toThrow("Bad request");

      expect(fetchMock).toHaveBeenCalledTimes(1);
    });
  });

  // ===== Cache expiry tests =====
  describe("Cache Expiry", () => {
    it("should expire cache after 5 minutes", async () => {
      vi.useFakeTimers();

      const mockResponse: Training[] = [
        {
          id: "training-1",
          title: "Module 1",
          description: "First module",
          order_number: 1,
          is_common: true,
          persona_required: null,
          created_at: "2026-01-01T00:00:00Z",
          updated_at: "2026-01-01T00:00:00Z",
        },
      ];

      fetchMock.mockResolvedValue({
        ok: true,
        json: async () => mockResponse,
      });

      // First call
      await client.getTrainings();
      expect(fetchMock).toHaveBeenCalledTimes(1);

      // Advance 3 minutes - should still be cached
      vi.advanceTimersByTime(3 * 60 * 1000);
      await client.getTrainings();
      expect(fetchMock).toHaveBeenCalledTimes(1);

      // Advance 3 more minutes (6 total) - cache should expire
      vi.advanceTimersByTime(3 * 60 * 1000);
      await client.getTrainings();
      expect(fetchMock).toHaveBeenCalledTimes(2);

      vi.useRealTimers();
    });
  });

  // ===== Error handling tests =====
  describe("Error Handling", () => {
    it("should normalize network errors", async () => {
      fetchMock.mockRejectedValue(new Error("Network error"));

      await expect(client.getTrainings()).rejects.toThrow("Network error");
    });

    it("should handle malformed JSON responses", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 500,
        text: async () => "not json",
      });

      await expect(client.getTrainings()).rejects.toThrow();
    });

    it("should include status code in errors", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 403,
        text: async () => JSON.stringify({
          detail: "Forbidden",
        }),
      });

      try {
        await client.getTrainings();
        expect.fail("Should have thrown");
      } catch (err) {
        const error = err as any;
        expect(error.status).toBe(403);
      }
    });
  });
});
