/**
 * Observation API Client Tests
 *
 * Comprehensive test coverage for:
 * - All 8 observation API methods
 * - Error handling and retry logic
 * - Cache management
 * - COT (Classroom Observation Tool) responses
 * - Bulk operations
 */

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import {
  ObservationApiClient,
  type CreateObservationPayload,
  type Observation,
  type COTResponse,
  type ApiError,
} from "../observationApiClient";

describe("ObservationApiClient", () => {
  let client: ObservationApiClient;
  let fetchMock: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    client = new ObservationApiClient("http://localhost:8000");
    fetchMock = vi.fn();
    global.fetch = fetchMock;
  });

  afterEach(() => {
    vi.clearAllMocks();
    client.clearCache();
  });

  describe("createObservation", () => {
    it("should successfully create an observation", async () => {
      const mockResponse: Observation = {
        id: "obs-123",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Student showed engagement in group discussion",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.createObservation(
        "user-456",
        "2026-06-09",
        "Student showed engagement in group discussion"
      );

      expect(result.id).toBe("obs-123");
      expect(result.notes).toBe("Student showed engagement in group discussion");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/observations",
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify({
            user_id: "user-456",
            date: "2026-06-09",
            notes: "Student showed engagement in group discussion",
          }),
        })
      );
    });

    it("should handle missing user error", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({
          detail: "User not found",
        }),
      });

      await expect(
        client.createObservation("user-999", "2026-06-09", "Test")
      ).rejects.toThrow("User not found");
    });

    it("should handle validation error", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 400,
        text: async () => JSON.stringify({
          detail: "Invalid date format",
        }),
      });

      await expect(
        client.createObservation("user-456", "invalid-date", "Test")
      ).rejects.toThrow("Invalid date format");
    });

    it("should retry on server error", async () => {
      const mockResponse: Observation = {
        id: "obs-123",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Test",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      fetchMock
        .mockResolvedValueOnce({ ok: false, status: 500, text: async () => "" })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

      const result = await client.createObservation("user-456", "2026-06-09", "Test");

      expect(result.id).toBe("obs-123");
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });

  describe("getObservation", () => {
    it("should successfully fetch an observation", async () => {
      const mockResponse: Observation = {
        id: "obs-123",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Student engaged",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getObservation("obs-123");

      expect(result.id).toBe("obs-123");
      expect(result.notes).toBe("Student engaged");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/observations/obs-123",
        expect.any(Object)
      );
    });

    it("should cache observation data", async () => {
      const mockResponse: Observation = {
        id: "obs-123",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Student engaged",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      // First call
      await client.getObservation("obs-123");
      // Second call (should use cache)
      await client.getObservation("obs-123");

      // Should only fetch once due to cache
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });

    it("should handle not found error", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({
          detail: "Observation not found",
        }),
      });

      await expect(client.getObservation("obs-999")).rejects.toThrow(
        "Observation not found"
      );
    });
  });

  describe("getUserObservations", () => {
    it("should successfully fetch user observations with pagination", async () => {
      const mockResponse = {
        observations: [
          {
            id: "obs-1",
            user_id: "user-456",
            date: "2026-06-09",
            notes: "Observation 1",
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T10:00:00Z",
          },
          {
            id: "obs-2",
            user_id: "user-456",
            date: "2026-06-08",
            notes: "Observation 2",
            created_at: "2026-06-08T10:00:00Z",
            updated_at: "2026-06-08T10:00:00Z",
          },
        ],
        total: 2,
        limit: 10,
        offset: 0,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getUserObservations("user-456", 10, 0);

      expect(result.observations).toHaveLength(2);
      expect(result.total).toBe(2);
      expect(fetchMock).toHaveBeenCalledWith(
        expect.stringContaining("http://localhost:8000/api/observations/user/user-456"),
        expect.any(Object)
      );
    });

    it("should support pagination parameters", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ observations: [], total: 0, limit: 5, offset: 10 }),
      });

      await client.getUserObservations("user-456", 5, 10);

      expect(fetchMock).toHaveBeenCalledWith(
        expect.stringContaining("limit=5&offset=10"),
        expect.any(Object)
      );
    });

    it("should handle user not found error", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({
          detail: "User not found",
        }),
      });

      await expect(client.getUserObservations("user-999")).rejects.toThrow(
        "User not found"
      );
    });
  });

  describe("updateObservation", () => {
    it("should successfully update an observation", async () => {
      const mockResponse: Observation = {
        id: "obs-123",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Updated notes",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T11:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.updateObservation("obs-123", {
        notes: "Updated notes",
      });

      expect(result.notes).toBe("Updated notes");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/observations/obs-123",
        expect.objectContaining({
          method: "PUT",
          body: JSON.stringify({ notes: "Updated notes" }),
        })
      );
    });

    it("should invalidate cache on update", async () => {
      const mockResponse: Observation = {
        id: "obs-123",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Original",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      const updatedResponse: Observation = {
        ...mockResponse,
        notes: "Updated",
        updated_at: "2026-06-09T11:00:00Z",
      };

      fetchMock
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => updatedResponse,
        });

      // Get the observation (caches it)
      await client.getObservation("obs-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      // Update the observation (invalidates cache, then sets new cache with response)
      const updated = await client.updateObservation("obs-123", { notes: "Updated" });
      expect(fetchMock).toHaveBeenCalledTimes(2);
      expect(updated.notes).toBe("Updated");

      // Get again should use cache from update
      const cached = await client.getObservation("obs-123");
      expect(cached.notes).toBe("Updated");
      expect(fetchMock).toHaveBeenCalledTimes(2); // Still 2, using cache from update
    });

    it("should handle not found error on update", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({
          detail: "Observation not found",
        }),
      });

      await expect(
        client.updateObservation("obs-999", { notes: "Test" })
      ).rejects.toThrow("Observation not found");
    });
  });

  describe("deleteObservation", () => {
    it("should successfully delete an observation", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ message: "Observation deleted" }),
      });

      await client.deleteObservation("obs-123");

      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/observations/obs-123",
        expect.objectContaining({
          method: "DELETE",
        })
      );
    });

    it("should handle not found error on delete", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({
          detail: "Observation not found",
        }),
      });

      await expect(client.deleteObservation("obs-999")).rejects.toThrow(
        "Observation not found"
      );
    });

    it("should invalidate cache on delete", async () => {
      const mockObservation: Observation = {
        id: "obs-123",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Test",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      fetchMock
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockObservation,
        })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ message: "Deleted" }),
        })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockObservation,
        });

      // Get the observation (caches it)
      await client.getObservation("obs-123");

      // Delete the observation
      await client.deleteObservation("obs-123");

      // Get again (should make a new request)
      await client.getObservation("obs-123");

      expect(fetchMock).toHaveBeenCalledTimes(3);
    });
  });

  describe("createCOTObservation", () => {
    it("should successfully create a COT observation", async () => {
      const mockResponse: COTResponse = {
        id: "cot-123",
        observation_id: "obs-123",
        category: "engagement",
        response: "High engagement observed",
        rating: 4,
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.createCOTObservation(
        "obs-123",
        "engagement",
        "High engagement observed",
        4
      );

      expect(result.id).toBe("cot-123");
      expect(result.rating).toBe(4);
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/observations/obs-123/cot",
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify({
            category: "engagement",
            response: "High engagement observed",
            rating: 4,
          }),
        })
      );
    });

    it("should validate rating range (1-5)", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 400,
        text: async () => JSON.stringify({
          detail: "Rating must be between 1 and 5",
        }),
      });

      await expect(
        client.createCOTObservation("obs-123", "engagement", "Test", 10)
      ).rejects.toThrow("Rating must be between 1 and 5");
    });

    it("should handle invalid category error", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 400,
        text: async () => JSON.stringify({
          detail: "Invalid category",
        }),
      });

      await expect(
        client.createCOTObservation("obs-123", "invalid", "Test", 3)
      ).rejects.toThrow("Invalid category");
    });
  });

  describe("getCOTResponses", () => {
    it("should successfully fetch COT responses for an observation", async () => {
      const mockResponse = {
        cot_responses: [
          {
            id: "cot-1",
            observation_id: "obs-123",
            category: "engagement",
            response: "Student active",
            rating: 4,
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T10:00:00Z",
          },
          {
            id: "cot-2",
            observation_id: "obs-123",
            category: "behavior",
            response: "Cooperative",
            rating: 5,
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T10:00:00Z",
          },
        ],
        total: 2,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getCOTResponses("obs-123");

      expect(result.cot_responses).toHaveLength(2);
      expect(result.total).toBe(2);
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/observations/obs-123/cot",
        expect.any(Object)
      );
    });

    it("should handle observation not found error", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({
          detail: "Observation not found",
        }),
      });

      await expect(client.getCOTResponses("obs-999")).rejects.toThrow(
        "Observation not found"
      );
    });
  });

  describe("bulkSaveObservations", () => {
    it("should successfully bulk save observations", async () => {
      const observations = [
        {
          user_id: "user-1",
          date: "2026-06-09",
          notes: "Observation 1",
        },
        {
          user_id: "user-2",
          date: "2026-06-09",
          notes: "Observation 2",
        },
      ];

      const mockResponse = {
        created: 2,
        updated: 0,
        failed: 0,
        observations: [
          {
            id: "obs-1",
            user_id: "user-1",
            date: "2026-06-09",
            notes: "Observation 1",
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T10:00:00Z",
          },
          {
            id: "obs-2",
            user_id: "user-2",
            date: "2026-06-09",
            notes: "Observation 2",
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T10:00:00Z",
          },
        ],
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.bulkSaveObservations(observations);

      expect(result.created).toBe(2);
      expect(result.observations).toHaveLength(2);
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/observations/bulk",
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify({ observations }),
        })
      );
    });

    it("should handle partial failure in bulk operations", async () => {
      const observations = [
        { user_id: "user-1", date: "2026-06-09", notes: "Obs 1" },
        { user_id: "user-999", date: "2026-06-09", notes: "Obs 2" },
      ];

      const mockResponse = {
        created: 1,
        updated: 0,
        failed: 1,
        observations: [
          {
            id: "obs-1",
            user_id: "user-1",
            date: "2026-06-09",
            notes: "Obs 1",
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T10:00:00Z",
          },
        ],
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.bulkSaveObservations(observations);

      expect(result.created).toBe(1);
      expect(result.failed).toBe(1);
    });

    it("should handle server error on bulk save", async () => {
      const observations = [
        { user_id: "user-1", date: "2026-06-09", notes: "Test" },
      ];

      // Mock all 3 retries with 500 error
      fetchMock
        .mockResolvedValueOnce({
          ok: false,
          status: 500,
          text: async () => JSON.stringify({
            detail: "Server error",
          }),
        })
        .mockResolvedValueOnce({
          ok: false,
          status: 500,
          text: async () => JSON.stringify({
            detail: "Server error",
          }),
        })
        .mockResolvedValueOnce({
          ok: false,
          status: 500,
          text: async () => JSON.stringify({
            detail: "Server error",
          }),
        });

      await expect(client.bulkSaveObservations(observations)).rejects.toThrow();
    });
  });

  describe("Cache invalidation", () => {
    it("should clear all cache", async () => {
      const mockResponse: Observation = {
        id: "obs-123",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Test",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      fetchMock.mockResolvedValue({
        ok: true,
        json: async () => mockResponse,
      });

      // Cache an observation
      await client.getObservation("obs-123");

      // Clear cache
      client.clearCache();

      // Fetch again (should make a new request)
      await client.getObservation("obs-123");

      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });

  describe("Error handling", () => {
    it("should normalize errors consistently", async () => {
      fetchMock.mockRejectedValueOnce(new Error("Network error"));

      await expect(
        client.createObservation("user-456", "2026-06-09", "Test")
      ).rejects.toThrow();
    });

    it("should retry on network errors", async () => {
      const mockResponse: Observation = {
        id: "obs-123",
        user_id: "user-456",
        date: "2026-06-09",
        notes: "Test",
        created_at: "2026-06-09T10:00:00Z",
        updated_at: "2026-06-09T10:00:00Z",
      };

      fetchMock
        .mockRejectedValueOnce(new Error("Network error"))
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

      const result = await client.createObservation("user-456", "2026-06-09", "Test");

      expect(result.id).toBe("obs-123");
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });

    it("should fail after max retries on persistent network error", async () => {
      fetchMock.mockRejectedValue(new Error("Network error"));

      await expect(
        client.createObservation("user-456", "2026-06-09", "Test")
      ).rejects.toThrow();

      // Should retry 3 times
      expect(fetchMock).toHaveBeenCalledTimes(3);
    });
  });
});
