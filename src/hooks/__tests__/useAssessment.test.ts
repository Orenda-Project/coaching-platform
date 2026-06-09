/**
 * useAssessment Hook Tests
 *
 * Test coverage for:
 * - State management
 * - API integration
 * - Error handling
 * - Session restoration
 */

import { describe, it, expect, beforeEach, vi } from "vitest";
import { renderHook, act, waitFor } from "@testing-library/react";
import { useAssessment } from "../useAssessment";
import * as assessmentClient from "@/lib/apiClients/assessmentApiClient";

vi.mock("@/lib/apiClients/assessmentApiClient");

const mockAssessment = {
  id: "assessment-123",
  user_id: "user-123",
  module_id: "module-456",
  type: "baseline" as const,
  status: "in_progress" as const,
  attempts: 0,
  score: null,
  passed: null,
  started_at: "2026-01-01T00:00:00Z",
  completed_at: null,
  created_at: "2026-01-01T00:00:00Z",
};

const mockAssessmentResponse = {
  assessments: [mockAssessment],
  total: 1,
};

const mockResults = {
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

describe("useAssessment Hook", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("Initial State", () => {
    it("should have default state on mount", () => {
      const { result } = renderHook(() => useAssessment());

      expect(result.current.assessment).toBeNull();
      expect(result.current.loading).toBe(false);
      expect(result.current.error).toBeNull();
      expect(result.current.responses).toEqual({});
    });
  });

  describe("loadAssessment", () => {
    it("should load assessment and set state", async () => {
      const mockGetAssessment = vi.fn().mockResolvedValue(mockAssessment);
      vi.mocked(assessmentClient.assessmentApiClient).getAssessment = mockGetAssessment;

      const { result } = renderHook(() => useAssessment());

      await act(async () => {
        await result.current.loadAssessment("assessment-123");
      });

      expect(result.current.assessment).toEqual(mockAssessment);
      expect(result.current.loading).toBe(false);
      expect(result.current.error).toBeNull();
      expect(mockGetAssessment).toHaveBeenCalledWith("assessment-123");
    });

    it("should clear loading state after fetch completes", async () => {
      const mockGetAssessment = vi.fn().mockResolvedValue(mockAssessment);
      vi.mocked(assessmentClient.assessmentApiClient).getAssessment = mockGetAssessment;

      const { result } = renderHook(() => useAssessment());

      expect(result.current.loading).toBe(false);

      await act(async () => {
        await result.current.loadAssessment("assessment-123");
      });

      expect(result.current.loading).toBe(false);
      expect(result.current.assessment).toEqual(mockAssessment);
    });

    it("should handle errors and set error state", async () => {
      const error = new Error("Failed to load assessment");
      const mockGetAssessment = vi.fn().mockRejectedValue(error);
      vi.mocked(assessmentClient.assessmentApiClient).getAssessment = mockGetAssessment;

      const { result } = renderHook(() => useAssessment());

      await act(async () => {
        try {
          await result.current.loadAssessment("assessment-123");
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();
      expect(result.current.error?.message).toBe("Failed to load assessment");
    });

    it("should clear previous error on successful load", async () => {
      const mockGetAssessment = vi.fn().mockResolvedValue(mockAssessment);
      vi.mocked(assessmentClient.assessmentApiClient).getAssessment = mockGetAssessment;

      const { result, rerender } = renderHook(() => useAssessment());

      // First, simulate an error state
      await act(async () => {
        const failingClient = vi.fn().mockRejectedValue(new Error("First error"));
        vi.mocked(assessmentClient.assessmentApiClient).getAssessment = failingClient;
        try {
          await result.current.loadAssessment("assessment-123");
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();

      // Now load successfully
      vi.mocked(assessmentClient.assessmentApiClient).getAssessment = mockGetAssessment;
      await act(async () => {
        await result.current.loadAssessment("assessment-123");
      });

      expect(result.current.error).toBeNull();
      expect(result.current.assessment).toEqual(mockAssessment);
    });
  });

  describe("submitAssessment", () => {
    it("should submit responses and update assessment", async () => {
      const updatedAssessment = {
        ...mockAssessment,
        status: "completed" as const,
        score: 80,
        passed: true,
      };

      const mockSubmit = vi.fn().mockResolvedValue(updatedAssessment);
      vi.mocked(assessmentClient.assessmentApiClient).submitAssessment = mockSubmit;

      const { result } = renderHook(() => useAssessment());

      const responses = {
        "question-1": "answer-a",
        "question-2": "answer-b",
      };

      await act(async () => {
        await result.current.submitAssessment("assessment-123", responses);
      });

      expect(result.current.assessment).toEqual(updatedAssessment);
      expect(result.current.responses).toEqual(responses);
      expect(mockSubmit).toHaveBeenCalledWith("assessment-123", responses);
    });

    it("should handle submission errors", async () => {
      const error = new Error("Submission failed");
      const mockSubmit = vi.fn().mockRejectedValue(error);
      vi.mocked(assessmentClient.assessmentApiClient).submitAssessment = mockSubmit;

      const { result } = renderHook(() => useAssessment());

      await act(async () => {
        try {
          await result.current.submitAssessment("assessment-123", {});
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();
      expect(result.current.error?.message).toBe("Submission failed");
    });

    it("should preserve responses in state", async () => {
      const mockSubmit = vi.fn().mockResolvedValue({
        ...mockAssessment,
        status: "completed" as const,
      });
      vi.mocked(assessmentClient.assessmentApiClient).submitAssessment = mockSubmit;

      const { result } = renderHook(() => useAssessment());

      const responses = {
        "q-1": "option-a",
        "q-2": "option-c",
      };

      await act(async () => {
        await result.current.submitAssessment("assessment-123", responses);
      });

      expect(result.current.responses).toEqual(responses);
    });
  });

  describe("getHistory", () => {
    it("should fetch assessment history", async () => {
      const mockGetHistory = vi.fn().mockResolvedValue(mockAssessmentResponse);
      vi.mocked(assessmentClient.assessmentApiClient).getAssessmentHistory =
        mockGetHistory;

      const { result } = renderHook(() => useAssessment());

      let history;
      await act(async () => {
        history = await result.current.getHistory("user-123", 10);
      });

      expect(history).toEqual(mockAssessmentResponse);
      expect(mockGetHistory).toHaveBeenCalledWith("user-123", 10);
    });

    it("should use default limit if not provided", async () => {
      const mockGetHistory = vi.fn().mockResolvedValue(mockAssessmentResponse);
      vi.mocked(assessmentClient.assessmentApiClient).getAssessmentHistory =
        mockGetHistory;

      const { result } = renderHook(() => useAssessment());

      await act(async () => {
        await result.current.getHistory("user-123");
      });

      expect(mockGetHistory).toHaveBeenCalledWith("user-123", undefined);
    });

    it("should handle history fetch errors", async () => {
      const error = new Error("History fetch failed");
      const mockGetHistory = vi.fn().mockRejectedValue(error);
      vi.mocked(assessmentClient.assessmentApiClient).getAssessmentHistory =
        mockGetHistory;

      const { result } = renderHook(() => useAssessment());

      await act(async () => {
        try {
          await result.current.getHistory("user-123");
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();
    });
  });

  describe("clearError", () => {
    it("should clear error state", async () => {
      const mockGetAssessment = vi.fn().mockRejectedValue(new Error("Test error"));
      vi.mocked(assessmentClient.assessmentApiClient).getAssessment =
        mockGetAssessment;

      const { result } = renderHook(() => useAssessment());

      await act(async () => {
        try {
          await result.current.loadAssessment("assessment-123");
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

  describe("State Immutability", () => {
    it("should preserve assessment data across renders", async () => {
      const mockGetAssessment = vi.fn().mockResolvedValue(mockAssessment);
      vi.mocked(assessmentClient.assessmentApiClient).getAssessment =
        mockGetAssessment;

      const { result, rerender } = renderHook(() => useAssessment());

      await act(async () => {
        await result.current.loadAssessment("assessment-123");
      });

      const firstRenderData = result.current.assessment?.id;

      // Rerender the hook
      rerender();

      const secondRenderData = result.current.assessment?.id;

      // Data should be the same across renders
      expect(firstRenderData).toBe(secondRenderData);
      expect(result.current.assessment?.id).toBe("assessment-123");
    });
  });

  describe("Multiple Sequential Calls", () => {
    it("should handle multiple loadAssessment calls", async () => {
      const assessment1 = { ...mockAssessment, id: "a-1" };
      const assessment2 = { ...mockAssessment, id: "a-2" };

      const mockGetAssessment = vi
        .fn()
        .mockResolvedValueOnce(assessment1)
        .mockResolvedValueOnce(assessment2);

      vi.mocked(assessmentClient.assessmentApiClient).getAssessment =
        mockGetAssessment;

      const { result } = renderHook(() => useAssessment());

      await act(async () => {
        await result.current.loadAssessment("a-1");
      });
      expect(result.current.assessment?.id).toBe("a-1");

      await act(async () => {
        await result.current.loadAssessment("a-2");
      });
      expect(result.current.assessment?.id).toBe("a-2");
    });
  });

  describe("Error User-Friendly Messages", () => {
    it("should provide user-friendly error message on network failure", async () => {
      const networkError = new Error("Network error");
      const mockGetAssessment = vi.fn().mockRejectedValue(networkError);
      vi.mocked(assessmentClient.assessmentApiClient).getAssessment =
        mockGetAssessment;

      const { result } = renderHook(() => useAssessment());

      await act(async () => {
        try {
          await result.current.loadAssessment("assessment-123");
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();
      expect(result.current.error?.message).toBeDefined();
    });

    it("should provide user-friendly error message on server error", async () => {
      const apiError = new Error("Failed to fetch assessment") as any;
      apiError.status = 500;
      const mockGetAssessment = vi.fn().mockRejectedValue(apiError);
      vi.mocked(assessmentClient.assessmentApiClient).getAssessment =
        mockGetAssessment;

      const { result } = renderHook(() => useAssessment());

      await act(async () => {
        try {
          await result.current.loadAssessment("assessment-123");
        } catch {
          // Expected
        }
      });

      expect(result.current.error).toBeTruthy();
      expect(result.current.error?.status).toBe(500);
    });
  });
});
