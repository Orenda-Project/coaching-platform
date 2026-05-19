import { describe, it, expect } from "vitest";
import {
  canAccessPracticeSection,
  getPracticeLockMessage,
  isTrainingComplete,
  getActivePhase,
} from "../trainingRules";

describe("Training Domain Rules", () => {
  describe("canAccessPracticeSection", () => {
    it("should return false when slides are not completed", () => {
      expect(canAccessPracticeSection(false)).toBe(false);
    });

    it("should return true when slides are completed", () => {
      expect(canAccessPracticeSection(true)).toBe(true);
    });
//test
    it("should enforce binary state (not percentage or partial completion)", () => {
      expect(canAccessPracticeSection(false)).toBe(false);
      expect(canAccessPracticeSection(true)).toBe(true);
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

  describe("isTrainingComplete", () => {
    it("should return false when slides are not completed", () => {
      expect(isTrainingComplete(false, false, true)).toBe(false);
      expect(isTrainingComplete(false, true, true)).toBe(false);
      expect(isTrainingComplete(false, false, false)).toBe(false);
    });

    it("should return false when slides done but scenario not done (has scenario)", () => {
      expect(isTrainingComplete(true, false, true)).toBe(false);
    });

    it("should return true when both slides and scenario are done", () => {
      expect(isTrainingComplete(true, true, true)).toBe(true);
    });

    it("should return true when slides done and no scenario exists", () => {
      expect(isTrainingComplete(true, false, false)).toBe(true);
    });

    it("should return true when slides done, no scenario, scenarioCompleted irrelevant", () => {
      expect(isTrainingComplete(true, true, false)).toBe(true);
    });
  });

  describe("getActivePhase", () => {
    it("should return 'slides' when slides are not completed", () => {
      expect(getActivePhase(false, true)).toBe("slides");
      expect(getActivePhase(false, false)).toBe("slides");
    });

    it("should return 'scenario' when slides done and scenario exists", () => {
      expect(getActivePhase(true, true)).toBe("scenario");
    });

    it("should return 'slides' when slides done but no scenario exists", () => {
      expect(getActivePhase(true, false)).toBe("slides");
    });
  });
});
