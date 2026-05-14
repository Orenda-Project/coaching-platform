import { describe, it, expect } from "vitest";
import { shuffle } from "../shuffle";

describe("shuffle utility - Fisher-Yates algorithm", () => {
  it("should not mutate the input array", () => {
    const original = [
      { id: "a", label: "A" },
      { id: "b", label: "B" },
      { id: "c", label: "C" },
    ];
    const originalCopy = JSON.parse(JSON.stringify(original));
    const result = shuffle(original);

    expect(original).toEqual(originalCopy);
    expect(result).not.toBe(original); // Different reference
  });

  it("should preserve all input elements in output", () => {
    const input = [1, 2, 3, 4, 5];
    const result = shuffle(input);

    expect(result.sort((a, b) => a - b)).toEqual(input.sort((a, b) => a - b));
  });

  it("should preserve output length equal to input length", () => {
    const input = ["a", "b", "c", "d", "e"];
    const result = shuffle(input);

    expect(result.length).toBe(input.length);
  });

  it("should handle single-element array", () => {
    const input = ["only"];
    const result = shuffle(input);

    expect(result).toEqual(input);
    expect(result).not.toBe(input); // Different reference
  });

  it("should handle empty array", () => {
    const input: never[] = [];
    const result = shuffle(input);

    expect(result).toEqual([]);
  });

  it("should produce different orderings across multiple calls", () => {
    const input = [1, 2, 3, 4, 5, 6, 7, 8];
    const results: number[][] = [];

    for (let i = 0; i < 10; i++) {
      results.push(shuffle(input));
    }

    // At least some orderings should be different
    const uniqueOrderings = new Set(results.map((r) => r.join(",")));
    expect(uniqueOrderings.size).toBeGreaterThan(1);
  });
});
