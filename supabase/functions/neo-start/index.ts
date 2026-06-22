import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, content-type",
};

function getRegionKey(region: string): string {
  if (!region) return Deno.env.get("NEO_API_KEY_ICT") || "";
  const lower = region.toLowerCase();
  if (lower.includes("punjab")) return Deno.env.get("NEO_API_KEY_PUNJAB") || "";
  if (lower.includes("pindi") || lower.includes("rawalpindi"))
    return Deno.env.get("NEO_API_KEY_PINDI") || "";
  return Deno.env.get("NEO_API_KEY_ICT") || "";
}

function getRegionName(region: string): string {
  if (!region) return "ICT";
  const lower = region.toLowerCase();
  if (lower.includes("punjab")) return "PUNJAB";
  if (lower.includes("pindi") || lower.includes("rawalpindi")) return "PINDI";
  return "ICT";
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") || "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || ""
    );

    // Get JWT to verify user
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Verify JWT and get user
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(authHeader.replace("Bearer ", ""));

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Parse FormData from request
    const formData = await req.formData();
    const audioFile = formData.get("file") as File | null;
    const observationId = formData.get("observation_id") as string | null;
    const regionFromClient = formData.get("region") as string | null;

    console.log("neo-start received:", {
      userId: user.id,
      observationId,
      regionFromClient,
      fileSize: audioFile?.size,
      fileName: audioFile?.name,
    });

    if (!audioFile || !observationId) {
      console.error("Missing required fields:", {
        hasFile: !!audioFile,
        hasObsId: !!observationId,
      });
      return new Response(
        JSON.stringify({
          error: "Missing file or observation_id",
          details: { hasFile: !!audioFile, hasObsId: !!observationId }
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Try to verify observation in Supabase — observations created via Railway Postgres
    // won't be found here, so fall back to the region provided by the client.
    const { data: obs, error: obsError } = await supabase
      .from("cot_observations")
      .select("id,region")
      .eq("id", observationId)
      .eq("observer_id", user.id)
      .single();

    if (obsError || !obs) {
      console.warn("Observation not in Supabase (Railway-only observation), falling back to client-provided region:", {
        observationId,
        userId: user.id,
        regionFromClient,
        obsError: obsError?.message,
      });
      // Only block the request if we have no region to work with
      if (!regionFromClient) {
        return new Response(
          JSON.stringify({
            error: "Observation not found and no region provided",
            errorCode: "OBS_NOT_FOUND",
          }),
          {
            status: 404,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }
    }

    const region = (obs?.region || regionFromClient || "ICT");
    const regionName = getRegionName(region);
    const apiKey = getRegionKey(region);

    console.log("Region lookup:", {
      region,
      regionName,
      hasApiKey: !!apiKey,
    });

    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: `Neo API key not configured for region ${regionName}` }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const neoBaseUrl = Deno.env.get("NEO_BASE_URL") || "";

    console.log("Neo upload starting:", {
      neoBaseUrl,
      regionName,
      audioFileSize: audioFile.size,
      uploadUrl: `${neoBaseUrl}/api/neo/upload-audio`,
    });

    // Step 1: Upload audio to Neo
    const uploadFormData = new FormData();
    uploadFormData.append("file", audioFile);
    uploadFormData.append("observer_id", user.id);

    const uploadResponse = await fetch(`${neoBaseUrl}/api/neo/upload-audio`, {
      method: "POST",
      headers: {
        "X-API-Key": apiKey,
      },
      body: uploadFormData,
    });

    if (!uploadResponse.ok) {
      const uploadError = await uploadResponse.text();
      console.error("Neo upload failed:", {
        status: uploadResponse.status,
        neoBaseUrl,
        regionName,
        responseText: uploadError,
      });
      return new Response(
        JSON.stringify({
          error: `Neo upload failed: ${uploadResponse.status}`,
          errorType: "NEO_UPLOAD_FAILED",
          neoUrl: `${neoBaseUrl}/api/neo/upload-audio`,
          region: regionName,
          details: uploadError,
        }),
        {
          status: uploadResponse.status,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const uploadData = await uploadResponse.json();
    const audioS3Url = uploadData.s3_url;

    if (!audioS3Url) {
      return new Response(
        JSON.stringify({ error: "No s3_url returned from Neo upload" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Step 2: Start processing
    const processFormData = new FormData();
    processFormData.append("audio_s3_url", audioS3Url);
    processFormData.append("observer_id", user.id);
    processFormData.append("region", regionName);

    const processResponse = await fetch(
      `${neoBaseUrl}/api/neo/process-coaching-audio`,
      {
        method: "POST",
        headers: {
          "X-API-Key": apiKey,
        },
        body: processFormData,
      }
    );

    if (!processResponse.ok) {
      const processError = await processResponse.text();
      return new Response(
        JSON.stringify({
          error: `Neo process failed: ${processResponse.status}`,
          details: processError,
        }),
        {
          status: processResponse.status,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const processData = await processResponse.json();
    const taskId = processData.task_id;

    if (!taskId) {
      return new Response(
        JSON.stringify({ error: "No task_id returned from Neo" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Step 3: Update observation with neo_task_id and neo_status
    const { error: updateError } = await supabase
      .from("cot_observations")
      .update({
        neo_status: "processing",
        neo_task_id: taskId,
        neo_requested_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq("id", observationId);

    if (updateError) {
      // Observation may only exist in Railway Postgres — log but don't block the response
      console.warn("Could not update Supabase cot_observations (Railway-only observation):", updateError.message);
    }

    return new Response(
      JSON.stringify({ ok: true, task_id: taskId, status: "processing" }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("neo-start error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Internal server error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
