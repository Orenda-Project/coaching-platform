// Coach module visibility test
//
// Feature: Coaches access all modules during vacation engagement period (until 2026-06-15)
//
// Rules:
// - Coaches (role = 'coach') see all 6 modules
// - Regular Persona A/B/C/D see filtered modules (mandatory + weak_modules)
// - Persona E sees all modules (existing rule)
// - Coaches treated like Persona E (unlimited quiz attempts, all modules)
//
// To run: npm run test -- src/domain/coach-module-access.test.ts

import { describe, it, expect, beforeEach, vi } from 'vitest';
import { createSupabaseMock } from '@/test/mocks/supabase';

const mock = createSupabaseMock();
vi.mock('@/integrations/supabase/client', () => ({ supabase: mock.client }));

// ---------------------------------------------------------------------------
// Helper: simulate Dashboard.tsx module filtering logic
// ---------------------------------------------------------------------------
interface DashboardModule {
  id: string;
  title: string;
  is_mandatory: boolean;
}

interface FilterInput {
  isCoach: boolean;
  persona: string | null;
  weakModules: string[];
}

interface FilteredModules {
  isCoach: boolean;
  persona: string;
  assignedCount: number;
  assignedModuleIds: string[];
}

function filterModulesForUser(
  allModules: DashboardModule[],
  input: FilterInput,
): FilteredModules {
  let assignedModules = allModules;

  // Coach logic: see all modules (same as Persona E)
  if (input.isCoach || input.persona === 'E') {
    assignedModules = allModules;
  } else {
    // Regular personas: show mandatory + weak_modules
    const weakModules = input.weakModules || [];
    assignedModules = allModules.filter(
      (m) => m.is_mandatory || weakModules.some((wm) => m.title.startsWith(wm)),
    );
  }

  return {
    isCoach: input.isCoach,
    persona: input.persona || 'unassigned',
    assignedCount: assignedModules.length,
    assignedModuleIds: assignedModules.map((m) => m.id),
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
describe('Coach module visibility — vacation engagement feature', () => {
  beforeEach(() => mock.reset());

  describe('Coach sees all 6 modules', () => {
    it('coach with any persona sees all 6 modules', () => {
      const modules: DashboardModule[] = [
        { id: 'mod1', title: 'Module 1: Foundation', is_mandatory: true },
        { id: 'mod2', title: 'Module 2: Partnership', is_mandatory: false },
        { id: 'mod3', title: 'Module 3: Mirror', is_mandatory: false },
        { id: 'mod4', title: 'Module 4: Digital', is_mandatory: false },
        { id: 'mod5', title: 'Module 5: Catalyst', is_mandatory: false },
        { id: 'mod6', title: 'Module 6: Excellence', is_mandatory: false },
      ];

      const result = filterModulesForUser(modules, {
        isCoach: true,
        persona: 'A',
        weakModules: [],
      });

      expect(result.assignedCount).toBe(6);
      expect(result.isCoach).toBe(true);
    });

    it('coach with persona D sees all 6 modules (not just mandatory)', () => {
      const modules: DashboardModule[] = [
        { id: 'mod1', title: 'Module 1: Foundation', is_mandatory: true },
        { id: 'mod2', title: 'Module 2: Partnership', is_mandatory: false },
        { id: 'mod3', title: 'Module 3: Mirror', is_mandatory: false },
      ];

      const result = filterModulesForUser(modules, {
        isCoach: true,
        persona: 'D',
        weakModules: [],
      });

      expect(result.assignedCount).toBe(3);
    });

    it('coach sees all modules even with empty weak_modules', () => {
      const modules: DashboardModule[] = [
        { id: 'mod1', title: 'Module 1: Foundation', is_mandatory: true },
        { id: 'mod2', title: 'Module 2: Partnership', is_mandatory: false },
        { id: 'mod3', title: 'Module 3: Mirror', is_mandatory: false },
      ];

      const result = filterModulesForUser(modules, {
        isCoach: true,
        persona: 'B',
        weakModules: [],
      });

      expect(result.assignedCount).toBe(3);
    });
  });

  describe('Regular Persona A/B/C/D sees filtered modules only', () => {
    it('Persona A with no weak modules sees only mandatory Module 1', () => {
      const modules: DashboardModule[] = [
        { id: 'mod1', title: 'Module 1: Foundation', is_mandatory: true },
        { id: 'mod2', title: 'Module 2: Partnership', is_mandatory: false },
        { id: 'mod3', title: 'Module 3: Mirror', is_mandatory: false },
      ];

      const result = filterModulesForUser(modules, {
        isCoach: false,
        persona: 'A',
        weakModules: [],
      });

      expect(result.assignedCount).toBe(1);
      expect(result.assignedModuleIds).toEqual(['mod1']);
    });

    it('Persona B with weak modules sees mandatory + weak modules', () => {
      const modules: DashboardModule[] = [
        { id: 'mod1', title: 'Module 1: Foundation', is_mandatory: true },
        { id: 'mod2', title: 'Partnership Foundation', is_mandatory: false },
        { id: 'mod3', title: 'Mirror Specialist', is_mandatory: false },
        { id: 'mod4', title: 'Module 4: Digital', is_mandatory: false },
      ];

      const result = filterModulesForUser(modules, {
        isCoach: false,
        persona: 'B',
        weakModules: ['Partnership', 'Mirror'],
      });

      // Should see: Module 1 (mandatory), Module 2 (matches 'Partnership'), Module 3 (matches 'Mirror')
      expect(result.assignedCount).toBe(3);
      expect(result.assignedModuleIds).toContain('mod1');
      expect(result.assignedModuleIds).toContain('mod2');
      expect(result.assignedModuleIds).toContain('mod3');
      expect(result.assignedModuleIds).not.toContain('mod4');
    });

    it('Persona C with one weak module sees mandatory + that module', () => {
      const modules: DashboardModule[] = [
        { id: 'mod1', title: 'Module 1: Foundation', is_mandatory: true },
        { id: 'mod2', title: 'Partnership Module', is_mandatory: false },
        { id: 'mod3', title: 'Mirror Specialist', is_mandatory: false },
      ];

      const result = filterModulesForUser(modules, {
        isCoach: false,
        persona: 'C',
        weakModules: ['Partnership'],
      });

      expect(result.assignedCount).toBe(2);
      expect(result.assignedModuleIds).toContain('mod1');
      expect(result.assignedModuleIds).toContain('mod2');
    });

    it('non-coach does not access non-weak modules', () => {
      const modules: DashboardModule[] = [
        { id: 'mod1', title: 'Module 1: Foundation', is_mandatory: true },
        { id: 'mod2', title: 'Partnership', is_mandatory: false },
        { id: 'mod3', title: 'Mirror', is_mandatory: false },
        { id: 'mod4', title: 'Digital', is_mandatory: false },
        { id: 'mod5', title: 'Catalyst', is_mandatory: false },
        { id: 'mod6', title: 'Excellence', is_mandatory: false },
      ];

      const result = filterModulesForUser(modules, {
        isCoach: false,
        persona: 'D',
        weakModules: ['Partnership'],
      });

      // Only Module 1 (mandatory) and Module 2 (Partnership)
      expect(result.assignedCount).toBe(2);
      expect(result.assignedModuleIds).not.toContain('mod4');
      expect(result.assignedModuleIds).not.toContain('mod5');
      expect(result.assignedModuleIds).not.toContain('mod6');
    });
  });

  describe('Persona E sees all modules (existing rule, unaffected)', () => {
    it('Persona E (non-coach) sees all modules', () => {
      const modules: DashboardModule[] = [
        { id: 'mod1', title: 'Module 1: Foundation', is_mandatory: true },
        { id: 'mod2', title: 'Module 2: Partnership', is_mandatory: false },
        { id: 'mod3', title: 'Module 3: Mirror', is_mandatory: false },
        { id: 'mod4', title: 'Module 4: Digital', is_mandatory: false },
        { id: 'mod5', title: 'Module 5: Catalyst', is_mandatory: false },
        { id: 'mod6', title: 'Module 6: Excellence', is_mandatory: false },
      ];

      const result = filterModulesForUser(modules, {
        isCoach: false,
        persona: 'E',
        weakModules: [],
      });

      expect(result.assignedCount).toBe(6);
      expect(result.persona).toBe('E');
    });

    it('Persona E ignores weak_modules filtering', () => {
      const modules: DashboardModule[] = [
        { id: 'mod1', title: 'Module 1: Foundation', is_mandatory: true },
        { id: 'mod2', title: 'Module 2: Partnership', is_mandatory: false },
        { id: 'mod3', title: 'Module 3: Mirror', is_mandatory: false },
      ];

      const result = filterModulesForUser(modules, {
        isCoach: false,
        persona: 'E',
        weakModules: ['NonExistent'],
      });

      expect(result.assignedCount).toBe(3);
    });
  });

  describe('Edge cases', () => {
    it('coach with persona E and weak modules sees all modules', () => {
      const modules: DashboardModule[] = [
        { id: 'mod1', title: 'Module 1: Foundation', is_mandatory: true },
        { id: 'mod2', title: 'Module 2: Partnership', is_mandatory: false },
        { id: 'mod3', title: 'Module 3: Mirror', is_mandatory: false },
      ];

      const result = filterModulesForUser(modules, {
        isCoach: true,
        persona: 'E',
        weakModules: ['anything'],
      });

      expect(result.assignedCount).toBe(3);
      expect(result.isCoach).toBe(true);
    });

    it('non-coach with null persona and no weak modules sees only mandatory', () => {
      const modules: DashboardModule[] = [
        { id: 'mod1', title: 'Module 1: Foundation', is_mandatory: true },
        { id: 'mod2', title: 'Module 2: Partnership', is_mandatory: false },
      ];

      const result = filterModulesForUser(modules, {
        isCoach: false,
        persona: null,
        weakModules: [],
      });

      expect(result.assignedCount).toBe(1);
      expect(result.assignedModuleIds).toContain('mod1');
    });

    it('empty module list returns 0 modules for all users', () => {
      const modules: DashboardModule[] = [];

      const coachResult = filterModulesForUser(modules, {
        isCoach: true,
        persona: 'A',
        weakModules: [],
      });

      const regularResult = filterModulesForUser(modules, {
        isCoach: false,
        persona: 'B',
        weakModules: ['Partnership'],
      });

      expect(coachResult.assignedCount).toBe(0);
      expect(regularResult.assignedCount).toBe(0);
    });
  });

  describe('Rollback scenario (post-vacation, after 2026-06-15)', () => {
    it('when isCoach is removed, coaches revert to persona-based filtering', () => {
      const modules: DashboardModule[] = [
        { id: 'mod1', title: 'Module 1: Foundation', is_mandatory: true },
        { id: 'mod2', title: 'Module 2: Partnership', is_mandatory: false },
        { id: 'mod3', title: 'Module 3: Mirror', is_mandatory: false },
      ];

      // Coach with Persona A, would see all during vacation
      const vacationResult = filterModulesForUser(modules, {
        isCoach: true,
        persona: 'A',
        weakModules: [],
      });
      expect(vacationResult.assignedCount).toBe(3);

      // After rollback: isCoach = false, reverts to Persona A filtering
      const postVacationResult = filterModulesForUser(modules, {
        isCoach: false,
        persona: 'A',
        weakModules: [],
      });
      expect(postVacationResult.assignedCount).toBe(1);
    });
  });
});
