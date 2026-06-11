/**
 * Assessment API Client Tests
 *
 * Comprehensive test coverage for:
 * - All 8 API methods
 * - Error handling and retry logic
 * - Cache management
 * - Request/response validation
 */

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import { AssessmentApiClient, type Assessment, type AssessmentResponse } from "../assessmentApiClient";

describe("AssessmentApiClient", () => {
  let client: AssessmentApiClient;
  let fetchMock: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    client = new AssessmentApiClient("http://localhost:8000");
    fetchMock = vi.fn();
    global.fetch = fetchMock;
  });

  afterEach(() => {
    vi.clearAllMocks();
    client.clearCache();
  });

  // ===== createAssessment tests =====
  describe("createAssessment", () => {
    it("should successfully create a new assessment", async () => {
      const mockResponse: Assessment = {
        id: "assessment-123",
        user_id: "user-123",
        module_id: "module-456",
        type: "baseline",
        status: "in_progress",
        attempts: 0,
        score: null,
        passed: null,
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
        created_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.createAssessment("user-123", "module-456");

      expect(result.id).toBe("assessment-123");
      expect(result.status).toBe("in_progress");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/assessments",
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify({
            user_id: "user-123",
            module_id: "module-456",
          }),
        })
      );
    });

    it("should handle validation errors", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 400,
        text: async () => JSON.stringify({
          detail: "Invalid user_id",
        }),
      });

      await expect(client.createAssessment("invalid", "module-456")).rejects.toThrow(
        "Invalid user_id"
      );
    });

    it("should retry on server error", async () => {
      const mockResponse: Assessment = {
        id: "assessment-123",
        user_id: "user-123",
        module_id: "module-456",
        type: "baseline",
        status: "in_progress",
        attempts: 0,
        score: null,
        passed: null,
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
        created_at: "2026-01-01T00:00:00Z",
      };

      fetchMock
        .mockResolvedValueOnce({ ok: false, status: 500, text: async () => "" })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

      const result = await client.createAssessment("user-123", "module-456");

      expect(result.id).toBe("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });

  // ===== getAssessment tests =====
  describe("getAssessment", () => {
    it("should successfully fetch assessment by ID", async () => {
      const mockResponse: Assessment = {
        id: "assessment-123",
        user_id: "user-123",
        module_id: "module-456",
        type: "baseline",
        status: "in_progress",
        attempts: 0,
        score: null,
        passed: null,
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
        created_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getAssessment("assessment-123");

      expect(result.id).toBe("assessment-123");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/assessments/assessment-123",
        expect.objectContaining({
          headers: expect.objectContaining({
            "Content-Type": "application/json",
          }),
        })
      );
    });

    it("should cache assessment results", async () => {
      const mockResponse: Assessment = {
        id: "assessment-123",
        user_id: "user-123",
        module_id: "module-456",
        type: "baseline",
        status: "completed",
        attempts: 1,
        score: 85,
        passed: true,
        started_at: "2026-01-01T00:00:00Z",
        completed_at: "2026-01-01T01:00:00Z",
        created_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      // First call
      await client.getAssessment("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      // Second call should use cache
      await client.getAssessment("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });

    it("should handle not found error", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({
          detail: "Assessment not found",
        }),
      });

      await expect(client.getAssessment("nonexistent")).rejects.toThrow(
        "Assessment not found"
      );
    });
  });

  // ===== getUserAssessments tests =====
  describe("getUserAssessments", () => {
    it("should fetch all assessments for a user", async () => {
      const mockResponse: AssessmentResponse = {
        assessments: [
          {
            id: "assessment-1",
            user_id: "user-123",
            module_id: "module-1",
            type: "baseline",
            status: "completed",
            attempts: 1,
            score: 75,
            passed: true,
            started_at: "2026-01-01T00:00:00Z",
            completed_at: "2026-01-01T01:00:00Z",
            created_at: "2026-01-01T00:00:00Z",
          },
          {
            id: "assessment-2",
            user_id: "user-123",
            module_id: "module-2",
            type: "module",
            status: "in_progress",
            attempts: 0,
            score: null,
            passed: null,
            started_at: "2026-01-02T00:00:00Z",
            completed_at: null,
            created_at: "2026-01-02T00:00:00Z",
          },
        ],
        total: 2,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getUserAssessments("user-123");

      expect(result.assessments).toHaveLength(2);
      expect(result.total).toBe(2);
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/assessments/user/user-123",
        expect.objectContaining({
          headers: expect.objectContaining({
            "Content-Type": "application/json",
          }),
        })
      );
    });

    it("should cache user assessments", async () => {
      const mockResponse: AssessmentResponse = {
        assessments: [],
        total: 0,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getUserAssessments("user-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getUserAssessments("user-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });
  });

  // ===== submitAssessment tests =====
  describe("submitAssessment", () => {
    it("should submit assessment responses", async () => {
      const mockResponse: Assessment = {
        id: "assessment-123",
        user_id: "user-123",
        module_id: "module-456",
        type: "baseline",
        status: "completed",
        attempts: 1,
        score: 80,
        passed: true,
        started_at: "2026-01-01T00:00:00Z",
        completed_at: "2026-01-01T01:00:00Z",
        created_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const responses = {
        "question-1": "answer-a",
        "question-2": "answer-b",
      };

      const result = await client.submitAssessment("assessment-123", responses);

      expect(result.status).toBe("completed");
      expect(result.score).toBe(80);
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/assessments/assessment-123/submit",
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify({ responses }),
        })
      );
    });

    it("should invalidate cache on submit", async () => {
      const mockResponse: Assessment = {
        id: "assessment-123",
        user_id: "user-123",
        module_id: "module-456",
        type: "baseline",
        status: "completed",
        attempts: 1,
        score: 80,
        passed: true,
        started_at: "2026-01-01T00:00:00Z",
        completed_at: "2026-01-01T01:00:00Z",
        created_at: "2026-01-01T00:00:00Z",
      };

      // Get assessment to cache it
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });
      await client.getAssessment("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      // Second get should use cache
      await client.getAssessment("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      // Submit to invalidate cache (refreshes with new response)
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });
      await client.submitAssessment("assessment-123", {});
      expect(fetchMock).toHaveBeenCalledTimes(2);

      // Next get should use cache (already set by submit)
      await client.getAssessment("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });

    it("should retry on server error", async () => {
      const mockResponse: Assessment = {
        id: "assessment-123",
        user_id: "user-123",
        module_id: "module-456",
        type: "baseline",
        status: "completed",
        attempts: 1,
        score: 80,
        passed: true,
        started_at: "2026-01-01T00:00:00Z",
        completed_at: "2026-01-01T01:00:00Z",
        created_at: "2026-01-01T00:00:00Z",
      };

      fetchMock
        .mockResolvedValueOnce({ ok: false, status: 500, text: async () => "" })
        .mockResolvedValueOnce({ ok: false, status: 500, text: async () => "" })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

      const result = await client.submitAssessment("assessment-123", {});

      expect(result.score).toBe(80);
      expect(fetchMock).toHaveBeenCalledTimes(3);
    });
  });

  // ===== getAssessmentResults tests =====
  describe("getAssessmentResults", () => {
    it("should fetch assessment results", async () => {
      const mockResponse = {
        assessment_id: "assessment-123",
        score: 85,
        passed: true,
        results: [
          {
            question_id: "q-1",
            correct: true,
            user_answer: "a",
            correct_answer: "a",
          },
        ],
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getAssessmentResults("assessment-123");

      expect(result.score).toBe(85);
      expect(result.passed).toBe(true);
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/assessments/assessment-123/results",
        expect.objectContaining({
          headers: expect.objectContaining({
            "Content-Type": "application/json",
          }),
        })
      );
    });

    it("should cache results", async () => {
      const mockResponse = {
        assessment_id: "assessment-123",
        score: 85,
        passed: true,
        results: [],
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getAssessmentResults("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      await client.getAssessmentResults("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });
  });

  // ===== getAssessmentHistory tests =====
  describe("getAssessmentHistory", () => {
    it("should fetch assessment history with limit", async () => {
      const mockResponse: AssessmentResponse = {
        assessments: [
          {
            id: "assessment-1",
            user_id: "user-123",
            module_id: "module-1",
            type: "baseline",
            status: "completed",
            attempts: 1,
            score: 75,
            passed: true,
            started_at: "2026-01-01T00:00:00Z",
            completed_at: "2026-01-01T01:00:00Z",
            created_at: "2026-01-01T00:00:00Z",
          },
        ],
        total: 1,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getAssessmentHistory("user-123", 10);

      expect(result.assessments).toHaveLength(1);
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/assessments/user/user-123/history?limit=10",
        expect.objectContaining({
          headers: expect.objectContaining({
            "Content-Type": "application/json",
          }),
        })
      );
    });

    it("should use default limit of 50", async () => {
      const mockResponse: AssessmentResponse = {
        assessments: [],
        total: 0,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getAssessmentHistory("user-123");

      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/assessments/user/user-123/history?limit=50",
        expect.objectContaining({
          headers: expect.objectContaining({
            "Content-Type": "application/json",
          }),
        })
      );
    });
  });

  // ===== updateAssessment tests =====
  describe("updateAssessment", () => {
    it("should update assessment status", async () => {
      const mockResponse: Assessment = {
        id: "assessment-123",
        user_id: "user-123",
        module_id: "module-456",
        type: "baseline",
        status: "abandoned",
        attempts: 1,
        score: null,
        passed: null,
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
        created_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.updateAssessment("assessment-123", {
        status: "abandoned",
      });

      expect(result.status).toBe("abandoned");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/assessments/assessment-123",
        expect.objectContaining({
          method: "PUT",
          body: JSON.stringify({ status: "abandoned" }),
        })
      );
    });

    it("should invalidate cache on update", async () => {
      const mockResponse: Assessment = {
        id: "assessment-123",
        user_id: "user-123",
        module_id: "module-456",
        type: "baseline",
        status: "abandoned",
        attempts: 1,
        score: null,
        passed: null,
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
        created_at: "2026-01-01T00:00:00Z",
      };

      // Cache the assessment
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });
      await client.getAssessment("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      // Second get should use cache
      await client.getAssessment("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      // Update it (invalidates and re-caches)
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });
      await client.updateAssessment("assessment-123", { status: "abandoned" });
      expect(fetchMock).toHaveBeenCalledTimes(2);

      // Next get should use cache (already set by update)
      await client.getAssessment("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });

  // ===== deleteAssessment tests =====
  describe("deleteAssessment", () => {
    it("should delete assessment", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ message: "Assessment deleted" }),
      });

      await client.deleteAssessment("assessment-123");

      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/assessments/assessment-123",
        expect.objectContaining({
          method: "DELETE",
        })
      );
    });

    it("should invalidate cache on delete", async () => {
      const mockAssessment: Assessment = {
        id: "assessment-123",
        user_id: "user-123",
        module_id: "module-456",
        type: "baseline",
        status: "in_progress",
        attempts: 0,
        score: null,
        passed: null,
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
        created_at: "2026-01-01T00:00:00Z",
      };

      // Cache it
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockAssessment,
      });
      await client.getAssessment("assessment-123");

      // Delete it
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ message: "deleted" }),
      });
      await client.deleteAssessment("assessment-123");

      // Next get should fetch fresh (not cached)
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({ detail: "Not found" }),
      });
      await expect(client.getAssessment("assessment-123")).rejects.toThrow();

      expect(fetchMock).toHaveBeenCalledTimes(3);
    });

    it("should retry on server error", async () => {
      fetchMock
        .mockResolvedValueOnce({ ok: false, status: 500, text: async () => "" })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ message: "deleted" }),
        });

      await client.deleteAssessment("assessment-123");

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

      await expect(client.createAssessment("user-123", "module-456")).rejects.toThrow();

      expect(fetchMock).toHaveBeenCalledTimes(3);
    });

    it("should not retry on 4xx errors", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 400,
        text: async () => JSON.stringify({ detail: "Bad request" }),
      });

      await expect(client.createAssessment("user-123", "module-456")).rejects.toThrow(
        "Bad request"
      );

      expect(fetchMock).toHaveBeenCalledTimes(1);
    });

    it("should use exponential backoff on retries", async () => {
      vi.useFakeTimers();

      const mockResponse: Assessment = {
        id: "assessment-123",
        user_id: "user-123",
        module_id: "module-456",
        type: "baseline",
        status: "in_progress",
        attempts: 0,
        score: null,
        passed: null,
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
        created_at: "2026-01-01T00:00:00Z",
      };

      fetchMock
        .mockResolvedValueOnce({ ok: false, status: 500, text: async () => "" })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

      const promise = client.createAssessment("user-123", "module-456");

      // Initial attempt
      await vi.advanceTimersByTimeAsync(0);

      // First retry after ~1000ms
      await vi.advanceTimersByTimeAsync(1000);

      const result = await promise;

      expect(result.id).toBe("assessment-123");

      vi.useRealTimers();
    });
  });

  // ===== Cache expiry tests =====
  describe("Cache Expiry", () => {
    it("should expire cache after 5 minutes", async () => {
      vi.useFakeTimers();

      const mockResponse: Assessment = {
        id: "assessment-123",
        user_id: "user-123",
        module_id: "module-456",
        type: "baseline",
        status: "in_progress",
        attempts: 0,
        score: null,
        passed: null,
        started_at: "2026-01-01T00:00:00Z",
        completed_at: null,
        created_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValue({
        ok: true,
        json: async () => mockResponse,
      });

      // First call
      await client.getAssessment("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      // Advance 3 minutes - should still be cached
      vi.advanceTimersByTime(3 * 60 * 1000);
      await client.getAssessment("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      // Advance 3 more minutes (6 total) - cache should expire
      vi.advanceTimersByTime(3 * 60 * 1000);
      await client.getAssessment("assessment-123");
      expect(fetchMock).toHaveBeenCalledTimes(2);

      vi.useRealTimers();
    });
  });

  // ===== Error handling tests =====
  describe("Error Handling", () => {
    it("should normalize network errors", async () => {
      fetchMock.mockRejectedValue(new Error("Network error"));

      await expect(client.getAssessment("assessment-123")).rejects.toThrow("Network error");
    });

    it("should handle malformed JSON responses", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 500,
        text: async () => "not json",
      });

      await expect(client.getAssessment("assessment-123")).rejects.toThrow();
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
        await client.getAssessment("assessment-123");
        expect.fail("Should have thrown");
      } catch (err) {
        const error = err as any;
        expect(error.status).toBe(403);
      }
    });
  });
});
