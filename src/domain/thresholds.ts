// Centralized business-rule thresholds for the coaching platform.
//
// Why this file exists:
//   Thresholds (60/70/80/90/30s/3) appeared inline in JSX and hooks,
//   making them brittle and untestable. All numeric rules now live here
//   as named, exported constants. Tests pin every boundary
//   (just-below / exactly-at / just-above).
//
// Rule: NEVER hardcode one of these values inline. Import from here.
//
// Source-of-truth references:
//   - CLAUDE.md "Key Business Rules (Never Break)"
//   - docs/memory/patterns.md "Business Rules (never break)"

/** Baseline assessment: minimum % to pass (also persona D floor). */
export const BASELINE_PASS_PCT = 60;

/** Endline assessment: minimum % to pass and unlock certificate. */
export const ENDLINE_PASS_PCT = 70;

/** Module quiz: minimum % to pass a module. */
export const MODULE_QUIZ_PASS_PCT = 80;

/** Module quiz: maximum attempts before lockout. */
export const MODULE_QUIZ_MAX_ATTEMPTS = 3;

/** Content gate: minimum % of video that must be watched. */
export const VIDEO_GATE_PCT = 90;

/** Content gate: minimum seconds slides must be viewed. */
export const SLIDES_GATE_SECONDS = 30;

/** Anti-cheat: tab-switch count that triggers admin-review flag. */
export const TAB_SWITCH_FLAG_THRESHOLD = 3;

/** Persona thresholds (% inclusive lower bound). */
export const PERSONA_THRESHOLDS = {
  A: 75,
  B: 70,
  C: 65,
  D: 60,
} as const;
