import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

// ── DC → FICO mapping helpers ─────────────────────────────────────────────────

function mapDcScore(s: string): string | undefined {
  if (s === 'yes' || s === 'partial' || s === 'no') return s;
  if (s === 'N/A') return 'na';
  return undefined; // UNABLE_TO_DETECT → omit (shown as unscored)
}

function mapDcResultsToFicoRubric(results: any): object {
  const mapSection = (section: any): Record<string, string> => {
    if (!section?.scores) return {};
    const out: Record<string, string> = {};
    for (const [code, val] of Object.entries(section.scores)) {
      const mapped = mapDcScore(val as string);
      if (mapped !== undefined) out[code] = mapped;
    }
    return out;
  };
  return {
    section_b: mapSection(results?.section_b),
    section_c: mapSection(results?.section_c),
    section_d: mapSection(results?.section_d),
    // Section E (student observations) stays blank — coach fills manually
    section_e: [
      { q1: null, q2: null, q3: null },
      { q1: null, q2: null, q3: null },
      { q1: null, q2: null, q3: null },
      { q1: null, q2: null, q3: null },
      { q1: null, q2: null, q3: null },
    ],
  };
}

function scoreFromRubric(ficoRubric: any): { score: number; level: string } {
  // Score is based on Section B + Section C only (Section D = evidence markers, not scored)
  const vals = [
    ...Object.values(ficoRubric?.section_b ?? {}),
    ...Object.values(ficoRubric?.section_c ?? {}),
  ].filter((v) => v !== 'na') as string[];
  const max = vals.length;
  if (max === 0) return { score: 0, level: '' };
  const earned = vals.reduce(
    (s, v) => s + (v === 'yes' ? 1 : v === 'partial' ? 0.5 : 0),
    0,
  );
  const pct = Math.round((earned / max) * 100);
  const level =
    pct >= 85 ? 'Advanced' :
    pct >= 70 ? 'Proficient' :
    pct >= 50 ? 'Basic' : 'Below Basic';
  return { score: pct, level };
}

function buildDebriefNotes(results: any): string {
  const parts: string[] = [];
  const labels: Record<string, string> = {
    section_b: 'Section B — Structural & Pedagogical',
    section_c: 'Section C — Subject Specific',
    section_d: 'Section D — Student Engagement',
  };
  for (const key of ['section_b', 'section_c', 'section_d']) {
    const fb = results?.[key]?.feedback?.english;
    if (fb) parts.push(`[${labels[key]}]\n${fb}`);
  }
  return parts.join('\n\n');
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  // DC sends no auth — this endpoint is public
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const { task_id, status, progress, current_step, message, error, results } = body;

    if (!task_id || !status) {
      return new Response(JSON.stringify({ error: 'task_id and status required' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // Find the analysis row by DC's task_id
    const { data: analysis, error: findErr } = await adminClient
      .from('dc_analyses')
      .select('id, observation_id')
      .eq('task_id', task_id)
      .single();

    if (findErr || !analysis) {
      // DC may send callbacks before our row is inserted (rare) — return 200 to avoid retries
      console.warn('dc-callback: task not found:', task_id);
      return new Response(JSON.stringify({ received: true }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Update dc_analyses with latest state
    await adminClient.from('dc_analyses').update({
      status,
      progress: progress ?? null,
      current_step: current_step ?? null,
      message: message ?? null,
      error: error ?? null,
      results: results ?? null,
      updated_at: new Date().toISOString(),
    }).eq('task_id', task_id);

    // Mirror terminal states onto cot_observations
    if (status === 'completed') {
      const ficoRubric = mapDcResultsToFicoRubric(results);
      const { score, level } = scoreFromRubric(ficoRubric);
      const debriefNotes = buildDebriefNotes(results);

      await adminClient.from('cot_observations').update({
        dc_status: 'completed',
        dc_results: results ?? null,
        dc_completed_at: new Date().toISOString(),
        fico_rubric: ficoRubric,
        total_score: score,
        proficiency_level: level || null,
        hots_notes: debriefNotes || null,
        updated_at: new Date().toISOString(),
      }).eq('id', analysis.observation_id);
    } else if (status === 'failed') {
      await adminClient.from('cot_observations').update({
        dc_status: 'failed',
        dc_error: error ?? 'Analysis failed',
        updated_at: new Date().toISOString(),
      }).eq('id', analysis.observation_id);
    }

    // Always return 200 — DC retries on non-200
    return new Response(JSON.stringify({ received: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    console.error('dc-callback error:', err);
    // Still return 200 to stop DC retrying on our internal errors
    return new Response(JSON.stringify({ received: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
