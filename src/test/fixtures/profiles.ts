// Profile factory. Default = persona 'B' (median real user) with a passing baseline.
// Boundary cases (E, A, missing baseline, etc.) are explicit overrides.

export type Persona = 'A' | 'B' | 'C' | 'D' | 'E';

export interface FixtureProfile {
  id: string;
  full_name: string | null;
  persona: Persona | null;
  baseline_completed: boolean;
  baseline_score: number | null;
}

export function makeProfile(overrides: Partial<FixtureProfile> = {}): FixtureProfile {
  return {
    id: 'user-1',
    full_name: 'Test Coach',
    persona: 'B',
    baseline_completed: true,
    baseline_score: 72,
    ...overrides,
  };
}
