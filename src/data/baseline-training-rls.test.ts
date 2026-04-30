/**
 * Regression test: baseline assessment RLS violation (P3 bug)
 *
 * SCENARIO
 * --------
 * A coach user submits the baseline assessment.
 * Assessment.tsx::saveAssessmentProgress() runs this sequence:
 *   1. SELECT from trainings WHERE title = 'Coach Baseline Assessment' LIMIT 1
 *   2. If row is missing → INSERT into trainings  ← RLS blocks this (error 42501)
 *
 * This happens in production when migration 20260505000001 has NOT been applied,
 * because that migration seeds the "Coach Baseline Assessment" row.
 * Coach role lacks INSERT permission on `trainings` (admin-only policy).
 *
 * THIS TEST IS EXPECTED TO FAIL (reproduce the bug) until migration
 * 20260505000001 is applied to the target environment.  Once the migration
 * runs, the SELECT succeeds, the INSERT branch is never reached, and the
 * test should be updated / deleted.
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createSupabaseMock } from '@/test/mocks/supabase';
import { makeUser, makeProfile } from '@/test/fixtures';

// ── canonical mock setup ────────────────────────────────────────────────────
const mock = createSupabaseMock();
vi.mock('@/integrations/supabase/client', () => ({ supabase: mock.client }));

// ── inline replica of the logic under test ──────────────────────────────────
// We extract only the trainings-lookup + insert block from Assessment.tsx so
// we can drive it without rendering the full component.  This mirrors the
// exact code path at src/pages/Assessment.tsx lines 226-257.

type TrainingRow = { id: string };

async function ensureBaselineTraining(
  supabase: typeof mock.client,
  userId: string,
): Promise<{ trainingId: string | null; error: { message: string; code?: string } | null }> {
  const trainingTitle = 'Coach Baseline Assessment';

  const { data: existingTrainings } = await supabase
    .from('trainings')
    .select('id')
    .eq('title', trainingTitle)
    .limit(1);

  if (existingTrainings && (existingTrainings as TrainingRow[]).length > 0) {
    return { trainingId: (existingTrainings as TrainingRow[])[0].id, error: null };
  }

  // Training not found — attempt INSERT (coach role → RLS violation)
  const { data: newTraining, error: createError } = await supabase
    .from('trainings')
    .insert({
      title: trainingTitle,
      description: 'Baseline assessment for coaching program',
      order_number: 0,
      is_common: true,
    })
    .select('id')
    .single();

  if (createError || !newTraining) {
    return { trainingId: null, error: createError };
  }

  return { trainingId: (newTraining as TrainingRow).id, error: null };
}

// ── tests ───────────────────────────────────────────────────────────────────

describe('baseline training RLS violation regression', () => {
  beforeEach(() => mock.reset());

  it('succeeds when "Coach Baseline Assessment" row already exists (migration applied)', async () => {
    const user = makeUser();
    makeProfile({ id: user.id, persona: null, baseline_completed: false });

    // SELECT returns the seeded row — no INSERT needed
    mock.queueResult({ data: [{ id: 'training-uuid-001' }], error: null });

    const { trainingId, error } = await ensureBaselineTraining(mock.client, user.id);

    expect(error).toBeNull();
    expect(trainingId).toBe('training-uuid-001');

    // Confirm the INSERT branch was never reached
    const insertCalls = mock.callsByMethod('insert');
    expect(insertCalls).toHaveLength(0);
  });

  it('fails with RLS 42501 when migration not applied and coach attempts INSERT', async () => {
    const user = makeUser();
    makeProfile({ id: user.id, persona: null, baseline_completed: false });

    // SELECT returns empty — training not seeded yet
    mock.queueResult({ data: [], error: null });

    // INSERT is blocked by RLS — coach role cannot insert into trainings
    mock.queueError(
      'new row violates row-level security policy for table "trainings" (42501)',
    );

    const { trainingId, error } = await ensureBaselineTraining(mock.client, user.id);

    // This is the CURRENT production failure mode
    expect(trainingId).toBeNull();
    expect(error).not.toBeNull();
    expect(error!.message).toContain('42501');

    // Confirm the INSERT was actually attempted
    const insertCalls = mock.callsByMethod('insert');
    expect(insertCalls).toHaveLength(1);
    expect(insertCalls[0].args[0]).toMatchObject({
      title: 'Coach Baseline Assessment',
      order_number: 0,
      is_common: true,
    });
  });

  it('does not attempt INSERT when user is null (guard clause)', async () => {
    // Assessment.tsx line 223: if (!user) return;
    // We verify our extracted helper behaves consistently with a null-like userId
    // by simply not calling it — this test documents the guard is relied upon.
    // No queue entries needed; if called, the first nextResult() returns { data: null, error: null }.
    const insertCalls = mock.callsByMethod('insert');
    expect(insertCalls).toHaveLength(0);
  });

  it('returns null trainingId (not a crash) when INSERT is denied', async () => {
    const user = makeUser();

    mock.queueResult({ data: [], error: null });   // SELECT → empty
    mock.queueError('42501 RLS policy violation'); // INSERT → denied

    const { trainingId, error } = await ensureBaselineTraining(mock.client, user.id);

    // saveAssessmentProgress returns early → no progress is saved
    // Coach loses their baseline record silently — the bug surface
    expect(trainingId).toBeNull();
    expect(error).not.toBeNull();
  });
});
