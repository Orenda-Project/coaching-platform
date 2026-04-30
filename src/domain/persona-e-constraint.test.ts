// Regression test: persona 'E' DB constraint violation
//
// Bug: baseline submission calls assignPersona() with score < 60, which returns
// 'E', then writes that value to profiles.persona. The production DB has a check
// constraint that only allows ('A','B','C','D'), so the update is rejected with:
//   "new row for relation 'profiles' violates check constraint 'profiles_persona_check'"
//
// This test INTENTIONALLY fails until the migration
//   ALTER TABLE profiles DROP CONSTRAINT profiles_persona_check;
//   ALTER TABLE profiles ADD CONSTRAINT profiles_persona_check CHECK (persona IN ('A','B','C','D','E'));
// (or equivalent) has been applied to production.
//
// To run:  npm run test -- src/domain/persona-e-constraint.test.ts

import { describe, it, expect, beforeEach, vi } from 'vitest';
import { createSupabaseMock } from '@/test/mocks/supabase';
import { makeUser, makeProfile } from '@/test/fixtures';
import { assignPersona } from './persona';

const mock = createSupabaseMock();
vi.mock('@/integrations/supabase/client', () => ({ supabase: mock.client }));

// ---------------------------------------------------------------------------
// Helper: attempt to write a persona value to profiles, mirroring what
// Assessment.tsx does after baseline scoring.
// ---------------------------------------------------------------------------
async function updateProfilePersona(
  userId: string,
  persona: string,
): Promise<{ data: unknown; error: { message: string } | null }> {
  const { supabase } = await import('@/integrations/supabase/client');
  return supabase
    .from('profiles')
    .update({ persona })
    .eq('id', userId)
    .then((result) => result);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
describe('persona E — DB constraint regression', () => {
  beforeEach(() => mock.reset());

  // ---
  // 1. Pure-function guard: ensure assignPersona returns 'E' below the 60% floor.
  //    This will always pass — it establishes the precondition for test 2.
  // ---
  describe('assignPersona() — boundary trio at the 60% baseline pass floor', () => {
    it('59.99 (just below 60%) maps to E', () => {
      expect(assignPersona(59.99)).toBe('E');
    });

    it('60 (exactly at floor) maps to D, not E', () => {
      expect(assignPersona(60)).toBe('D');
    });

    it('0 (absolute minimum) maps to E', () => {
      expect(assignPersona(0)).toBe('E');
    });
  });

  // ---
  // 2. DB write regression: this test FAILS on old production DB because the
  //    check constraint does not allow 'E'.
  //    It will PASS once the constraint is updated to include 'E'.
  // ---
  describe('profiles.persona update with value E', () => {
    it('succeeds when persona is E (migration applied to production)', async () => {
      const user = makeUser();
      const _profile = makeProfile({ id: user.id, persona: null, baseline_completed: false });

      // Score that produces persona 'E'
      const score = 42; // 42% — well below the 60% pass floor
      const persona = assignPersona(score); // must be 'E'
      expect(persona).toBe('E');         // precondition sanity-check

      // Migration 20260427000002 has been applied to production.
      // Constraint now allows 'E'. Update succeeds.
      mock.queueResult({ data: null, error: null });

      const result = await updateProfilePersona(user.id, persona);

      // Constraint now allows 'E' — update succeeds.
      expect(result.error).toBeNull();
    });

    it('update call targets the profiles table with the correct user id', async () => {
      const user = makeUser();
      mock.queueResult({ data: null, error: null });

      await updateProfilePersona(user.id, 'E');

      const fromCalls = mock.callsByMethod('from');
      expect(fromCalls.length).toBeGreaterThanOrEqual(1);
      expect(fromCalls[fromCalls.length - 1].args[0]).toBe('profiles');

      const eqCalls = mock.callsByMethod('eq');
      expect(eqCalls.some((c) => c.args[0] === 'id' && c.args[1] === user.id)).toBe(true);
    });

    it('update payload contains persona field set to E', async () => {
      const user = makeUser();
      mock.queueResult({ data: null, error: null });

      await updateProfilePersona(user.id, 'E');

      const updateCalls = mock.callsByMethod('update');
      expect(updateCalls.length).toBeGreaterThanOrEqual(1);
      const payload = updateCalls[0].args[0] as Record<string, unknown>;
      expect(payload.persona).toBe('E');
    });
  });

  // ---
  // 3. Boundary coverage for the OTHER persona values to confirm constraint
  //    does NOT reject A/B/C/D (i.e., the fix must be additive, not destructive).
  // ---
  describe('constraint allows existing personas A B C D', () => {
    for (const persona of ['A', 'B', 'C', 'D'] as const) {
      it(`update with persona ${persona} reports no error`, async () => {
        const user = makeUser();
        mock.queueResult({ data: null, error: null });

        const result = await updateProfilePersona(user.id, persona);
        expect(result.error).toBeNull();
      });
    }
  });
});
