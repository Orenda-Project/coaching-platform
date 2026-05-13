import { describe, it, expect } from "vitest";
import {
  canAccessPracticeSection,
  getPracticeLockMessage,
} from "../trainingRules";

describe("Training Domain Rules - Phase 2: Practice Section Locking (COACH-XXXX)", () => {
  describe("canAccessPracticeSection", () => {
    it("should return false when content is not completed", () => {
      const result = canAccessPracticeSection(false);
      expect(result).toBe(false);
    });

    it("should return true when content is completed", () => {
      const result = canAccessPracticeSection(true);
      expect(result).toBe(true);
    });

    it("should enforce binary state (not percentage or partial completion)", () => {
      // Practice section is locked/unlocked, not partially accessible
      expect(canAccessPracticeSection(false)).toBe(false);
      expect(canAccessPracticeSection(true)).toBe(true);
      // No middle ground
    });
  });

  describe("getPracticeLockMessage", () => {
    it("should return a user-friendly message", () => {
      const message = getPracticeLockMessage();
      expect(message).toBeTruthy();
      expect(message).toContain("training slides");
      expect(message).toContain("practice");
    });

    it("should provide consistent message across calls", () => {
      const message1 = getPracticeLockMessage();
      const message2 = getPracticeLockMessage();
      expect(message1).toBe(message2);
    });
  });
});
