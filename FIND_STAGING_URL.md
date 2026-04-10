# Find Your Staging Live URL

---

## 🔗 Quick Steps to Find Your Staging URL

### Method 1: Railway Dashboard (Easiest) ⭐

1. Go to **https://railway.app/dashboard**
2. Login if needed
3. Click on **"coaching-platform-staging"** project
4. Look at the **"Deployments"** section
5. Find the green **✓** (successful deployment)
6. Click on it to expand
7. Copy the **domain URL** (should look like `https://coaching-platform-staging-production.up.railway.app/`)

### Method 2: Railway CLI

```bash
# Install if not already installed
npm install -g @railway/cli

# Login
railway login

# Navigate to coaching-platform repo
cd /Users/mac/Desktop/data/Taleemabad/coaching-platform

# Switch to staging environment
railway environment staging

# Get the domain
railway domain

# This will output something like:
# coaching-platform-staging-production.up.railway.app
```

### Method 3: Check via GitHub Actions

1. Go to **GitHub → Orenda-Project/coaching-platform**
2. Click **Actions** tab
3. Find the most recent **"Deploy"** workflow run
4. Click on it
5. Look for "deploy-staging" job
6. Check the **logs** for:
   - "Build successful" ✓
   - "Deployed to: https://..."

---

## ✅ What to Look For

Once you find the URL, verify the staging deployment:

```bash
# Test the URL
curl https://your-staging-url/

# Should return HTML (not error)
# Should see coaching platform landing page
```

**In Browser:**
1. Open the staging URL
2. Should see: Landing page with "Sign Up" and "Login" buttons
3. Check browser console (F12 → Console tab):
   ```javascript
   // Should print "staging" (not "production")
   console.log(import.meta.env.VITE_ENVIRONMENT)
   ```

---

## 🧪 Quick Test After Finding URL

```bash
STAGING_URL="https://your-staging-url-here"

# Test 1: Page loads
curl -I $STAGING_URL
# Should return: HTTP/1.1 200 OK

# Test 2: Environment is correct
curl $STAGING_URL | grep -i "coaching\|platform"
# Should see HTML with page content
```

---

## 🚀 Next: Full E2E Test on Staging

Once you have the URL:

1. **Signup as test user**
   ```
   URL: https://your-staging-url/signup
   Email: testcoach+staging@example.com
   Password: Test123!
   ```

2. **Take baseline assessment**
   - Click "Dashboard"
   - Click "Start Assessment"
   - Answer 30 questions
   - Target score: >60% to pass

3. **Check persona assigned**
   - Persona should be A, B, C, or D
   - If <60%, you'll see "Assessment Failed" (normal)

4. **Complete Module 1**
   - Click Module 1
   - Watch video (90% to unlock quiz)
   - Take quiz (80% to pass)
   - Max 3 attempts

5. **Take endline**
   - Endline should be locked until all modules passed
   - Once unlocked, take it (70% to pass)
   - Should issue certificate

---

## 🔍 If Staging URL Not Found

**Check these:**

1. **Staging environment exists in Railway**
   - Dashboard → should show "coaching-platform-staging" project
   - Should have a "web" service

2. **Build was successful**
   - Check Deployments → green checkmark
   - If red ✗, check logs for build errors

3. **Environment variables set**
   - Railway → Settings → Variables
   - Should have: `VITE_SUPABASE_PROJECT_ID=kddvxrlffafyjvvststh`

4. **GitHub Actions passed**
   - Repo → Actions → Deploy workflow
   - Should see "deploy-staging" job passed (green)

---

## ⚡ Troubleshooting: Staging Not Loading

**"Page won't load"**
- Check if Railway service is running (Dashboard → status)
- Check build logs for errors
- Restart service: Dashboard → Service → Restart

**"Shows production data"**
- Check `VITE_SUPABASE_PROJECT_ID` in Railway env vars
- Should be: `kddvxrlffafyjvvststh` (not production ID)
- Hard refresh: Cmd+Shift+R (on Mac) or Ctrl+Shift+R (Windows)

**"500 error"**
- Check Railway logs: Dashboard → Deployments → view logs
- Common issues:
  - Supabase project ID wrong
  - Environment variables missing
  - Build failed silently

---

## 📝 Save Your Staging URL

Once you find it, save it here for reference:

```
STAGING URL: https://________________________________________

Bookmark this link! You'll use it for:
- Testing new features before production
- QA testing
- Staging database browser (at /admin)
```

---

## 🎯 Next Steps

1. **Find your staging URL** (using Method 1 above)
2. **Test the URL** (should load landing page)
3. **Run E2E flow** (signup → baseline → module → endline)
4. **Commit the verification** (update this file with URL)

---

**Need help?** Check the detailed troubleshooting in `STAGING_VERIFICATION.md`

