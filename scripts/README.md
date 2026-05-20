# Coaching Platform Scripts

Automated testing and verification scripts for the coaching platform.

## Coach Feature Verification

Automatically verify that coaches can see all modules after deployment.

### Python Version (Recommended)

```bash
# Verify production (requires .env with production Supabase URL)
python3 scripts/verify-coach-feature.py jalal.khan125@gmail.com production

# Verify staging (requires .env.local with staging Supabase URL)
python3 scripts/verify-coach-feature.py jalal.khan125@gmail.com staging

# Or use default email
python3 scripts/verify-coach-feature.py
```

**Requirements:**
```bash
pip install python-dotenv supabase
```

### Node.js Version

```bash
# Verify production
node scripts/verify-coach-feature.js jalal.khan125@gmail.com production

# Verify staging
node scripts/verify-coach-feature.js jalal.khan125@gmail.com staging
```

**Requirements:**
```bash
npm install @supabase/supabase-js dotenv
```

## What the Script Verifies

The verification script checks:

1. ✓ User exists and loads their profile
2. ✓ User has coach role assigned
3. ✓ All modules exist in database
4. ✓ User sees all expected modules
5. ✓ Trainings are available

## Example Output

```
🔍 Verifying Coach Feature Deployment
============================================================
Email: jalal.khan125@gmail.com
Environment: production
Supabase URL: https://...

📋 STEP 1: Looking for user by email
────────────────────────────────────────────────────────────
✓ Found user: Jalal Khan
  Persona: A
  Weak Modules: ["Module 2", "Module 3"]

📋 STEP 2: Checking if user has coach role
────────────────────────────────────────────────────────────
✓ User HAS coach role

📋 STEP 3: Fetching all modules
────────────────────────────────────────────────────────────
✓ Found 6 total modules:
  [1] Module 1: Foundation (mandatory)
  [2] Module 2: Partnership
  [3] Module 3: Mirror
  [4] Module 4: Digital
  [5] Module 5: Catalyst
  [6] Module 6: Excellence

📋 STEP 4: Calculating expected visible modules
────────────────────────────────────────────────────────────
✓ User should see ALL modules (coach or Persona E)
  Visible modules: 1, 2, 3, 4, 5, 6

📋 STEP 5: Checking trainings availability
────────────────────────────────────────────────────────────
✓ Total trainings in database: 42

📊 VERIFICATION SUMMARY
============================================================
User: Jalal Khan (jalal.khan125@gmail.com)
Persona: A
Coach Role: ✓ YES
Expected Visible Modules: 6 of 6
Module List: 1, 2, 3, 4, 5, 6

Status: ✅ PASS
============================================================
```

## Exit Codes

- `0` — Verification passed ✅
- `1` — Verification failed ❌

## Integration with CI/CD

Add to your CI pipeline:

```yaml
# GitHub Actions example
- name: Verify coach feature
  run: python3 scripts/verify-coach-feature.py test@example.com production
```

## Troubleshooting

**Error: "VITE_SUPABASE_URL not set"**
- Ensure `.env` or `.env.local` exists in the project root
- Verify `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY` are set

**Error: "User not found"**
- Check the email address is correct
- Verify the user exists in Supabase

**Error: "No modules found"**
- Ensure migrations have been applied
- Check the modules table in Supabase

## Creating New Test Users

To create coaches for testing:

```sql
-- Add to user_roles (coach must have coach role)
INSERT INTO public.user_roles (user_id, role)
VALUES ('[user_id]', 'coach')
ON CONFLICT (user_id, role) DO NOTHING;
```

Then run:
```bash
python3 scripts/verify-coach-feature.py test@example.com production
```
