// Module factory. Default = a non-common module for persona B at order 2.
// Module 1 is universal (is_common=true) — see docs/memory/patterns.md.

import type { Persona } from './profiles';

export interface FixtureModule {
  id: string;
  title: string;
  order_number: number;
  is_common: boolean;
  persona_required: Persona | null;
}

let counter = 1;

export function makeModule(overrides: Partial<FixtureModule> = {}): FixtureModule {
  counter += 1;
  return {
    id: `module-${counter}`,
    title: `Module ${counter}`,
    order_number: counter,
    is_common: false,
    persona_required: 'B',
    ...overrides,
  };
}

export function makeModule1(overrides: Partial<FixtureModule> = {}): FixtureModule {
  return {
    id: 'module-1',
    title: 'Module 1 (universal)',
    order_number: 1,
    is_common: true,
    persona_required: null,
    ...overrides,
  };
}
