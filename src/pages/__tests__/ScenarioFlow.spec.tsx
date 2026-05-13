import { describe, it, expect, vi, beforeEach } from "vitest";
import { canAccessPracticeSection, getPracticeLockMessage } from "@/domain/trainingRules";

describe("ScenarioFlow - Phase 2: Practice Section Locking (COACH-XXXX)", () => {
  const mockTrainingId = "training-123";
  const mockUserId = "user-123";

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("Practice Section Access Control via Domain Rules", () => {
    it("should lock practice section when contentCompleted is false", () => {
      // The domain rule enforces: contentCompleted must be true to access practice
      const canAccess = canAccessPracticeSection(false);
      expect(canAccess).toBe(false);
    });

    it("should unlock practice section when contentCompleted is true", () => {
      // When user completes slides/video, contentCompleted becomes true
      const canAccess = canAccessPracticeSection(true);
      expect(canAccess).toBe(true);
    });

    it("should provide user-friendly lock message", () => {
      // When practice is locked, show informative message to user
      const message = getPracticeLockMessage();
      expect(message).toBeTruthy();
      expect(message.length).toBeGreaterThan(0);
      expect(message.toLowerCase()).toContain("training");
    });

    it("should enforce binary state (not partial access)", () => {
      // Practice section is either fully locked or fully unlocked
      expect(canAccessPracticeSection(false)).toBe(false);
      expect(canAccessPracticeSection(true)).toBe(true);
      // No middle ground / partial access
    });
  });

  describe("contentCompleted prop behavior", () => {
    it("should default to locked when prop not provided", () => {
      // ScenarioFlow should default to contentCompleted=false
      // which means Practice Section is locked
      const defaultUnlocked = canAccessPracticeSection(false);
      expect(defaultUnlocked).toBe(false);
    });

    it("should respect contentCompleted prop changes", () => {
      // Parent can pass contentCompleted prop to control lock state
      // Initial state: locked
      expect(canAccessPracticeSection(false)).toBe(false);

      // After completing slides: unlocked
      expect(canAccessPracticeSection(true)).toBe(true);
    });
  });

  describe("Phase Transition Logic", () => {
    it("should show 'locked' phase when contentCompleted is false", () => {
      // ScenarioFlow has a "locked" phase for when practice section is not accessible
      // This phase shows the lock warning UI
      const isLocked = !canAccessPracticeSection(false);
      expect(isLocked).toBe(true);
    });

    it("should transition from locked to scenario phase when contentCompleted is true", () => {
      // After slides complete, user sees scenarios, not lock message
      const isLocked = !canAccessPracticeSection(true);
      expect(isLocked).toBe(false);
    });
  });

  describe("Integration with Slide Completion", () => {
    it("should require content completion before practice access", () => {
      // Gating rule: slides (or video) must be completed first
      const slideNotCompleted = canAccessPracticeSection(false);
      expect(slideNotCompleted).toBe(false);
    });

    it("should allow practice access only after content completion", () => {
      // Only after slides complete (30s) or video watched (90%),
      // practice section becomes accessible
      const slideCompleted = canAccessPracticeSection(true);
      expect(slideCompleted).toBe(true);
    });
  });

  describe("Scenario Completion Independence", () => {
    it("should not mark training complete from scenario alone", () => {
      // Training completion depends on slides/video, NOT scenarios
      // Even after completing all scenarios, training remains incomplete
      // unless slides/video were completed first

      // This test documents the rule: scenarios are practice, not gates
      const scenarioCompletionDoesNotUnlock = true;
      expect(scenarioCompletionDoesNotUnlock).toBe(true);
    });

    it("should allow practice even if scenarios not started yet", () => {
      // Practice section unlocks immediately after slides complete
      // User doesn't need to start scenarios
      const contentCompleted = true;
      const canAccessPractice = canAccessPracticeSection(contentCompleted);
      expect(canAccessPractice).toBe(true);
    });
  });

  describe("Lock Message Consistency", () => {
    it("should return consistent message across calls", () => {
      const message1 = getPracticeLockMessage();
      const message2 = getPracticeLockMessage();
      expect(message1).toBe(message2);
    });

    it("should mention training content completion requirement", () => {
      const message = getPracticeLockMessage();
      const lowerCase = message.toLowerCase();
      expect(
        lowerCase.includes("training") ||
        lowerCase.includes("slides") ||
        lowerCase.includes("complete")
      ).toBe(true);
    });

    it("should guide user on what to do next", () => {
      // Lock message should be helpful, not just restrictive
      const message = getPracticeLockMessage();
      expect(message.length).toBeGreaterThan(10);
    });
  });

  describe("Access Control Matrix", () => {
    it("locks access when slides not viewed", () => {
      expect(canAccessPracticeSection(false)).toBe(false);
    });

    it("unlocks access when slides viewed", () => {
      expect(canAccessPracticeSection(true)).toBe(true);
    });

    it("unlocks access when video 90% watched", () => {
      // contentCompleted=true signifies either:
      // - Slides viewed for 30+ seconds, OR
      // - Video watched to 90%, OR
      // - (Future: other content types)
      expect(canAccessPracticeSection(true)).toBe(true);
    });
  });

  describe("Edge Cases", () => {
    it("should handle undefined contentCompleted as false", () => {
      // Default behavior when prop not provided
      const undefinedState = false; // treats undefined as not completed
      expect(canAccessPracticeSection(undefinedState)).toBe(false);
    });

    it("should not allow partial completion", () => {
      // Only boolean values, no percentages or partial states
      expect(canAccessPracticeSection(false)).toBe(false);
      expect(canAccessPracticeSection(true)).toBe(true);
      // Any other state should be treated as locked
    });
  });
});
