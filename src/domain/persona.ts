// Persona assignment from a baseline percentage.
//
// Extracted from src/pages/Assessment.tsx (was inline at line 33).
// Pure function — no I/O, no side effects, fully unit-testable.
//
// Persona contract (CLAUDE.md "Key Business Rules"):
//   A ≥ 75
//   B ≥ 70  (and < 75)
//   C ≥ 65  (and < 70)
//   D ≥ 60  (and < 65)
//   E < 60   (entry-level — sees all modules)

import { PERSONA_THRESHOLDS } from './thresholds';

export type Persona = 'A' | 'B' | 'C' | 'D' | 'E';

export function assignPersona(pct: number): Persona {
  if (pct >= PERSONA_THRESHOLDS.A) return 'A';
  if (pct >= PERSONA_THRESHOLDS.B) return 'B';
  if (pct >= PERSONA_THRESHOLDS.C) return 'C';
  if (pct >= PERSONA_THRESHOLDS.D) return 'D';
  return 'E';
}
