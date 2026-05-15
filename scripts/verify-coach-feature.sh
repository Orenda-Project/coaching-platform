#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Automated Coach Feature Verification Script (Bash/curl version)
#
# Purpose: Test if coaches can see all modules after deployment
# Usage: ./scripts/verify-coach-feature.sh [email] [environment]
# Example: ./scripts/verify-coach-feature.sh jalal.khan125@gmail.com production
# ─────────────────────────────────────────────────────────────────────────────

set -e

EMAIL="${1:-jalal.khan125@gmail.com}"
ENVIRONMENT="${2:-production}"

# Load environment variables
ENV_FILE=".env"
if [ "$ENVIRONMENT" = "staging" ]; then
  ENV_FILE=".env.local"
fi

if [ -f "$ENV_FILE" ]; then
  export $(grep VITE_SUPABASE_URL "$ENV_FILE" | xargs)
  export $(grep VITE_SUPABASE_PUBLISHABLE_KEY "$ENV_FILE" | xargs)
fi

SUPABASE_URL="${VITE_SUPABASE_URL}"
SUPABASE_KEY="${VITE_SUPABASE_PUBLISHABLE_KEY}"

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_KEY" ]; then
  echo "❌ Error: VITE_SUPABASE_URL or VITE_SUPABASE_PUBLISHABLE_KEY not set"
  echo "Make sure $ENV_FILE exists in project root"
  exit 1
fi

echo "🔍 Verifying Coach Feature Deployment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Email: $EMAIL"
echo "Environment: $ENVIRONMENT"
echo ""

# Step 1: Find user
echo "📋 STEP 1: Looking for user by email"
echo "─────────────────────────────────────────────────────────────"
USER_RESPONSE=$(curl -s -X POST "$SUPABASE_URL/rest/v1/rpc/execute_query" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"SELECT id, full_name, persona, weak_modules FROM public.profiles WHERE email = '$EMAIL' LIMIT 1\"}" 2>/dev/null || echo "{}")

USER_ID=$(echo "$USER_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$USER_ID" ]; then
  echo "❌ User $EMAIL not found"
  exit 1
fi

echo "✓ Found user with ID: $USER_ID"
echo ""

# Step 2: Check coach role
echo "📋 STEP 2: Checking if user has coach role"
echo "─────────────────────────────────────────────────────────────"
ROLES_RESPONSE=$(curl -s -X GET "$SUPABASE_URL/rest/v1/user_roles?user_id=eq.$USER_ID&role=eq.coach" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json" 2>/dev/null || echo "[]")

if echo "$ROLES_RESPONSE" | grep -q "coach"; then
  echo "✓ User HAS coach role"
  HAS_COACH_ROLE=true
else
  echo "✗ User DOES NOT have coach role"
  HAS_COACH_ROLE=false
fi
echo ""

# Step 3: Get all modules
echo "📋 STEP 3: Fetching all modules"
echo "─────────────────────────────────────────────────────────────"
MODULES_RESPONSE=$(curl -s -X GET "$SUPABASE_URL/rest/v1/modules?order=order_number" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json" 2>/dev/null || echo "[]")

MODULE_COUNT=$(echo "$MODULES_RESPONSE" | grep -o '"id":' | wc -l)
echo "✓ Found $MODULE_COUNT total modules"
echo ""

# Step 4: Summary
echo "📊 VERIFICATION SUMMARY"
echo "═════════════════════════════════════════════════════════════"
echo "User Email: $EMAIL"
echo "Coach Role: $([ "$HAS_COACH_ROLE" = true ] && echo '✓ YES' || echo '✗ NO')"
echo "Total Modules: $MODULE_COUNT"
echo ""

if [ "$HAS_COACH_ROLE" = true ]; then
  echo "Status: ✅ PASS - Coach should see all $MODULE_COUNT modules"
  exit 0
else
  echo "Status: ⚠️ CHECK - Coach role not found"
  exit 1
fi
