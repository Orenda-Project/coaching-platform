import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

function subjectToShortcode(subject: string): string {
  const s = subject.toLowerCase();
  if (s.includes('math') || s.includes('numeracy')) return 'Math';
  if (s.includes('english') || s.includes('literacy') || s.includes('reading')) return 'Eng';
  if (s.includes('urdu')) return 'Urdu';
  if (s.includes('science')) return 'Sci';
  if (s.includes('social') || s.includes('studies')) return 'SST';
  return subject.substring(0, 4);
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // Verify user JWT
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: { user }, error: authErr } = await supabase.auth.getUser();
    if (authErr || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { observation_id, s3_key, presigned_get_url, lesson_plan_text } = await req.json();
    if (!observation_id || !s3_key || !presigned_get_url) {
      return new Response(JSON.stringify({ error: 'observation_id, s3_key, presigned_get_url required' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Get observation (verify ownership + get metadata)
    const { data: obs, error: obsErr } = await supabase
      .from('cot_observations')
      .select('id, observer_id, subject, teacher_name, topic')
      .eq('id', observation_id)
      .eq('observer_id', user.id)
      .single();

    if (obsErr || !obs) {
      return new Response(JSON.stringify({ error: 'Observation not found' }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const dcBaseUrl = Deno.env.get('DC_BASE_URL')!;
    const functionsUrl = Deno.env.get('SUPABASE_FUNCTIONS_URL')!;
    const callbackUrl = `${functionsUrl}/dc-callback`;

    // Build form data for DC API
    const formData = new FormData();
    formData.append('audio_s3_url', presigned_get_url);
    formData.append('lesson_plan_text', lesson_plan_text || obs.topic || '');
    formData.append('test_name', `obs-${observation_id}`);
    formData.append('rubric_type', 'fico-v3');
    formData.append('region', 'ict');
    formData.append('teacher_id', obs.teacher_name);
    formData.append('callback_url', callbackUrl);
    formData.append('subject_shortcode', subjectToShortcode(obs.subject));
    formData.append('subject_label', obs.subject);

    // Call DC API
    const dcResp = await fetch(`${dcBaseUrl}/api/external/process-audio-from-s3`, {
      method: 'POST',
      body: formData,
      signal: AbortSignal.timeout(30_000),
    });

    if (!dcResp.ok) {
      const errText = await dcResp.text();
      console.error('DC API error:', dcResp.status, errText);
      return new Response(JSON.stringify({ error: `DC service returned ${dcResp.status}` }), {
        status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const dcData = await dcResp.json();
    const dcTaskId: string = dcData.task_id ?? crypto.randomUUID();

    // Use service role for DB writes
    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // Insert dc_analyses row with DC's task_id
    await adminClient.from('dc_analyses').insert({
      observation_id,
      task_id: dcTaskId,
      status: 'processing',
      progress: 0,
    });

    // Update cot_observations
    await adminClient.from('cot_observations').update({
      dc_task_id: dcTaskId,
      dc_status: 'processing',
      dc_audio_s3_key: s3_key,
      dc_requested_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    }).eq('id', observation_id);

    return new Response(
      JSON.stringify({ ok: true, dc_task_id: dcTaskId }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    console.error('dc-start error:', err);
    return new Response(JSON.stringify({ error: 'Internal error' }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
