# Coaching Content Export API Documentation

**Version:** 1.0  
**Status:** ✅ Production Live  
**Base URL:** `https://coaching-content-api-production.up.railway.app`  
**Last Updated:** 2026-05-19

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Authentication](#authentication)
4. [Endpoints](#endpoints)
5. [Response Format](#response-format)
6. [Error Handling](#error-handling)
7. [Examples](#examples)
8. [Rate Limiting](#rate-limiting)
9. [Troubleshooting](#troubleshooting)
10. [Support](#support)

---

## 🎯 Overview

The Coaching Content Export API provides internal teams with programmatic access to training content stored in Railway PostgreSQL. This service enables integration with other systems, analytics platforms, and content delivery systems.

### What You Can Access

- **6 Modules** with metadata (titles, descriptions, competencies)
- **25 Trainings** (learning units) across all modules
- **80+ Questions** (MCQ and open-ended)
- **Content Assets** (slides, videos with URLs and duration)
- **Scenarios** (situational learning exercises)

### Key Features

✅ **No Authentication Required** - Internal-only service  
✅ **Fast Responses** - Typical < 500ms response time  
✅ **JSON Format** - Easy integration with any system  
✅ **Complete Content** - All modules, trainings, and materials  
✅ **Production Ready** - Monitored and backed by Railway PostgreSQL

---

## 🚀 Quick Start

### Using curl

```bash
# 1. Check if service is running
curl https://coaching-content-api-production.up.railway.app/api/export/health | jq .

# 2. Get all modules
curl https://coaching-content-api-production.up.railway.app/api/export/modules | jq .

# 3. Get complete export (all content)
curl https://coaching-content-api-production.up.railway.app/api/export/complete | jq . > coaching_content.json
```

### Using Python

```python
import requests
import json

BASE_URL = "https://coaching-content-api-production.up.railway.app"

# Get all modules
response = requests.get(f"{BASE_URL}/api/export/modules")
modules = response.json()["modules"]
print(f"Found {len(modules)} modules")

# Get complete export
response = requests.get(f"{BASE_URL}/api/export/complete")
export_data = response.json()
print(f"Export contains {export_data['stats']['total_modules']} modules")
print(f"Export contains {export_data['stats']['total_trainings']} trainings")

# Save to file
with open("coaching_content.json", "w") as f:
    json.dump(export_data, f, indent=2)
```

### Using JavaScript/Node.js

```javascript
const BASE_URL = "https://coaching-content-api-production.up.railway.app";

// Fetch all modules
fetch(`${BASE_URL}/api/export/modules`)
  .then(res => res.json())
  .then(data => {
    console.log(`Found ${data.modules.length} modules`);
    data.modules.forEach(module => {
      console.log(`- ${module.title}`);
    });
  });

// Fetch complete export
fetch(`${BASE_URL}/api/export/complete`)
  .then(res => res.json())
  .then(data => {
    console.log("Export stats:", data.stats);
    // Process content...
  });
```

---

## 🔐 Authentication

**No authentication required.** This is an internal service accessible only from Taleemabad networks.

For future external access, we can add API keys. Contact the platform team if needed.

---

## 📡 Endpoints

### 1. Health Check

**Purpose:** Verify service is running and get version information.

**Request:**
```
GET /api/export/health
```

**Response (200 OK):**
```json
{
  "status": "ok",
  "version": "1.0",
  "environment": "production",
  "timestamp": "2026-05-19T10:54:32.429Z"
}
```

**Use Cases:**
- Uptime monitoring
- Dependency health checks
- CI/CD health gates

---

### 2. List Modules

**Purpose:** Get list of all available modules with basic metadata.

**Request:**
```
GET /api/export/modules
```

**Response (200 OK):**
```json
{
  "modules": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Module 1: Foundation",
      "description": "Core coaching principles",
      "order_number": 1,
      "is_mandatory": true,
      "persona_required": ["A", "B", "C", "D"],
      "competencies": "Active listening, empathy building"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "title": "Module 2: Advanced Techniques",
      "description": "Building on foundation knowledge",
      "order_number": 2,
      "is_mandatory": false,
      "persona_required": ["B", "C"],
      "competencies": "Scenario analysis, feedback delivery"
    }
  ],
  "stats": {
    "total_modules": 6,
    "export_timestamp": "2026-05-19T10:54:32.429Z"
  }
}
```

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | string (UUID) | Unique module identifier |
| `title` | string | Module name |
| `description` | string | Module summary |
| `order_number` | integer | Display order (1, 2, 3...) |
| `is_mandatory` | boolean | Required for all users |
| `persona_required` | array | Applicable user personas (A, B, C, D) |
| `competencies` | string | Skills covered in module |

**Use Cases:**
- Display module list in frontend
- Filter modules by persona
- Show module progression order

---

### 3. Get Module Details

**Purpose:** Get complete module data including all trainings, content, and questions.

**Request:**
```
GET /api/export/modules/{module_id}
```

**Example:**
```
GET /api/export/modules/550e8400-e29b-41d4-a716-446655440000
```

**Response (200 OK):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Module 1: Foundation",
  "description": "Core coaching principles",
  "order_number": 1,
  "is_mandatory": true,
  "competencies": "Active listening, empathy building",
  "trainings": [
    {
      "id": "660e8400-e29b-41d4-a716-446655440000",
      "title": "Training 1.1: Listening Skills",
      "order_number": 1,
      "content": [
        {
          "id": "770e8400-e29b-41d4-a716-446655440000",
          "format_type": "slides",
          "content_url": "https://example.com/slides/training-1.1.pdf",
          "duration_minutes": 15,
          "metadata": {
            "slide_count": 20,
            "language": "en"
          }
        }
      ],
      "questions": [
        {
          "id": "880e8400-e29b-41d4-a716-446655440000",
          "question_type": "mcq",
          "question_text": "What is active listening?",
          "order_number": 1,
          "max_score": 1,
          "options": [
            {
              "id": "990e8400-e29b-41d4-a716-446655440000",
              "option_text": "Focusing fully on what someone is saying",
              "is_correct": true,
              "order_number": 1
            },
            {
              "id": "990e8400-e29b-41d4-a716-446655440001",
              "option_text": "Waiting for your turn to talk",
              "is_correct": false,
              "order_number": 2
            }
          ]
        }
      ]
    }
  ]
}
```

**Error Response (404 Not Found):**
```json
{
  "detail": "Module not found"
}
```

**Use Cases:**
- Display module details in learning platform
- Extract questions for quiz systems
- Get content URLs for player integration
- Build curriculum reports

---

### 4. Complete Export

**Purpose:** Get all training content in a single request (all modules, trainings, content, questions).

**Request:**
```
GET /api/export/complete
```

**Response (200 OK):**
```json
{
  "modules": [
    {
      "id": "...",
      "title": "...",
      "trainings": [
        {
          "id": "...",
          "content": [...],
          "questions": [...]
        }
      ]
    }
  ],
  "stats": {
    "total_modules": 6,
    "total_trainings": 25,
    "total_questions": 80,
    "total_scenarios": 0,
    "export_timestamp": "2026-05-19T10:54:32.429Z"
  }
}
```

**Response Size:** ~3-5 MB  
**Response Time:** <1 second

**Use Cases:**
- Bulk data export for analytics
- Backup/archival
- Migrate content to another system
- Create offline copies

---

## 📦 Response Format

All successful responses follow this structure:

```json
{
  "data": {
    // Response payload varies by endpoint
  },
  "stats": {
    "export_timestamp": "ISO 8601 timestamp"
    // Additional stats per endpoint
  }
}
```

### Common Fields Across Responses

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Unique identifier for any resource |
| `title` | string | Human-readable name |
| `order_number` | integer | Display/processing order |
| `created_at` | timestamp | When resource was created |

### Data Types

- **UUID:** Standard UUID v4 format (e.g., `550e8400-e29b-41d4-a716-446655440000`)
- **Timestamp:** ISO 8601 format (e.g., `2026-05-19T10:54:32.429Z`)
- **Boolean:** `true` or `false`

---

## ⚠️ Error Handling

### HTTP Status Codes

| Status | Meaning | Example |
|--------|---------|---------|
| 200 | Success | Request processed successfully |
| 400 | Bad Request | Invalid query parameters |
| 404 | Not Found | Module ID doesn't exist |
| 500 | Server Error | Database connection issue |

### Error Response Format

```json
{
  "detail": "Human-readable error message"
}
```

### Common Errors

**404 - Module Not Found**
```json
{
  "detail": "Module not found"
}
```
**Solution:** Verify module ID is correct. Get list from `/api/export/modules` first.

**500 - Database Connection Error**
```json
{
  "detail": "Database connection failed"
}
```
**Solution:** Service may be temporarily down. Check health endpoint and retry after 30 seconds.

---

## 💡 Examples

### Example 1: List All Modules for Display

**Goal:** Show module list in a learning platform frontend.

**Request:**
```bash
curl https://coaching-content-api-production.up.railway.app/api/export/modules
```

**Response Processing (JavaScript):**
```javascript
const modules = response.data.modules
  .sort((a, b) => a.order_number - b.order_number);

modules.forEach(module => {
  console.log(`${module.order_number}. ${module.title}`);
  console.log(`   Required for: ${module.persona_required.join(", ")}`);
  if (!module.is_mandatory) {
    console.log("   (Optional)");
  }
});
```

**Output:**
```
1. Module 1: Foundation
   Required for: A, B, C, D
2. Module 2: Advanced Techniques
   Required for: B, C
   (Optional)
```

---

### Example 2: Extract Quiz Questions

**Goal:** Build a quiz system using exported questions.

**Request:**
```bash
curl https://coaching-content-api-production.up.railway.app/api/export/modules/550e8400-e29b-41d4-a716-446655440000
```

**Response Processing (Python):**
```python
import json

response = requests.get(url).json()
module = response

for training in module["trainings"]:
    for question in training.get("questions", []):
        if question["question_type"] == "mcq":
            print(f"Q: {question['question_text']}")
            for option in question["options"]:
                marker = "✓" if option["is_correct"] else " "
                print(f"  [{marker}] {option['option_text']}")
```

---

### Example 3: Backup All Content

**Goal:** Create a local backup of all content.

**Request:**
```bash
curl https://coaching-content-api-production.up.railway.app/api/export/complete > coaching_backup_$(date +%Y%m%d).json
```

**Verification:**
```bash
# Check file size
ls -lh coaching_backup_*.json

# Verify JSON is valid
jq . coaching_backup_*.json | head -20
```

---

### Example 4: Filter Content by Persona

**Goal:** Show only content applicable to specific user persona.

**Request & Processing (Python):**
```python
response = requests.get(f"{BASE_URL}/api/export/modules").json()

# Filter modules for persona "B"
persona = "B"
applicable_modules = [
    m for m in response["modules"]
    if persona in m["persona_required"]
]

print(f"Modules for persona {persona}:")
for module in applicable_modules:
    print(f"  - {module['title']}")
```

---

## 🚦 Rate Limiting

**Current Limits:**
- 1,000 requests per hour per IP
- 100 requests per minute (burst limit)

**Headers in Response:**
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1634567890
```

**If Rate Limited (429):**
```json
{
  "detail": "Rate limit exceeded. Try again after 60 seconds."
}
```

---

## 🔧 Troubleshooting

### Service Not Responding

**Symptom:** Connection timeout or "Service unavailable"

**Solution:**
1. Check health endpoint: `curl https://coaching-content-api-production.up.railway.app/api/export/health`
2. If health check fails, service may be down. Check Railway dashboard.
3. Contact platform team: #coaching-api-support Slack channel

### Invalid Module ID

**Symptom:** 404 Not Found for module ID

**Solution:**
1. Get current module list: `curl .../api/export/modules`
2. Copy the exact `id` from the response
3. Use that ID in your request

### Large Response (Complete Export)

**Symptom:** Request times out or response very slow

**Solution:**
1. The complete export is ~3-5 MB and should complete in <1 second
2. If slow, check your network connection
3. Try requesting individual modules instead

### JSON Parse Error

**Symptom:** "Invalid JSON" when parsing response

**Solution:**
1. Verify endpoint is correct
2. Check HTTP status code (should be 200)
3. Pretty-print response: `curl ... | jq .`

---

## 📞 Support

### Slack Channel
`#coaching-api-support` - Ask questions, report issues, get help

### Common Questions

**Q: Can I cache the responses?**  
A: Yes! Responses are stable. Cache for 1 hour and invalidate when module updates happen.

**Q: Can external teams access this?**  
A: Currently internal-only. Contact platform team to add API keys for external access.

**Q: What's the update frequency?**  
A: Content is updated whenever modules change. You can poll `/api/export/health` for timestamp changes.

**Q: Can I get only specific fields?**  
A: Currently all fields are returned. Let us know if you need field filtering.

**Q: Is there pagination for large datasets?**  
A: No pagination yet. Complete export is ~5MB which handles 6 modules. Let us know if you need pagination.

---

## 📚 Related Documentation

- [Setup & Deployment](./DEPLOYMENT.md)
- [Architecture Overview](./ARCHITECTURE.md)
- [Database Schema](./SCHEMA.md)
- [Postman Collection](../postman_collection.json)

---

**Last Updated:** 2026-05-19  
**Maintained By:** Platform Engineering Team  
**Questions?** Slack #coaching-api-support or email api-support@taleemabad.com
