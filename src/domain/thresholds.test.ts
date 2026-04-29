// Pin the threshold values themselves. If a refactor accidentally changes
// a constant, this test fails before any feature test even runs — making
// the regression cause obvious.
//
// Per CLAUDE.md "Key Business Rules (Never Break)":
//   Baseline 60%, Endline 70%, Module quiz 80% (max 3 attempts),
//   Video 90%, Slides 30s, Anti-cheat 3+ tab switches.

import { describe, it, expect } from 'vitest';
import {
  BASELINE_PASS_PCT,
  ENDLINE_PASS_PCT,
  MODULE_QUIZ_PASS_PCT,
  MODULE_QUIZ_MAX_ATTEMPTS,
  VIDEO_GATE_PCT,
  SLIDES_GATE_SECONDS,
  TAB_SWITCH_FLAG_THRESHOLD,
  PERSONA_THRESHOLDS,
} from './thresholds';

describe('business-rule thresholds (DO NOT change without a product decision)', () => {
  it('baseline pass = 60', () => expect(BASELINE_PASS_PCT).toBe(60));
  it('endline pass = 70', () => expect(ENDLINE_PASS_PCT).toBe(70));
  it('module quiz pass = 80', () => expect(MODULE_QUIZ_PASS_PCT).toBe(80));
  it('module quiz max attempts = 3', () => expect(MODULE_QUIZ_MAX_ATTEMPTS).toBe(3));
  it('video gate = 90%', () => expect(VIDEO_GATE_PCT).toBe(90));
  it('slides gate = 30s', () => expect(SLIDES_GATE_SECONDS).toBe(30));
  it('tab-switch flag threshold = 3', () => expect(TAB_SWITCH_FLAG_THRESHOLD).toBe(3));

  it('persona thresholds match CLAUDE.md', () => {
    expect(PERSONA_THRESHOLDS).toEqual({ A: 75, B: 70, C: 65, D: 60 });
  });

  it('persona thresholds are strictly decreasing (A > B > C > D)', () => {
    expect(PERSONA_THRESHOLDS.A).toBeGreaterThan(PERSONA_THRESHOLDS.B);
    expect(PERSONA_THRESHOLDS.B).toBeGreaterThan(PERSONA_THRESHOLDS.C);
    expect(PERSONA_THRESHOLDS.C).toBeGreaterThan(PERSONA_THRESHOLDS.D);
  });

  it('persona D floor equals baseline pass floor (invariant)', () => {
    expect(PERSONA_THRESHOLDS.D).toBe(BASELINE_PASS_PCT);
  });
});
