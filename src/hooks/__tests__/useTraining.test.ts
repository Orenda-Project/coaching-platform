/**
 * useTraining Hook Tests
 *
 * Test coverage for:
 * - State management
 * - API integration
 * - Error handling
 */

import { describe, it, expect, beforeEach, vi } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useTraining } from "../useTraining";
import * as trainingClient from "@/lib/apiClients/trainingApiClient";

vi.mock("@/lib/apiClients/trainingApiClient");

const mockTraining = {
  id: "training-1",
  title: "Module 1",
  description: "First module",
  order_number: 1,
  is_common: true,
  persona_required: null,
  created_at: "2026-01-01T00:00:00Z",
  updated_at: "2026-01-01T00:00:00Z",
};

const mockProgress = {
  user_id: "user-123",
  training_id: "training-1",
  started: true,
  completed: false,
  progress_percentage: 50,
  last_accessed: "2026-01-01T00:00:00Z",
  started_at: "2026-01-01T00:00:00Z",
  completed_at: null,
};

describe("useTraining Hook", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("Initial State", () => {
    it("should have default state on mount", () => {
      const { result } = renderHook(() => useTraining());

      expect(result.current.trainings).toEqual([]);
      expect(result.current.progress).toBeNull();
      expect(result.current.loading).toBe(false);
      expect(result.current.error).toBeNull();
    });
  });

  describe("loadTrainings", () => {
    it("should load trainings and set state", async () => {
      const mockTrainings = [mockTraining];
      const mockGetTrainings = vi.fn().mockResolvedValue(mockTrainings);
      vi.mocked(trainingClient.trainingApiClient).getTrainings = mockGetTrainings;

      const { result } = renderHook(() => useTraining());

      await act(async () => {
        await result.current.loadTrainings();
      });

      expect(result.current.trainings).toEqual(mockTrainings);
      expect(result.current.loading).toBe(false);
      expect(result.current.error).toBeNull();
      expect(mockGetTrainings).toHaveBeenCalled();
    });

    it("should clear previous error on successful load", async () => {
      const mockGetTrainings = vi.fn().mockResolvedValue([mockTraining]);
      vi.mocked(trainingClient.trainingApiClient).getTrainings = mockGetTrainings;

      const { result } = renderHook(() => useTraining());

      // First, simulate an error state
      await act(async () => {
        const failingClient = vi.fn().mockRejectedValue(new Error("First error"));
        vi.mocked(trainingClient.trainingApiClient).getTrainings = failingClient;
        try {
          await result.current.loadTrainings();
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();

      // Now load successfully
      vi.mocked(trainingClient.trainingApiClient).getTrainings = mockGetTrainings;
      await act(async () => {
        await result.current.loadTrainings();
      });

      expect(result.current.error).toBeNull();
      expect(result.current.trainings).toEqual([mockTraining]);
    });

    it("should handle errors", async () => {
      const error = new Error("Failed to load trainings");
      const mockGetTrainings = vi.fn().mockRejectedValue(error);
      vi.mocked(trainingClient.trainingApiClient).getTrainings = mockGetTrainings;

      const { result } = renderHook(() => useTraining());

      await act(async () => {
        try {
          await result.current.loadTrainings();
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();
      expect(result.current.error?.message).toBe("Failed to load trainings");
    });
  });

  describe("updateProgress", () => {
    it("should update training progress", async () => {
      const updatedProgress = { ...mockProgress, progress_percentage: 75 };
      const mockUpdate = vi.fn().mockResolvedValue(updatedProgress);
      vi.mocked(trainingClient.trainingApiClient).updateProgress = mockUpdate;

      const { result } = renderHook(() => useTraining());

      await act(async () => {
        await result.current.updateProgress("user-123", "training-1", {
          progress_percentage: 75,
        });
      });

      expect(result.current.progress).toEqual(updatedProgress);
      expect(result.current.error).toBeNull();
      expect(mockUpdate).toHaveBeenCalledWith("user-123", "training-1", {
        progress_percentage: 75,
      });
    });

    it("should handle update errors", async () => {
      const error = new Error("Update failed");
      const mockUpdate = vi.fn().mockRejectedValue(error);
      vi.mocked(trainingClient.trainingApiClient).updateProgress = mockUpdate;

      const { result } = renderHook(() => useTraining());

      await act(async () => {
        try {
          await result.current.updateProgress("user-123", "training-1", {});
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();
      expect(result.current.error?.message).toBe("Update failed");
    });

    it("should clear previous error on successful update", async () => {
      const mockUpdate = vi.fn().mockResolvedValue(mockProgress);
      vi.mocked(trainingClient.trainingApiClient).updateProgress = mockUpdate;

      const { result } = renderHook(() => useTraining());

      // Set error state first
      await act(async () => {
        const failingClient = vi.fn().mockRejectedValue(new Error("Error"));
        vi.mocked(trainingClient.trainingApiClient).updateProgress = failingClient;
        try {
          await result.current.updateProgress("user-123", "training-1", {});
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();

      // Now update successfully
      vi.mocked(trainingClient.trainingApiClient).updateProgress = mockUpdate;
      await act(async () => {
        await result.current.updateProgress("user-123", "training-1", {});
      });

      expect(result.current.error).toBeNull();
      expect(result.current.progress).toEqual(mockProgress);
    });
  });

  describe("markTrainingComplete", () => {
    it("should mark training as complete", async () => {
      const completedProgress = {
        ...mockProgress,
        completed: true,
        progress_percentage: 100,
        completed_at: "2026-01-01T01:00:00Z",
      };

      const mockMarkComplete = vi.fn().mockResolvedValue(completedProgress);
      vi.mocked(trainingClient.trainingApiClient).markComplete = mockMarkComplete;

      const { result } = renderHook(() => useTraining());

      await act(async () => {
        await result.current.markTrainingComplete("user-123", "training-1");
      });

      expect(result.current.progress).toEqual(completedProgress);
      expect(result.current.progress?.completed).toBe(true);
      expect(mockMarkComplete).toHaveBeenCalledWith("user-123", "training-1");
    });

    it("should handle mark complete errors", async () => {
      const error = new Error("Mark complete failed");
      const mockMarkComplete = vi.fn().mockRejectedValue(error);
      vi.mocked(trainingClient.trainingApiClient).markComplete = mockMarkComplete;

      const { result } = renderHook(() => useTraining());

      await act(async () => {
        try {
          await result.current.markTrainingComplete("user-123", "training-1");
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();
    });
  });

  describe("clearError", () => {
    it("should clear error state", async () => {
      const mockGetTrainings = vi
        .fn()
        .mockRejectedValue(new Error("Test error"));
      vi.mocked(trainingClient.trainingApiClient).getTrainings = mockGetTrainings;

      const { result } = renderHook(() => useTraining());

      await act(async () => {
        try {
          await result.current.loadTrainings();
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();

      act(() => {
        result.current.clearError();
      });

      expect(result.current.error).toBeNull();
    });
  });

  describe("Multiple Sequential Calls", () => {
    it("should handle multiple loadTrainings calls", async () => {
      const trainings1 = [mockTraining];
      const trainings2 = [{ ...mockTraining, id: "training-2" }];

      const mockGetTrainings = vi
        .fn()
        .mockResolvedValueOnce(trainings1)
        .mockResolvedValueOnce(trainings2);

      vi.mocked(trainingClient.trainingApiClient).getTrainings = mockGetTrainings;

      const { result } = renderHook(() => useTraining());

      await act(async () => {
        await result.current.loadTrainings();
      });
      expect(result.current.trainings).toEqual(trainings1);

      await act(async () => {
        await result.current.loadTrainings();
      });
      expect(result.current.trainings).toEqual(trainings2);
    });
  });

  describe("Progress State Management", () => {
    it("should preserve progress across renders", async () => {
      const mockUpdate = vi.fn().mockResolvedValue(mockProgress);
      vi.mocked(trainingClient.trainingApiClient).updateProgress = mockUpdate;

      const { result, rerender } = renderHook(() => useTraining());

      await act(async () => {
        await result.current.updateProgress("user-123", "training-1", {});
      });

      const firstRenderProgress = result.current.progress;

      rerender();

      const secondRenderProgress = result.current.progress;

      expect(firstRenderProgress).toEqual(secondRenderProgress);
      expect(result.current.progress?.user_id).toBe("user-123");
    });
  });

  describe("Error User-Friendly Messages", () => {
    it("should provide user-friendly error message on network failure", async () => {
      const networkError = new Error("Network error");
      const mockGetTrainings = vi.fn().mockRejectedValue(networkError);
      vi.mocked(trainingClient.trainingApiClient).getTrainings = mockGetTrainings;

      const { result } = renderHook(() => useTraining());

      await act(async () => {
        try {
          await result.current.loadTrainings();
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();
      expect(result.current.error?.message).toBeDefined();
    });

    it("should provide user-friendly error message on server error", async () => {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const apiError = new Error("Failed to fetch trainings") as any;
      apiError.status = 500;
      const mockGetTrainings = vi.fn().mockRejectedValue(apiError);
      vi.mocked(trainingClient.trainingApiClient).getTrainings = mockGetTrainings;

      const { result } = renderHook(() => useTraining());

      await act(async () => {
        try {
          await result.current.loadTrainings();
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();
      expect(result.current.error?.status).toBe(500);
    });
  });

  describe("Cache Management", () => {
    it("should provide clearCache function", async () => {
      const mockClearCache = vi.fn();
      vi.mocked(trainingClient.trainingApiClient).clearCache = mockClearCache;

      const { result } = renderHook(() => useTraining());

      act(() => {
        result.current.clearCache();
      });

      expect(mockClearCache).toHaveBeenCalled();
    });
  });
});
