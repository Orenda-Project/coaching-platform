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
/* //test */

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

// ─── Punjab Cluster Coordinator thresholds ───────────────────────────────────

/** Punjab teacher score: at/above = on track (green tier). */
export const PUNJAB_ON_TRACK_PCT = 75;

/** Punjab teacher score: below = critical (red tier); between critical and on-track = watch (amber). */
export const PUNJAB_CRITICAL_PCT = 60;

/** Punjab CC coaching: weekly visit target. */
export const PUNJAB_WEEKLY_VISIT_TARGET = 3;

/** Punjab stagnation flag: minimum observation count before flagging stagnation. */
export const PUNJAB_STAGNATION_OBS_MIN = 2;

/** Punjab escalation flag: minimum observation count before RO escalation. */
export const PUNJAB_ESCALATION_OBS_MIN = 3;

// ─── Rawalpindi (Pindi) Cluster Coordinator thresholds ───────────────────────

/** Pindi teacher score: at/above = on track (green tier). */
export const PINDI_ON_TRACK_PCT = 75;

/** Pindi teacher score: below = critical (red tier); between critical and on-track = watch (amber). */
export const PINDI_CRITICAL_PCT = 60;

/** Pindi CC coaching: weekly visit target. */
export const PINDI_WEEKLY_VISIT_TARGET = 3;

/** Pindi stagnation flag: minimum observation count before flagging stagnation. */
export const PINDI_STAGNATION_OBS_MIN = 2;

/** Pindi escalation flag: minimum observation count before RO escalation. */
export const PINDI_ESCALATION_OBS_MIN = 3;
