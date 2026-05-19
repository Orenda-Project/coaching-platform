# Integration Guide - Coaching Content Export API

**For teams integrating this API into their systems**

---

## 🎯 Overview

This guide explains how to integrate the Coaching Content Export API into your application or system.

### Typical Integration Patterns

1. **Display in LMS/Platform** - Show modules and content in a learning app
2. **Sync to Analytics** - Extract data for reporting and analysis
3. **Backup/Archival** - Regular data exports for backup
4. **API Gateway** - Expose API to external partners (with auth added)

---

## 📋 Step-by-Step Integration

### Step 1: Choose Your Integration Type

**Type A: Periodic Sync (Daily/Weekly)**
- Export complete data once per day
- Store in your database
- Serve from your system
- Best for: Analytics, backups, static content

**Type B: Real-Time Integration**
- Call API on-demand when users need content
- Cache responses for performance
- Best for: Dynamic content, learning platforms

**Type C: Hybrid**
- Store modules/structure locally
- Fetch content URLs on-demand
- Best for: Performance + freshness

---

### Step 2: Set Up Your Environment

#### Environment Variables (Recommended)
```bash
# .env
COACHING_API_BASE_URL=https://coaching-content-api-production.up.railway.app
COACHING_API_TIMEOUT=30  # seconds
COACHING_API_CACHE_TTL=3600  # 1 hour
```

#### Configuration (Code)
```python
# config.py
class Config:
    COACHING_API_URL = "https://coaching-content-api-production.up.railway.app"
    COACHING_API_TIMEOUT = 30
    CACHE_TTL = 3600  # Cache responses for 1 hour
```

---

### Step 3: Choose Implementation Approach

## 📦 Implementation Examples

### Approach A: Direct API Calls

**Best for:** Small apps, infrequent requests

**Python Example:**
```python
import requests
import json
from datetime import datetime

class CoachingAPI:
    BASE_URL = "https://coaching-content-api-production.up.railway.app"
    
    def get_modules(self):
        """Get all modules"""
        response = requests.get(f"{self.BASE_URL}/api/export/modules")
        response.raise_for_status()
        return response.json()["modules"]
    
    def get_module(self, module_id):
        """Get specific module with content"""
        response = requests.get(f"{self.BASE_URL}/api/export/modules/{module_id}")
        response.raise_for_status()
        return response.json()
    
    def health_check(self):
        """Verify service is running"""
        try:
            response = requests.get(
                f"{self.BASE_URL}/api/export/health",
                timeout=5
            )
            return response.status_code == 200
        except:
            return False

# Usage
api = CoachingAPI()
modules = api.get_modules()
for module in modules:
    print(module["title"])
```

**JavaScript Example:**
```javascript
class CoachingAPI {
  constructor(baseUrl = "https://coaching-content-api-production.up.railway.app") {
    this.baseUrl = baseUrl;
  }

  async getModules() {
    const response = await fetch(`${this.baseUrl}/api/export/modules`);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    return data.modules;
  }

  async getModule(moduleId) {
    const response = await fetch(
      `${this.baseUrl}/api/export/modules/${moduleId}`
    );
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  }

  async healthCheck() {
    try {
      const response = await fetch(`${this.baseUrl}/api/export/health`);
      return response.ok;
    } catch {
      return false;
    }
  }
}

// Usage
const api = new CoachingAPI();
const modules = await api.getModules();
modules.forEach(m => console.log(m.title));
```

---

### Approach B: Cached Integration (Recommended for Performance)

**Best for:** High-traffic apps, frequent requests

**Python Example:**
```python
import requests
import json
import time
from datetime import datetime

class CachedCoachingAPI:
    def __init__(self, cache_ttl=3600):
        self.BASE_URL = "https://coaching-content-api-production.up.railway.app"
        self.cache = {}
        self.cache_ttl = cache_ttl
    
    def _is_cache_valid(self, key):
        """Check if cached data is still fresh"""
        if key not in self.cache:
            return False
        age = time.time() - self.cache[key]["timestamp"]
        return age < self.cache_ttl
    
    def get_modules(self, use_cache=True):
        """Get all modules with optional caching"""
        cache_key = "modules"
        
        if use_cache and self._is_cache_valid(cache_key):
            return self.cache[cache_key]["data"]
        
        response = requests.get(f"{self.BASE_URL}/api/export/modules")
        response.raise_for_status()
        data = response.json()["modules"]
        
        self.cache[cache_key] = {
            "data": data,
            "timestamp": time.time()
        }
        return data
    
    def get_module(self, module_id, use_cache=True):
        """Get specific module with caching"""
        cache_key = f"module_{module_id}"
        
        if use_cache and self._is_cache_valid(cache_key):
            return self.cache[cache_key]["data"]
        
        response = requests.get(
            f"{self.BASE_URL}/api/export/modules/{module_id}"
        )
        response.raise_for_status()
        data = response.json()
        
        self.cache[cache_key] = {
            "data": data,
            "timestamp": time.time()
        }
        return data
    
    def clear_cache(self, key=None):
        """Clear cache for a specific key or all"""
        if key:
            self.cache.pop(key, None)
        else:
            self.cache.clear()

# Usage
api = CachedCoachingAPI(cache_ttl=3600)  # 1 hour cache
modules = api.get_modules()  # Calls API
modules = api.get_modules()  # Uses cache (no API call)
```

**JavaScript Example with LocalStorage:**
```javascript
class CachedCoachingAPI {
  constructor(baseUrl, cacheTTL = 3600000) { // 1 hour in ms
    this.baseUrl = baseUrl;
    this.cacheTTL = cacheTTL;
  }

  async _fetchWithCache(key, url) {
    // Check if cached data exists and is fresh
    const cached = localStorage.getItem(key);
    if (cached) {
      const { data, timestamp } = JSON.parse(cached);
      if (Date.now() - timestamp < this.cacheTTL) {
        return data;
      }
    }

    // Fetch fresh data
    const response = await fetch(url);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();

    // Cache the response
    localStorage.setItem(
      key,
      JSON.stringify({
        data,
        timestamp: Date.now()
      })
    );

    return data;
  }

  async getModules() {
    return this._fetchWithCache(
      "coaching_modules",
      `${this.baseUrl}/api/export/modules`
    );
  }

  async getModule(moduleId) {
    return this._fetchWithCache(
      `coaching_module_${moduleId}`,
      `${this.baseUrl}/api/export/modules/${moduleId}`
    );
  }

  clearCache() {
    localStorage.removeItem("coaching_modules");
    Object.keys(localStorage).forEach(key => {
      if (key.startsWith("coaching_module_")) {
        localStorage.removeItem(key);
      }
    });
  }
}

// Usage
const api = new CachedCoachingAPI(
  "https://coaching-content-api-production.up.railway.app"
);
const modules = await api.getModules();
```

---

### Approach C: Scheduled Sync to Database

**Best for:** Data warehouse, analytics, static exports

**Python Example (Daily Sync):**
```python
import requests
import json
from datetime import datetime
from apscheduler.schedulers.background import BackgroundScheduler

class CoachingContentSync:
    def __init__(self, db_connection):
        self.api_url = "https://coaching-content-api-production.up.railway.app"
        self.db = db_connection
    
    def sync_all_content(self):
        """Fetch all content from API and store in database"""
        try:
            response = requests.get(f"{self.api_url}/api/export/complete")
            response.raise_for_status()
            export_data = response.json()
            
            # Store in database
            self.db.tables.coaching_export.insert({
                "exported_at": datetime.now().isoformat(),
                "data": json.dumps(export_data),
                "stats": json.dumps(export_data["stats"])
            })
            
            print(f"✓ Sync complete: {export_data['stats']['total_modules']} modules")
            return True
        except Exception as e:
            print(f"✗ Sync failed: {e}")
            return False
    
    def schedule_daily_sync(self):
        """Schedule sync to run daily at 2 AM"""
        scheduler = BackgroundScheduler()
        scheduler.add_job(
            self.sync_all_content,
            'cron',
            hour=2,
            minute=0,
            id='coaching_sync'
        )
        scheduler.start()

# Usage
sync = CoachingContentSync(db)
sync.schedule_daily_sync()
```

---

## 🔄 Common Integration Scenarios

### Scenario 1: LMS Integration

**Goal:** Display modules and trainings in your learning platform

**Flow:**
1. User opens learning platform
2. App fetches modules: `GET /api/export/modules`
3. User selects a module
4. App fetches module details: `GET /api/export/modules/{id}`
5. Display trainings and content to user

**Code:**
```python
def display_module_content(user_id, module_id):
    """Show module content to user in LMS"""
    api = CachedCoachingAPI()
    module = api.get_module(module_id)
    
    # Store in user session for persistence
    session['current_module'] = {
        'id': module['id'],
        'title': module['title'],
        'trainings': module['trainings']
    }
    
    return render_template('module.html', module=module)
```

---

### Scenario 2: Analytics Export

**Goal:** Extract data for reporting and analysis

**Code:**
```python
def export_for_analytics():
    """Export all content to analytics platform"""
    api = CoachingAPI()
    
    response = requests.get(
        f"{api.BASE_URL}/api/export/complete"
    )
    export_data = response.json()
    
    # Transform for analytics
    analytics_data = {
        'module_count': export_data['stats']['total_modules'],
        'training_count': export_data['stats']['total_trainings'],
        'question_count': export_data['stats']['total_questions'],
        'export_date': datetime.now().isoformat(),
        'modules': [
            {
                'id': m['id'],
                'title': m['title'],
                'training_count': len(m['trainings'])
            }
            for m in export_data['modules']
        ]
    }
    
    # Send to analytics platform
    analytics.track('content_export', analytics_data)
```

---

### Scenario 3: Backup & Recovery

**Goal:** Regular backups for disaster recovery

**Script:**
```bash
#!/bin/bash
# backup_coaching_content.sh

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/coaching_content_${TIMESTAMP}.json"

mkdir -p $BACKUP_DIR

echo "Backing up coaching content..."
curl -s https://coaching-content-api-production.up.railway.app/api/export/complete \
  | jq . > $BACKUP_FILE

if [ -f $BACKUP_FILE ]; then
  SIZE=$(ls -lh $BACKUP_FILE | awk '{print $5}')
  echo "✓ Backup complete: $BACKUP_FILE ($SIZE)"
  
  # Keep only last 30 days of backups
  find $BACKUP_DIR -name "coaching_content_*.json" -mtime +30 -delete
else
  echo "✗ Backup failed"
  exit 1
fi
```

---

## ⚡ Performance Tips

1. **Cache aggressively** - Content doesn't change frequently
2. **Use pagination** - For large result sets (future feature)
3. **Batch requests** - Get complete export instead of multiple calls
4. **Monitor response time** - Track API performance in your logs
5. **Handle timeouts gracefully** - Fallback to cached data if API is slow

---

## 🔐 Error Handling

**Always handle errors gracefully:**

```python
def get_module_safe(module_id):
    """Safely fetch module with error handling"""
    try:
        api = CoachingAPI()
        return api.get_module(module_id)
    except requests.Timeout:
        print("API request timed out")
        # Use cached data or show error to user
        return None
    except requests.HTTPError as e:
        if e.response.status_code == 404:
            print("Module not found")
        else:
            print(f"API error: {e}")
        return None
    except Exception as e:
        print(f"Unexpected error: {e}")
        return None
```

---

## 📊 Monitoring Integration

**Track API health in your monitoring:**

```python
def monitor_coaching_api():
    """Check API health and log metrics"""
    api = CoachingAPI()
    
    if api.health_check():
        # Log successful health check
        metrics.gauge('coaching_api.health', 1)
    else:
        # Alert if API is down
        metrics.gauge('coaching_api.health', 0)
        alerts.send('Coaching API is down')
```

---

## 📞 Support During Integration

- **Slack:** #coaching-api-support
- **Email:** api-support@taleemabad.com
- **Documentation:** See [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)

---

**Ready to integrate?** Start with the direct API calls approach, then optimize with caching! 🚀
