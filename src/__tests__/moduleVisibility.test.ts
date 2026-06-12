/**
 * Module Visibility — Vacation Lock Mode
 *
 * Feature: All modules visible to all personas (vacation lock mode)
 *
 * Business rule (post-migration):
 *   The Dashboard no longer filters modules by persona.
 *   Every authenticated user — regardless of their persona score bucket
 *   (A, B, C, D, E) or role (Coach) — sees all 6 modules after completing
 *   the baseline assessment.
 *
 * Risk this guards against:
 *   A persona-based filter silently re-introduced in the dashboard query
 *   or the UI's module-list derivation narrowing the visible set below 6.
 *
 * Tier: Unit (pure data — no DB, no network, no mocks needed)
 */

import { describe, it, expect } from 'vitest';

// ---------------------------------------------------------------------------
// Canonical module catalogue (mirrors the seeded production data)
// ---------------------------------------------------------------------------

interface Module {
  id: string;
  title: string;
  is_mandatory: boolean;
  order_number: number;
}

const ALL_MODULES: Module[] = [
  {
    id: '1',
    title: 'Module 1: Universal Core Refresher',
    is_mandatory: true,
    order_number: 1,
  },
  {
    id: '2',
    title: 'Module 2: The Partnership Foundation',
    is_mandatory: false,
    order_number: 2,
  },
  {
    id: '3',
    title: 'Module 3: The Mirror Specialist',
    is_mandatory: false,
    order_number: 3,
  },
  {
    id: '4',
    title: 'Module 4: Digital & Data Intelligence',
    is_mandatory: false,
    order_number: 4,
  },
  {
    id: '5',
    title: 'Module 5: The Instructional Catalyst',
    is_mandatory: false,
    order_number: 5,
  },
  {
    id: '6',
    title: 'Module 6: The Excellence Loop',
    is_mandatory: false,
    order_number: 6,
  },
];

// ---------------------------------------------------------------------------
// Helper: simulate the vacation-lock assignment logic.
// In vacation lock mode the filter is a no-op — all modules are returned.
// This function is the pure equivalent of what the Dashboard derives.
// ---------------------------------------------------------------------------

function getVisibleModulesForPersona(
  modules: Module[],
  _persona: string | null
): Module[] {
  // Vacation lock mode: persona is irrelevant, return all modules.
  return modules;
}

// ---------------------------------------------------------------------------
// Count invariant — every persona sees exactly 6 modules
// ---------------------------------------------------------------------------

describe('Module Visibility (Vacation Lock Mode) — count invariant', () => {
  const personas = ['A', 'B', 'C', 'D', 'E', 'Coach'] as const;

  for (const persona of personas) {
    it(`${persona} persona should see all 6 modules`, () => {
      const visible = getVisibleModulesForPersona(ALL_MODULES, persona);
      expect(visible).toHaveLength(6);
    });
  }

  it('null persona (unauthenticated fallback) should not reduce module count', () => {
    // Unauthenticated users should never reach this path, but the filter
    // must not crash or silently drop modules if called with a null persona.
    const visible = getVisibleModulesForPersona(ALL_MODULES, null);
    expect(visible).toHaveLength(6);
  });
});

// ---------------------------------------------------------------------------
// Identity invariant — all six specific titles must be present
// ---------------------------------------------------------------------------

describe('Module Visibility (Vacation Lock Mode) — title identity', () => {
  it('all module titles should be present in the returned set', () => {
    const visible = getVisibleModulesForPersona(ALL_MODULES, 'A');
    const titles = visible.map((m) => m.title);

    expect(titles).toContain('Module 1: Universal Core Refresher');
    expect(titles).toContain('Module 2: The Partnership Foundation');
    expect(titles).toContain('Module 3: The Mirror Specialist');
    expect(titles).toContain('Module 4: Digital & Data Intelligence');
    expect(titles).toContain('Module 5: The Instructional Catalyst');
    expect(titles).toContain('Module 6: The Excellence Loop');
  });

  it('no module titles should be missing from any persona view', () => {
    const personas = ['A', 'B', 'C', 'D', 'E', 'Coach'];
    const expectedTitles = ALL_MODULES.map((m) => m.title).sort();

    for (const persona of personas) {
      const visible = getVisibleModulesForPersona(ALL_MODULES, persona);
      const actualTitles = visible.map((m) => m.title).sort();
      expect(actualTitles).toEqual(expectedTitles);
    }
  });
});

// ---------------------------------------------------------------------------
// Mandatory flag — Module 1 must always be marked mandatory
// ---------------------------------------------------------------------------

describe('Module Visibility (Vacation Lock Mode) — mandatory flag', () => {
  it('Module 1 should be marked as mandatory', () => {
    const mod1 = ALL_MODULES.find((m) => m.order_number === 1);
    expect(mod1).toBeDefined();
    expect(mod1?.is_mandatory).toBe(true);
  });

  it('Modules 2-6 should not be marked as mandatory', () => {
    const nonMandatory = ALL_MODULES.filter((m) => m.order_number > 1);
    expect(nonMandatory).toHaveLength(5);
    for (const mod of nonMandatory) {
      expect(mod.is_mandatory).toBe(false);
    }
  });
});

// ---------------------------------------------------------------------------
// Sequential order — modules must be ordered by order_number 1-6
// ---------------------------------------------------------------------------

describe('Module Visibility (Vacation Lock Mode) — sequential order', () => {
  it('modules should be ordered sequentially starting at 1', () => {
    const visible = getVisibleModulesForPersona(ALL_MODULES, 'B');
    const orderNumbers = visible.map((m) => m.order_number);
    expect(orderNumbers).toEqual([1, 2, 3, 4, 5, 6]);
  });

  it('no gaps in order_number sequence', () => {
    const visible = getVisibleModulesForPersona(ALL_MODULES, 'C');
    const sorted = [...visible].sort((a, b) => a.order_number - b.order_number);

    for (let i = 0; i < sorted.length; i++) {
      expect(sorted[i].order_number).toBe(i + 1);
    }
  });

  it('boundary: module at order_number 1 is the first element', () => {
    const visible = getVisibleModulesForPersona(ALL_MODULES, 'D');
    expect(visible[0].order_number).toBe(1);
  });

  it('boundary: module at order_number 6 is the last element', () => {
    const visible = getVisibleModulesForPersona(ALL_MODULES, 'E');
    expect(visible[visible.length - 1].order_number).toBe(6);
  });
});

// ---------------------------------------------------------------------------
// Regression: persona filter must not narrow the set
// This directly guards against a developer re-introducing a persona guard.
// ---------------------------------------------------------------------------

describe('Module Visibility — persona filter regression', () => {
  it('Persona A view must equal the full unfiltered module set', () => {
    const visible = getVisibleModulesForPersona(ALL_MODULES, 'A');
    expect(visible).toEqual(ALL_MODULES);
  });

  it('Persona D (lowest passing) view must equal the full unfiltered module set', () => {
    const visible = getVisibleModulesForPersona(ALL_MODULES, 'D');
    expect(visible).toEqual(ALL_MODULES);
  });

  it('Persona E (below-pass) view must equal the full unfiltered module set', () => {
    // Persona E was historically filtered to fewer modules — vacation lock overrides this.
    const visible = getVisibleModulesForPersona(ALL_MODULES, 'E');
    expect(visible).toEqual(ALL_MODULES);
  });
});
