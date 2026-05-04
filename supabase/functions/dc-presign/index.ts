import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { S3Client, PutObjectCommand, GetObjectCommand } from 'npm:@aws-sdk/client-s3';
import { getSignedUrl } from 'npm:@aws-sdk/s3-request-presigner';
import { corsHeaders } from '../_shared/cors.ts';

function makeS3Client(region: string, accessKeyId: string, secretAccessKey: string) {
  return new S3Client({
    region,
    credentials: { accessKeyId, secretAccessKey },
  });
}

async function presignPut(client: S3Client, bucket: string, key: string, mimeType: string): Promise<string> {
  return getSignedUrl(
    client,
    new PutObjectCommand({ Bucket: bucket, Key: key, ContentType: mimeType }),
    { expiresIn: 1800 }, // 30 min
  );
}

async function presignGet(client: S3Client, bucket: string, key: string): Promise<string> {
  return getSignedUrl(
    client,
    new GetObjectCommand({ Bucket: bucket, Key: key }),
    { expiresIn: 7200 }, // 2 hours — long enough for DC to fetch
  );
}

// ── Handler ───────────────────────────────────────────────────────────────────

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

    const { observation_id, mime_type } = await req.json();
    if (!observation_id) {
      return new Response(JSON.stringify({ error: 'observation_id required' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Verify observation belongs to this user
    const { data: obs, error: obsErr } = await supabase
      .from('cot_observations')
      .select('id, observer_id')
      .eq('id', observation_id)
      .eq('observer_id', user.id)
      .single();

    if (obsErr || !obs) {
      return new Response(JSON.stringify({ error: 'Observation not found' }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const bucket = Deno.env.get('S3_BUCKET_NAME')!;
    const region = Deno.env.get('AWS_REGION')!;
    const accessKeyId = Deno.env.get('AWS_ACCESS_KEY_ID')!;
    const secretAccessKey = Deno.env.get('AWS_SECRET_ACCESS_KEY')!;

    const ext = mime_type === 'audio/mp4' ? 'm4a' : 'webm';
    const mimeType = mime_type === 'audio/mp4' ? 'audio/mp4' : 'audio/webm';
    const s3Key = `dc-audio/${observation_id}/${Date.now()}.${ext}`;

    const s3 = makeS3Client(region, accessKeyId, secretAccessKey);
    const presignedPutUrl = await presignPut(s3, bucket, s3Key, mimeType);
    const presignedGetUrl = await presignGet(s3, bucket, s3Key);

    return new Response(
      JSON.stringify({ presigned_put_url: presignedPutUrl, presigned_get_url: presignedGetUrl, s3_key: s3Key }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    console.error('dc-presign error:', err);
    return new Response(JSON.stringify({ error: 'Internal error' }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
