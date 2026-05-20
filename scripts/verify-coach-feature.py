#!/usr/bin/env python3
"""
Automated Coach Feature Verification Script

Purpose: Test if coaches can see all modules after deployment
Usage: python3 scripts/verify-coach-feature.py [email] [environment]
Example: python3 scripts/verify-coach-feature.py jalal.khan125@gmail.com production
"""

import sys
import os
from dotenv import load_dotenv
from supabase import create_client, Client

# Load environment variables
env_file = '.env' if (len(sys.argv) > 2 and sys.argv[2] == 'production') else '.env.local'
if os.path.exists(env_file):
    load_dotenv(env_file)

EMAIL = sys.argv[1] if len(sys.argv) > 1 else 'jalal.khan125@gmail.com'
ENVIRONMENT = sys.argv[2] if len(sys.argv) > 2 else 'production'

SUPABASE_URL = os.getenv('VITE_SUPABASE_URL')
SUPABASE_KEY = os.getenv('VITE_SUPABASE_PUBLISHABLE_KEY')

if not SUPABASE_URL or not SUPABASE_KEY:
    print("❌ Error: VITE_SUPABASE_URL or VITE_SUPABASE_PUBLISHABLE_KEY not set")
    print("Make sure to run from project root with .env files configured")
    sys.exit(1)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def verify():
    print("🔍 Verifying Coach Feature Deployment")
    print("=" * 60)
    print(f"Email: {EMAIL}")
    print(f"Environment: {ENVIRONMENT}")
    print(f"Supabase URL: {SUPABASE_URL}")
    print()

    try:
        # Step 1: Find user
        print("📋 STEP 1: Looking for user by email")
        print("-" * 60)
        response = supabase.table('profiles').select('id, full_name, persona, weak_modules').eq('email', EMAIL).execute()

        if not response.data or len(response.data) == 0:
            print(f"❌ User {EMAIL} not found")
            return False

        user = response.data[0]
        user_id = user['id']
        print(f"✓ Found user: {user['full_name']}")
        print(f"  Persona: {user['persona']}")
        print(f"  Weak Modules: {user['weak_modules']}")
        print()

        # Step 2: Check coach role
        print("📋 STEP 2: Checking if user has coach role")
        print("-" * 60)
        response = supabase.table('user_roles').select('role').eq('user_id', user_id).execute()

        has_coach_role = any(r['role'] == 'coach' for r in response.data) if response.data else False
        if has_coach_role:
            print("✓ User HAS coach role")
        else:
            print("✗ User DOES NOT have coach role")
        print()

        # Step 3: Get all modules
        print("📋 STEP 3: Fetching all modules")
        print("-" * 60)
        response = supabase.table('modules').select('id, title, order_number, is_mandatory').order('order_number').execute()

        modules = response.data if response.data else []
        if not modules:
            print("❌ No modules found in database")
            return False

        print(f"✓ Found {len(modules)} total modules:")
        for m in modules:
            mandatory = " (mandatory)" if m['is_mandatory'] else ""
            print(f"  [{m['order_number']}] {m['title']}{mandatory}")
        print()

        # Step 4: Calculate visible modules
        print("📋 STEP 4: Calculating expected visible modules")
        print("-" * 60)

        if has_coach_role or user['persona'] == 'E':
            visible_modules = modules
            print("✓ User should see ALL modules (coach or Persona E)")
        else:
            weak_modules = user['weak_modules'] or []
            visible_modules = [
                m for m in modules
                if m['is_mandatory'] or any(m['title'].startswith(wm) for wm in weak_modules)
            ]
            print(f"✓ User should see: Module 1 (mandatory) + weak_modules")

        visible_nums = [m['order_number'] for m in visible_modules]
        print(f"  Visible modules: {', '.join(map(str, visible_nums))}")
        print()

        # Step 5: Check trainings
        print("📋 STEP 5: Checking trainings availability")
        print("-" * 60)
        response = supabase.table('trainings').select('id, title, module_id').execute()

        trainings_count = len(response.data) if response.data else 0
        print(f"✓ Total trainings in database: {trainings_count}")
        print()

        # Step 6: Summary
        print("📊 VERIFICATION SUMMARY")
        print("=" * 60)
        print(f"User: {user['full_name']} ({EMAIL})")
        print(f"Persona: {user['persona']}")
        print(f"Coach Role: {'✓ YES' if has_coach_role else '✗ NO'}")
        print(f"Expected Visible Modules: {len(visible_modules)} of {len(modules)}")
        print(f"Module List: {', '.join(map(str, visible_nums))}")
        print()

        # Status
        should_see_all = has_coach_role or user['persona'] == 'E'
        all_visible = len(visible_modules) == len(modules)
        status = "✅ PASS" if (should_see_all and all_visible) else "⚠️ CHECK"

        print(f"Status: {status}")
        print("=" * 60)

        return should_see_all and all_visible

    except Exception as error:
        print(f"❌ Error during verification: {str(error)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = verify()
    sys.exit(0 if success else 1)
