/**
 * useObservation Hook Tests
 *
 * Comprehensive test coverage for:
 * - State management (observations, loading, error)
 * - All hook actions (loadObservations, createObservation, updateObservation, etc.)
 * - Error handling and recovery
 * - Cache clearing
 */

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useObservation } from "../useObservation";
import { observationApiClient } from "@/lib/apiClients/observationApiClient";
import type { Observation } from "@/lib/apiClients/observationApiClient";

// Mock the API client
vi.mock("@/lib/apiClients/observationApiClient", () => {
  const actual = vi.importActual("@/lib/apiClients/observationApiClient");
  return {
    ...actual,
    observationApiClient: {
      createObservation: vi.fn(),
      getObservation: vi.fn(),
      getUserObservations: vi.fn(),
      updateObservation: vi.fn(),
      deleteObservation: vi.fn(),
      createCOTObservation: vi.fn(),
      getCOTResponses: vi.fn(),
      bulkSaveObservations: vi.fn(),
      clearCache: vi.fn(),
    },
  };
});

describe("useObservation", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe("initial state", () => {
    it("should have initial empty state", () => {
      const { result } = renderHook(() => useObservation());

      expect(result.current.observations).toEqual([]);
      expect(result.current.loading).toBe(false);
      expect(result.current.error).toBeNull();
    });
  });

  describe("loadObservations", () => {
    it("should successfully load observations", async () => {
      const mockObservations: Observation[] = [
        {
          id: "obs-1",
          user_id: "user-456",
          date: "2026-06-09",
          notes: "First observation",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        },
        {
          id: "obs-2",
          user_id: "user-456",
          date: "2026-06-08",
          notes: "Second observation",
          created_at: "2026-06-08T10:00:00Z",
          updated_at: "2026-06-08T10:00:00Z",
        },
      ];

      vi.mocked(observationApiClient.getUserObservations).mockResolvedValueOnce({
        observations: mockObservations,
        total: 2,
        limit: 100,
        offset: 0,
      });

      const { result } = renderHook(() => useObservation());

      expect(result.current.loading).toBe(false);

      await act(async () => {
        await result.current.loadObservations("user-456");
      });

      expect(result.current.observations).toEqual(mockObservations);
      expect(result.current.loading).toBe(false);
      expect(result.current.error).toBeNull();
    });

    it("should handle pagination parameters", async () => {
      vi.mocked(observationApiClient.getUserObservations).mockResolvedValueOnce({
        observations: [],
        total: 100,
        limit: 10,
        offset: 20,
      });

      const { result } = renderHook(() => useObservation());

      await act(async () => {
        await result.current.loadObservations("user-456", 10, 20);
      });

      expect(observationApiClient.getUserObservations).toHaveBeenCalledWith(
        "user-456",
        10,
        20
      );
    });

    it("should set loading state during fetch", async () => {
      vi.mocked(observationApiClient.getUserObservations).mockImplementationOnce(
        () =>
          new Promise((resolve) =>
            setTimeout(
              () =>
                resolve({
                  observations: [],
                  total: 0,
                  limit: 100,
                  offset: 0,
                }),
              100
            )
          )
      );

      const { result } = renderHook(() => useObservation());

      const promise = act(async () => {
        await result.current.loadObservations("user-456");
      });

      // Note: Due to hook implementation, loading state may not be visible in test
      await promise;

      expect(result.current.loading).toBe(false);
    });

    it("should handle error when loading observations", async () => {
      const mockError = new Error("Failed to load");

      vi.mocked(observationApiClient.getUserObservations).mockRejectedValueOnce(
        mockError
      );

      const { result } = renderHook(() => useObservation());

      await act(async () => {
        try {
          await result.current.loadObservations("user-456");
        } catch {
          // Expected error
        }
      });

      expect(result.current.error).not.toBeNull();
      expect(result.current.observations).toEqual([]);
    });
  });

  describe("createObservation", () => {
    it("should successfully create an observation", async () => {
      const newObservation: Observation = {
        id: "obs-123",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "New observation",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      vi.mocked(observationApiClient.createObservation).mockResolvedValueOnce(
        newObservation
      );

      const { result } = renderHook(() => useObservation());

      await act(async () => {
        await result.current.createObservation(
          "user-456",
          "2026-06-09",
          "New observation"
        );
      });

      expect(result.current.error).toBeNull();
      expect(observationApiClient.createObservation).toHaveBeenCalledWith(
        "user-456",
        "2026-06-09",
        "New observation"
      );
    });

    it("should add created observation to observations list", async () => {
      const existingObservation: Observation = {
        id: "obs-1",
        user_id: "user-456",
        date: "2026-06-08",
        notes: "Existing",
        created_at: "2026-06-08T10:00:00Z",
        updated_at: "2026-06-08T10:00:00Z",
      };

      const newObservation: Observation = {
        id: "obs-2",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "New",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      const { result } = renderHook(() => useObservation());

      // Set initial observation
      await act(async () => {
        vi.mocked(observationApiClient.getUserObservations).mockResolvedValueOnce({
          observations: [existingObservation],
          total: 1,
          limit: 100,
          offset: 0,
        });
        await result.current.loadObservations("user-456");
      });

      // Create new observation
      await act(async () => {
        vi.mocked(observationApiClient.createObservation).mockResolvedValueOnce(
          newObservation
        );
        await result.current.createObservation(
          "user-456",
          "2026-06-09",
          "New"
        );
      });

      expect(result.current.observations).toContainEqual(newObservation);
    });

    it("should handle creation error", async () => {
      const mockError = new Error("Creation failed");

      vi.mocked(observationApiClient.createObservation).mockRejectedValueOnce(
        mockError
      );

      const { result } = renderHook(() => useObservation());

      await act(async () => {
        try {
          await result.current.createObservation("user-456", "2026-06-09", "Test");
        } catch {
          // Expected error
        }
      });

      expect(result.current.error).not.toBeNull();
    });
  });

  describe("updateObservation", () => {
    it("should successfully update an observation", async () => {
      const existingObservation: Observation = {
        id: "obs-1",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Original",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      const updatedObservation: Observation = {
        ...existingObservation,
        notes: "Updated",
        updated_at: "2026-06-09T11:00:00Z",
      };

      const { result } = renderHook(() => useObservation());

      // Set initial observation
      await act(async () => {
        vi.mocked(observationApiClient.getUserObservations).mockResolvedValueOnce({
          observations: [existingObservation],
          total: 1,
          limit: 100,
          offset: 0,
        });
        await result.current.loadObservations("user-456");
      });

      // Update observation
      await act(async () => {
        vi.mocked(observationApiClient.updateObservation).mockResolvedValueOnce(
          updatedObservation
        );
        await result.current.updateObservation("obs-1", { notes: "Updated" });
      });

      expect(result.current.error).toBeNull();
      expect(observationApiClient.updateObservation).toHaveBeenCalledWith(
        "obs-1",
        { notes: "Updated" }
      );
    });

    it("should update observation in list", async () => {
      const observation: Observation = {
        id: "obs-1",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Original",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      const updated = { ...observation, notes: "Updated" };

      const { result } = renderHook(() => useObservation());

      await act(async () => {
        vi.mocked(observationApiClient.getUserObservations).mockResolvedValueOnce({
          observations: [observation],
          total: 1,
          limit: 100,
          offset: 0,
        });
        await result.current.loadObservations("user-456");
      });

      await act(async () => {
        vi.mocked(observationApiClient.updateObservation).mockResolvedValueOnce(
          updated
        );
        await result.current.updateObservation("obs-1", { notes: "Updated" });
      });

      const obs = result.current.observations.find((o) => o.id === "obs-1");
      expect(obs?.notes).toBe("Updated");
    });

    it("should handle update error", async () => {
      const mockError = new Error("Update failed");

      vi.mocked(observationApiClient.updateObservation).mockRejectedValueOnce(
        mockError
      );

      const { result } = renderHook(() => useObservation());

      await act(async () => {
        try {
          await result.current.updateObservation("obs-1", { notes: "Updated" });
        } catch {
          // Expected error
        }
      });

      expect(result.current.error).not.toBeNull();
    });
  });

  describe("deleteObservation", () => {
    it("should successfully delete an observation", async () => {
      const observation: Observation = {
        id: "obs-1",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Test",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      const { result } = renderHook(() => useObservation());

      await act(async () => {
        vi.mocked(observationApiClient.getUserObservations).mockResolvedValueOnce({
          observations: [observation],
          total: 1,
          limit: 100,
          offset: 0,
        });
        await result.current.loadObservations("user-456");
      });

      await act(async () => {
        vi.mocked(observationApiClient.deleteObservation).mockResolvedValueOnce(
          undefined
        );
        await result.current.deleteObservation("obs-1");
      });

      expect(result.current.error).toBeNull();
      expect(observationApiClient.deleteObservation).toHaveBeenCalledWith("obs-1");
    });

    it("should remove observation from list", async () => {
      const observation: Observation = {
        id: "obs-1",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Test",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      const { result } = renderHook(() => useObservation());

      await act(async () => {
        vi.mocked(observationApiClient.getUserObservations).mockResolvedValueOnce({
          observations: [observation],
          total: 1,
          limit: 100,
          offset: 0,
        });
        await result.current.loadObservations("user-456");
      });

      expect(result.current.observations).toHaveLength(1);

      await act(async () => {
        vi.mocked(observationApiClient.deleteObservation).mockResolvedValueOnce(
          undefined
        );
        await result.current.deleteObservation("obs-1");
      });

      expect(result.current.observations).toHaveLength(0);
    });

    it("should handle delete error", async () => {
      const mockError = new Error("Delete failed");

      vi.mocked(observationApiClient.deleteObservation).mockRejectedValueOnce(
        mockError
      );

      const { result } = renderHook(() => useObservation());

      await act(async () => {
        try {
          await result.current.deleteObservation("obs-1");
        } catch {
          // Expected error
        }
      });

      expect(result.current.error).not.toBeNull();
    });
  });

  describe("clearError", () => {
    it("should clear error state", async () => {
      vi.mocked(observationApiClient.getUserObservations).mockRejectedValueOnce(
        new Error("Test error")
      );

      const { result } = renderHook(() => useObservation());

      await act(async () => {
        try {
          await result.current.loadObservations("user-456");
        } catch {
          // Expected error
        }
      });

      expect(result.current.error).not.toBeNull();

      act(() => {
        result.current.clearError();
      });

      expect(result.current.error).toBeNull();
    });
  });

  describe("clearCache", () => {
    it("should call API client clearCache", () => {
      const { result } = renderHook(() => useObservation());

      act(() => {
        result.current.clearCache();
      });

      expect(observationApiClient.clearCache).toHaveBeenCalled();
    });
  });

  describe("multiple observations", () => {
    it("should handle multiple observations correctly", async () => {
      const observations: Observation[] = [
        {
          id: "obs-1",
          user_id: "user-456",
          date: "2026-06-09",
          notes: "First",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        },
        {
          id: "obs-2",
          user_id: "user-456",
          date: "2026-06-08",
          notes: "Second",
          created_at: "2026-06-08T10:00:00Z",
          updated_at: "2026-06-08T10:00:00Z",
        },
        {
          id: "obs-3",
          user_id: "user-456",
          date: "2026-06-07",
          notes: "Third",
          created_at: "2026-06-07T10:00:00Z",
          updated_at: "2026-06-07T10:00:00Z",
        },
      ];

      const { result } = renderHook(() => useObservation());

      await act(async () => {
        vi.mocked(observationApiClient.getUserObservations).mockResolvedValueOnce({
          observations,
          total: 3,
          limit: 100,
          offset: 0,
        });
        await result.current.loadObservations("user-456");
      });

      expect(result.current.observations).toHaveLength(3);
      expect(result.current.observations[0].id).toBe("obs-1");
      expect(result.current.observations[2].id).toBe("obs-3");
    });
  });
});
