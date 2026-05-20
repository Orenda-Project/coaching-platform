# Coaching Content Export API - Documentation Hub

**Production Service:** ✅ `https://coaching-content-api-production.up.railway.app`

Welcome! This folder contains everything you need to use, integrate, and share the Coaching Content Export API.

---

## 📚 Documentation Files

### 1. **QUICK_START.md** ⭐ START HERE
**For:** First-time users, quick testing, copy-paste examples  
**Contains:**
- 30-second Postman setup
- First 4 API requests (bash/curl ready)
- Common tasks with code examples
- Postman tips & tricks

**Read this if:** You want to make your first API request in 2 minutes

---

### 2. **API_DOCUMENTATION.md** 📖 COMPLETE REFERENCE
**For:** Understanding the API in detail, all endpoints, response formats  
**Contains:**
- Full endpoint reference with examples
- Response formats and field descriptions
- Error handling guide
- Real-world integration examples
- Rate limiting and troubleshooting

**Read this if:** You need to understand how the API works deeply

---

### 3. **INTEGRATION_GUIDE.md** 🔌 FOR DEVELOPERS
**For:** Integrating the API into your application  
**Contains:**
- 3 implementation approaches (direct calls, cached, scheduled sync)
- Code examples in Python and JavaScript
- Common integration scenarios (LMS, analytics, backups)
- Error handling patterns
- Performance optimization tips

**Read this if:** You're building an app that uses this API

---

### 4. **postman_collection.json** 📦 IMPORT THIS
**For:** Postman users (recommended way to test API)  
**Contains:**
- Pre-configured requests for all 4 endpoints
- Example responses for success and error cases
- Environment variables setup
- Base URL already configured

**Use this if:** You use Postman for API testing

---

## 🚀 Getting Started (3 Steps)

### Step 1: Download Postman Collection
```bash
# The file is here:
coaching-api/postman_collection.json
```

### Step 2: Import into Postman
1. Open Postman
2. Click **File → Import**
3. Select `postman_collection.json`
4. ✅ Collection is now in your Postman!

### Step 3: Make Your First Request
1. Click **"Health Check"** in the collection
2. Click **"Send"**
3. See response: `"status": "ok"` ✅

---

## 📋 Which File Should I Read?

| Your Role | Read First | Then Read |
|-----------|-----------|-----------|
| **Quality Tester / QA** | QUICK_START.md | API_DOCUMENTATION.md |
| **Developer (Integration)** | QUICK_START.md | INTEGRATION_GUIDE.md |
| **DevOps / Backend** | API_DOCUMENTATION.md | INTEGRATION_GUIDE.md |
| **Product Manager** | QUICK_START.md | API_DOCUMENTATION.md (Summary) |
| **First-time User** | QUICK_START.md | (Go from there!) |

---

## 🎯 Common Tasks

### "I want to test the API in Postman"
→ Import `postman_collection.json` → See **QUICK_START.md** → Done! ✅

### "I want to understand all the endpoints"
→ Read **API_DOCUMENTATION.md** → Section: "Endpoints"

### "I want to integrate this into my app"
→ Read **INTEGRATION_GUIDE.md** → Choose an implementation approach

### "I want to show modules in my learning platform"
→ Read **INTEGRATION_GUIDE.md** → Section: "Scenario 1: LMS Integration"

### "I want to backup all content"
→ Read **INTEGRATION_GUIDE.md** → Section: "Scenario 3: Backup & Recovery"

---

## 📡 The 4 Core Endpoints

| Endpoint | Purpose | Learn More |
|----------|---------|-----------|
| `GET /api/export/health` | Check service status | QUICK_START.md |
| `GET /api/export/modules` | List all modules | API_DOCUMENTATION.md |
| `GET /api/export/modules/{id}` | Get module with trainings & questions | API_DOCUMENTATION.md |
| `GET /api/export/complete` | Download all content at once | API_DOCUMENTATION.md |

---

## 💡 Quick Examples

### Test with curl
```bash
# Health check
curl https://coaching-content-api-production.up.railway.app/api/export/health | jq .

# List modules
curl https://coaching-content-api-production.up.railway.app/api/export/modules | jq .
```

### Test with Python
```python
import requests

url = "https://coaching-content-api-production.up.railway.app"
response = requests.get(f"{url}/api/export/modules")
modules = response.json()["modules"]
print(f"Found {len(modules)} modules")
```

### Test with JavaScript
```javascript
const url = "https://coaching-content-api-production.up.railway.app";
fetch(`${url}/api/export/modules`)
  .then(r => r.json())
  .then(d => console.log(`${d.modules.length} modules`));
```

---

## 📦 What Data Can I Access?

✅ **6 Modules** - With titles, descriptions, competencies  
✅ **25 Trainings** - Learning units across modules  
✅ **80+ Questions** - Multiple choice and open-ended  
✅ **Content Assets** - Slides, videos with URLs  
✅ **Metadata** - Order numbers, personas, flags  

---

## 🔧 Sharing with Other Teams

### Option 1: Send Postman Collection (Easiest)
1. Export `postman_collection.json`
2. Send to team via email or Slack
3. They import into Postman → Ready to go!

### Option 2: Create Slack Message with curl Examples
```
📢 NEW API: Coaching Content Export

Quick start:
curl https://coaching-content-api-production.up.railway.app/api/export/health

Full docs: [Link to this README]
Postman collection: [Attach JSON file]
```

### Option 3: API Gateway (With Auth)
If external teams need access:
1. Add API key authentication (see INTEGRATION_GUIDE.md)
2. Rate limit by API key
3. Share via managed portal

---

## 🛠️ Support & Questions

| Question | Answer |
|----------|--------|
| "API is not responding" | Check health: `/api/export/health`. Post in #coaching-api-support |
| "What fields does the module have?" | See **API_DOCUMENTATION.md** → Endpoints → List Modules |
| "How do I integrate with my app?" | Read **INTEGRATION_GUIDE.md** |
| "Can I cache the responses?" | Yes! See INTEGRATION_GUIDE.md → Performance Tips |
| "Is there rate limiting?" | Yes, 1000/hour. See API_DOCUMENTATION.md → Rate Limiting |

**Slack:** #coaching-api-support  
**Email:** api-support@taleemabad.com

---

## 📊 API Status & Metrics

| Metric | Value |
|--------|-------|
| Service Status | ✅ Production Live |
| Database | Railway PostgreSQL |
| Records Available | 57 (6 modules, 25 trainings) |
| Avg Response Time | <500ms |
| Uptime Target | 99.5% |
| Rate Limit | 1000 req/hour |

---

## 🔄 Implementation Flow

```
Read QUICK_START.md (5 min)
           ↓
Import Postman Collection
           ↓
Test endpoints in Postman
           ↓
Read API_DOCUMENTATION.md (15 min)
           ↓
Decide on integration approach
           ↓
Read INTEGRATION_GUIDE.md (20 min)
           ↓
Code your integration
           ↓
Share Postman collection with other teams ✅
```

---

## 📝 File Locations

```
coaching-api/
├── docs/
│   ├── README.md ← YOU ARE HERE
│   ├── QUICK_START.md ← Read this first!
│   ├── API_DOCUMENTATION.md
│   ├── INTEGRATION_GUIDE.md
│   └── ... (other docs)
└── postman_collection.json ← Import this into Postman
```

---

## 🎓 Learning Path

**Beginner (Just want to test):**
1. QUICK_START.md → Make requests in curl/Postman
2. Done! ✅

**Intermediate (Need to integrate):**
1. QUICK_START.md → Test API
2. API_DOCUMENTATION.md → Understand endpoints
3. INTEGRATION_GUIDE.md → Choose implementation
4. Code your integration

**Advanced (Building complex system):**
1. API_DOCUMENTATION.md → Full reference
2. INTEGRATION_GUIDE.md → All scenarios
3. Customize caching/error handling
4. Implement monitoring

---

## 🎯 Next Actions

- [ ] Download and import `postman_collection.json`
- [ ] Test `/api/export/health` endpoint
- [ ] List all modules with `/api/export/modules`
- [ ] Read full **API_DOCUMENTATION.md**
- [ ] Share with your team!

---

## 📞 Contact & Support

Need help? 

- 💬 **Slack:** #coaching-api-support
- 📧 **Email:** api-support@taleemabad.com
- 📚 **Docs:** API_DOCUMENTATION.md (this folder)

---

**Version:** 1.0  
**Status:** ✅ Production Live  
**Last Updated:** 2026-05-19

**Get started now!** → Read [QUICK_START.md](./QUICK_START.md)
