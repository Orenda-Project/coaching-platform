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

    // Parse request body
    const body = await req.json();
    const observationId = body.observation_id as string | null;

    if (!observationId) {
      return new Response(JSON.stringify({ error: "Missing observation_id" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Get observation with neo_task_id
    const { data: obs, error: obsError } = await supabase
      .from("cot_observations")
      .select("id,neo_task_id,region,neo_status")
      .eq("id", observationId)
      .eq("observer_id", user.id)
      .single();

    if (obsError || !obs) {
      return new Response(
        JSON.stringify({ error: "Observation not found or unauthorized" }),
        {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (!obs.neo_task_id) {
      return new Response(
        JSON.stringify({ error: "Neo task not started" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const region = obs.region || "ICT";
    const regionName = getRegionName(region);
    const apiKey = getRegionKey(region);

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

    // Poll status from Neo
    const statusResponse = await fetch(
      `${neoBaseUrl}/api/neo/status/${obs.neo_task_id}`,
      {
        method: "GET",
        headers: {
          "X-API-Key": apiKey,
        },
      }
    );

    if (!statusResponse.ok) {
      const statusError = await statusResponse.text();
      return new Response(
        JSON.stringify({
          error: `Neo status check failed: ${statusResponse.status}`,
          details: statusError,
        }),
        {
          status: statusResponse.status,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const statusData = await statusResponse.json();
    const neoStatus = statusData.status; // "processing", "completed", "failed"

    // If completed, update observation with results
    if (neoStatus === "completed") {
      const { error: updateError } = await supabase
        .from("cot_observations")
        .update({
          neo_status: "completed",
          neo_results: statusData.results || {},
          neo_completed_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq("id", observationId);

      if (updateError) {
        console.error("Failed to update observation with results:", updateError);
      }
    } else if (neoStatus === "failed") {
      const { error: updateError } = await supabase
        .from("cot_observations")
        .update({
          neo_status: "failed",
          neo_error: statusData.error || "Unknown error",
          updated_at: new Date().toISOString(),
        })
        .eq("id", observationId);

      if (updateError) {
        console.error("Failed to update observation with error:", updateError);
      }
    }

    return new Response(
      JSON.stringify({
        status: neoStatus,
        results: statusData.results || null,
        error: statusData.error || null,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("neo-status error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Internal server error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
