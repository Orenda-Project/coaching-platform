# Quick Start Guide - Coaching Content Export API

**Time to first request:** 2 minutes

---

## ⚡ 30-Second Setup

### 1. Install Postman
- Download: https://www.postman.com/downloads/
- Or use web version: https://www.postman.com/

### 2. Import Collection
- Download: [postman_collection.json](../postman_collection.json)
- In Postman: **File** → **Import** → Select the `.json` file
- ✅ Done! Collection is now in your Postman

### 3. Make Your First Request
- Click **"Health Check"** in the collection
- Click **"Send"**
- See the response: `"status": "ok"`

---

## 🚀 First Requests (Copy-Paste Ready)

### Get All Modules
```bash
curl https://coaching-content-api-production.up.railway.app/api/export/modules | jq .
```

### Get Module Details (with trainings & questions)
```bash
# First, get a module ID from the list above, then:
curl https://coaching-content-api-production.up.railway.app/api/export/modules/[MODULE_ID] | jq .
```

### Get Complete Export (all content)
```bash
curl https://coaching-content-api-production.up.railway.app/api/export/complete | jq . > coaching_export.json
```

---

## 📡 The 4 Endpoints You Need

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/export/health` | GET | Check if service is running |
| `/api/export/modules` | GET | List all modules |
| `/api/export/modules/{id}` | GET | Get specific module with content |
| `/api/export/complete` | GET | Download everything at once |

---

## ✅ Common Tasks

### Task 1: Display Module List in My App

```javascript
fetch('https://coaching-content-api-production.up.railway.app/api/export/modules')
  .then(res => res.json())
  .then(data => {
    data.modules.forEach(module => {
      console.log(`${module.order_number}. ${module.title}`);
    });
  });
```

### Task 2: Get Quiz Questions for a Module

```python
import requests

module_id = "550e8400-e29b-41d4-a716-446655440000"  # Replace with your module ID
response = requests.get(
    f"https://coaching-content-api-production.up.railway.app/api/export/modules/{module_id}"
)
module = response.json()

for training in module["trainings"]:
    for question in training.get("questions", []):
        print(f"Q: {question['question_text']}")
        for option in question["options"]:
            print(f"  - {option['option_text']}")
```

### Task 3: Backup All Content to File

```bash
curl https://coaching-content-api-production.up.railway.app/api/export/complete | jq . > content_backup.json

# Verify it worked
ls -lh content_backup.json
jq '.stats' content_backup.json
```

### Task 4: Get Content URLs for a Training

```python
import requests
import json

module_id = "550e8400-e29b-41d4-a716-446655440000"
response = requests.get(
    f"https://coaching-content-api-production.up.railway.app/api/export/modules/{module_id}"
)
module = response.json()

for training in module["trainings"]:
    print(f"\n{training['title']}")
    for content in training.get("content", []):
        print(f"  {content['format_type']}: {content['content_url']}")
        print(f"  Duration: {content.get('duration_minutes', 'N/A')} min")
```

---

## 🎯 In Postman

### Set Base URL (Save Time)

1. Click **"Variables"** at top
2. Set Variable:
   - **Variable:** `base_url`
   - **Value:** `https://coaching-content-api-production.up.railway.app`
3. Click **"Save"**

Now all requests use `{{base_url}}` automatically!

### Import Pre-built Requests

Our Postman collection includes:
- ✅ All 4 endpoints pre-configured
- ✅ Example responses
- ✅ Error case examples
- ✅ Base URL variable

Just click → Send → Done!

---

## 🔍 Understanding Responses

### Success Response (200)
```json
{
  "modules": [...],
  "stats": {
    "total_modules": 6,
    "export_timestamp": "2026-05-19T10:54:32.429Z"
  }
}
```

### Error Response (404)
```json
{
  "detail": "Module not found"
}
```

---

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "Connection refused" | Service is down. Check #coaching-api-support |
| "404 Not Found" | Module ID is invalid. Get list from `/api/export/modules` |
| "Timeout" | Network slow. Try again or get individual module instead of complete export |
| "Invalid JSON" | Copy-paste the URL exactly, including `https://` |

---

## 📚 Next Steps

- **Want the full API docs?** → [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)
- **Need to integrate with your app?** → See the examples above
- **Have questions?** → Slack `#coaching-api-support`

---

## 💡 Pro Tips

1. **Use `jq` for pretty JSON:** `curl ... | jq .`
2. **Save to file:** `curl ... | jq . > backup.json`
3. **Filter responses:** `jq '.modules[0]' backup.json`
4. **Check response time:** Postman shows it in bottom right
5. **Cache responses:** Data doesn't change often, cache for 1 hour

---

**You're ready!** Make your first request now. 🚀
