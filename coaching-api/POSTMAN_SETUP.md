# Postman Setup Instructions

**Step-by-step guide to test the API in Postman**

---

## 📥 Install Postman

### Option 1: Desktop App (Recommended)
1. Go to https://www.postman.com/downloads/
2. Download for your OS (Mac/Windows/Linux)
3. Install and launch
4. Create free account (or skip)

### Option 2: Web App
1. Go to https://www.postman.com/
2. Click **"Sign In"** or **"Create Account"**
3. No installation needed!

---

## 🚀 Import Collection (3 Steps)

### Step 1: Get the File
The file `postman_collection.json` is located in:
```
coaching-platform/coaching-api/postman_collection.json
```

### Step 2: Open Postman
Launch Postman (desktop or web)

### Step 3: Import
**Desktop Postman:**
1. Click **File** menu (top left)
2. Select **Import**
3. Click **Select Files**
4. Navigate to `postman_collection.json`
5. Select it and click **Open**
6. Click **Import** button

**Web Postman:**
1. Click **Import** button (top bar)
2. Click **Upload Files**
3. Select `postman_collection.json`
4. Click **Import**

✅ **Collection imported!** You should see the collection in your left sidebar.

---

## ⚙️ Configure Variables

### Set Base URL (Recommended)

**Why:** Saves you from typing the full URL each time

**Steps:**
1. Click your collection name: **"Coaching Content Export API"**
2. Click **Variables** tab (next to Documentation)
3. You should see a variable `base_url`
4. Value should be: `https://coaching-content-api-production.up.railway.app`
5. Click **Save** (top right)

✅ **Now all requests will use this base URL automatically!**

---

## 📡 Make Your First Request

### Request 1: Health Check (30 seconds)

1. In left sidebar, expand **"Coaching Content Export API"**
2. Expand **"Health & Status"** folder
3. Click **"Health Check"** request
4. You should see the request details:
   ```
   GET {{base_url}}/api/export/health
   ```
5. Click blue **"Send"** button (top right)
6. Look at response below:
   ```json
   {
     "status": "ok",
     "version": "1.0",
     "environment": "production",
     "timestamp": "2026-05-19T10:54:32.429Z"
   }
   ```

✅ **Success!** Your API is working.

---

## 🧪 Test All 4 Endpoints

### Request 2: List Modules

1. Left sidebar → **Modules** → **"List All Modules"**
2. Click **Send**
3. See response: Array of 6 modules with metadata

```json
{
  "modules": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Module 1: Foundation",
      "order_number": 1,
      ...
    }
  ]
}
```

✅ **You now have the module IDs!**

---

### Request 3: Get Module Details

1. Left sidebar → **Modules** → **"Get Module Details"**
2. **Replace** the module ID in the URL:
   - Find: `550e8400-e29b-41d4-a716-446655440000`
   - Replace with: An ID from the modules list above
3. Click **Send**
4. See full module details:
   ```json
   {
     "id": "...",
     "title": "...",
     "trainings": [
       {
         "id": "...",
         "questions": [...]
       }
     ]
   }
   ```

✅ **You now have trainings and questions!**

---

### Request 4: Complete Export

1. Left sidebar → **Content Export** → **"Complete Export"**
2. Click **Send**
3. See response with all modules, trainings, questions
4. Response will be large (~3-5 MB)

✅ **This is the full export!**

---

## 💾 Save Response as File

**To download response data:**

1. Make any request (e.g., Complete Export)
2. Click **"Send"** and wait for response
3. In response pane (bottom), click **"Save Response"**
4. Choose **"Save response body to file"**
5. Name it: `coaching_content.json`
6. Click **Save**

✅ **File saved to your computer!**

---

## 📝 Create Custom Request

**To test a custom request:**

1. Click **"+"** tab (or File → New → Request)
2. Change method to **GET**
3. In URL field, enter:
   ```
   {{base_url}}/api/export/modules
   ```
4. Click **Send**

✅ **Works because Postman replaces {{base_url}} with the actual URL!**

---

## 🔍 View Formatted Response

**Pretty-print JSON response:**

In response pane:
- Click **"Pretty"** (below the response)
- Response becomes indented and readable
- Click **"Raw"** to see unformatted version

---

## 🧮 Test Error Cases

### Test 404 Error

1. Create new request
2. Method: **GET**
3. URL: `{{base_url}}/api/export/modules/invalid-id`
4. Click **Send**
5. See error response:
   ```json
   {
     "detail": "Module not found"
   }
   ```

Status code: **404** (shown in red)

---

## 📊 View Response Headers

**To see response headers:**

In response pane, click **"Headers"** tab

You should see:
```
content-type: application/json
content-length: 1234
date: Mon, 19 May 2026 10:54:32 GMT
```

---

## 🔄 Create Request Collection Yourself

**To manually create requests (good practice):**

1. Click **New** → **Request**
2. Name: "My Health Check"
3. Method: **GET**
4. URL: `{{base_url}}/api/export/health`
5. Description: "Check if service is running"
6. Click **Save**
7. Choose collection: Coaching Content Export API
8. Click **Send** → Response appears!

---

## 📱 Mobile/Web Testing

**Use Postman Web instead:**

1. Go to https://web.postman.co/
2. Sign in
3. Import collection same way
4. Make requests same way
5. No installation needed!

---

## 🎯 Postman Pro Tips

### 1. Use Environment Variables
```
Base URL: https://coaching-content-api-production.up.railway.app
Timeout: 30
Cache: enabled
```

### 2. Organize Requests in Folders
```
Coaching Content Export API/
├── Health & Status
│   └── Health Check
├── Modules
│   ├── List All Modules
│   └── Get Module Details
└── Content Export
    └── Complete Export
```

### 3. Save Requests as Favorites
⭐ Click star next to request name

### 4. Use Pre-request Scripts
Run code before request (e.g., generate auth tokens)

### 5. Use Tests
Verify response is correct automatically

```javascript
pm.test("Response status is 200", function() {
    pm.response.to.have.status(200);
});

pm.test("Response has modules array", function() {
    pm.expect(pm.response.json().modules).to.be.an('array');
});
```

---

## 🐛 Troubleshooting

### Request hangs (no response)
- Check internet connection
- Close any VPN
- Timeout might be too short
- Try with shorter request (Health Check)

### "SSL_ERROR_INTERNAL_ERROR_ALERT"
- Click **Preferences** → **SSL Verification** → Toggle Off
- Or use web version (no SSL issues)

### Response shows HTML instead of JSON
- Check URL is correct
- Verify endpoint exists
- Check status code (should be 200-400)

### "invalid_json" error
- Response might not be JSON
- Check the Raw response
- Try with Health Check endpoint first

### Can't import collection file
- Make sure file is `.json` (not `.txt`)
- Try drag-and-drop into Postman window
- Use web version if desktop version fails

---

## 📚 Next Steps

After testing in Postman:
1. ✅ Read [QUICK_START.md](./docs/QUICK_START.md)
2. ✅ Read [API_DOCUMENTATION.md](./docs/API_DOCUMENTATION.md)
3. ✅ Read [INTEGRATION_GUIDE.md](./docs/INTEGRATION_GUIDE.md)
4. ✅ Share collection with your team!

---

## 📞 Need Help?

- **Can't import?** Check the file is named `.json`
- **Request failing?** Try Health Check first
- **Need docs?** See [docs/README.md](./docs/README.md)
- **Have questions?** Slack #coaching-api-support

---

**You're all set!** Make your first request now. 🚀
