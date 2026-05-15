#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Automated Coach Feature Verification Script
#
# Purpose: Test if coaches can see all modules after deployment
# Usage: ./scripts/verify-coach-deployment.sh [email] [environment]
# Example: ./scripts/verify-coach-deployment.sh jalal.khan125@gmail.com production
# ─────────────────────────────────────────────────────────────────────────────

set -e

EMAIL="${1:-jalal.khan125@gmail.com}"
ENVIRONMENT="${2:-production}"

echo "🔍 Verifying Coach Feature Deployment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Email: $EMAIL"
echo "Environment: $ENVIRONMENT"
echo ""

# Get Supabase connection details from environment
SUPABASE_URL="${VITE_SUPABASE_URL:-http://127.0.0.1:54321}"
SUPABASE_KEY="${VITE_SUPABASE_PUBLISHABLE_KEY}"

if [ -z "$SUPABASE_KEY" ]; then
  echo "❌ Error: VITE_SUPABASE_PUBLISHABLE_KEY not set"
  echo "Set it from your .env or .env.production file"
  exit 1
fi

echo "✓ Using Supabase URL: $SUPABASE_URL"
echo ""

# Function to run SQL query against Supabase
run_query() {
  local query=$1
  local description=$2

  echo "📋 $description"
  curl -s -X POST "$SUPABASE_URL/rest/v1/rpc/exec_sql" \
    -H "Authorization: Bearer $SUPABASE_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"query\": \"$query\"}" 2>/dev/null || echo "Query execution failed"
  echo ""
}

echo "STEP 1: Check if coach enum exists"
echo "─────────────────────────────────────────────────────────────────"
run_query "SELECT enum_range(NULL::app_role) as app_roles;" "Checking app_role enum values"

echo "STEP 2: Find user by email"
echo "─────────────────────────────────────────────────────────────────"
run_query "SELECT id, email FROM auth.users WHERE email = '$EMAIL';" "Looking for $EMAIL"

echo "STEP 3: Check if user has coach role"
echo "─────────────────────────────────────────────────────────────────"
run_query "SELECT ur.user_id, ur.role FROM public.user_roles ur JOIN auth.users u ON ur.user_id = u.id WHERE u.email = '$EMAIL';" "Checking coach role assignment"

echo "STEP 4: Check user profile"
echo "─────────────────────────────────────────────────────────────────"
run_query "SELECT id, full_name, persona, weak_modules FROM public.profiles WHERE id IN (SELECT id FROM auth.users WHERE email = '$EMAIL');" "Getting profile data"

echo "STEP 5: List all modules"
echo "─────────────────────────────────────────────────────────────────"
run_query "SELECT id, title, order_number, is_mandatory FROM public.modules ORDER BY order_number;" "All available modules"

echo "STEP 6: Count enrolled coaches"
echo "─────────────────────────────────────────────────────────────────"
run_query "SELECT COUNT(*) as total_coaches FROM public.user_roles WHERE role = 'coach';" "Total coaches enrolled"

echo ""
echo "✅ Verification complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
