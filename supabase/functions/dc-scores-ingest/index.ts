import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const {
      observer_id,
      teacher_name,
      school_name,
      region,
      subject,
      grade,
      framework,
      total_score,
      proficiency_level,
      scored_at,
      results,
    } = body;

    if (!observer_id || !teacher_name || !school_name || !region || total_score == null || !scored_at) {
      return new Response(
        JSON.stringify({ error: 'observer_id, teacher_name, school_name, region, total_score, scored_at are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    const { error } = await adminClient
      .from('teacher_dc_scores')
      .upsert({
        observer_id,
        teacher_name,
        school_name,
        region,
        subject: subject ?? null,
        grade: grade ?? null,
        framework: framework ?? 'FICO',
        total_score,
        proficiency_level: proficiency_level ?? null,
        scored_at,
        raw_results: results ?? null,
      }, {
        onConflict: 'observer_id,teacher_name,school_name,scored_at',
      });

    if (error) {
      console.error('dc-scores-ingest db error:', error);
      return new Response(JSON.stringify({ error: 'Database error' }), {
        status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    console.error('dc-scores-ingest error:', err);
    return new Response(JSON.stringify({ error: 'Internal error' }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
