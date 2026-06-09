# Backup Strategy for Quiz Data Migration

## Overview

Before running the quiz data migration, comprehensive backups of both Supabase and PostgreSQL databases are created. This document explains the backup strategy, scripts, and recovery procedures.

## Backup Scripts

### 1. `backup_supabase.sh` - Supabase Export

**Purpose:** Back up the local Supabase development database before migration.

**What it does:**
- Checks if local Supabase is running (`supabase start`)
- Uses `pg_dump` to export the entire Supabase database
- Creates a timestamped SQL file: `supabase_export_<timestamp>.sql`
- Generates a manifest with size, line count, and MD5 checksum

**Usage:**
```bash
./backup_supabase.sh
```

**Requirements:**
- Docker Desktop running
- Supabase CLI installed
- Local Supabase started: `supabase start`

**Output:**
- `backups/supabase_export_<timestamp>.sql` - Complete database dump
- `backups/BACKUP_MANIFEST.txt` - Metadata and recovery instructions

---

### 2. `backup_postgres.sh` - PostgreSQL Backup (Local + Railway)

**Purpose:** Back up PostgreSQL from both local development and Railway production.

**What it does:**
- **Local PostgreSQL:** 
  - Checks if PostgreSQL is running on localhost:5432
  - Creates a dump of the `coaching_platform` database using `pg_dump`
  - Saves to: `postgres_local_<timestamp>.sql`
  - (Currently skipped if PostgreSQL is not running)

- **Railway PostgreSQL:**
  - Checks if Railway CLI is installed and authenticated
  - Creates a reference file for manual snapshot creation
  - Saves to: `railway_snapshot_<timestamp>.txt`
  - Provides instructions for creating snapshots in Railway dashboard

**Usage:**
```bash
# Backup both local and Railway
./backup_postgres.sh

# Backup only local PostgreSQL
./backup_postgres.sh --local-only

# Backup only Railway (reference)
./backup_postgres.sh --railway-only
```

**Requirements:**
- PostgreSQL tools (`pg_dump`, `psql`) for local backup
- Railway CLI installed and authenticated for Railway reference
- Local PostgreSQL running (optional) for local backup

**Output:**
- `backups/postgres_local_<timestamp>.sql` - Local database dump (if available)
- `backups/railway_snapshot_<timestamp>.txt` - Railway backup reference
- `backups/BACKUP_MANIFEST_POSTGRES.txt` - Complete manifest with recovery instructions

---

### 3. `backup_railway_db.sh` - Railway Direct Dump (Optional)

**Purpose:** Alternative method to dump the Railway production database directly via CLI.

**What it does:**
- Checks Railway CLI authentication and project linking
- Uses `railway run pg_dump` to dump the production database
- Saves to: `railway_postgres_dump_<timestamp>.sql`
- Useful as a complete backup of production (vs. snapshot reference)

**Usage:**
```bash
./backup_railway_db.sh
```

**Requirements:**
- Railway CLI installed and authenticated
- Current directory linked to coaching-platform project: `railway link`
- PostgreSQL service running in Railway

**Output:**
- `backups/railway_postgres_dump_<timestamp>.sql` - Production database dump

---

## Backup Files

### Current Backups

```
backups/
├── BACKUP_MANIFEST.txt                    # Supabase manifest
├── BACKUP_MANIFEST_POSTGRES.txt           # PostgreSQL manifest
├── supabase_export_20260609_145036.sql    # Supabase dump (~571 KB)
├── railway_snapshot_20260609_145206.txt   # Railway snapshot reference
└── (optional) railway_postgres_dump_<timestamp>.sql
```

### File Specifications

| File | Size | Type | Purpose |
|------|------|------|---------|
| `supabase_export_*.sql` | ~500 KB+ | SQL dump | Complete Supabase schema + data |
| `postgres_local_*.sql` | ~100 KB+ | SQL dump | Local PostgreSQL backup (when running) |
| `railway_postgres_dump_*.sql` | ~100 KB+ | SQL dump | Direct Railway database dump |
| `railway_snapshot_*.txt` | ~1 KB | Reference | Instructions for manual snapshots |
| `BACKUP_MANIFEST_*.txt` | ~2 KB | Metadata | Recovery instructions + checksums |

---

## Recovery Procedures

### Supabase Recovery

**If Supabase data is corrupted:**

1. Ensure Supabase is running:
   ```bash
   cd /Users/mac/Desktop/data/Taleemabad/coaching-platform
   supabase start
   ```

2. Get the database URL from status:
   ```bash
   supabase status
   ```

3. Restore the backup:
   ```bash
   PGPASSWORD="postgres" psql \
     -h 127.0.0.1 \
     -p 54322 \
     -U postgres \
     -d postgres \
     -f backups/supabase_export_20260609_145036.sql
   ```

4. Verify restoration:
   ```bash
   supabase status
   ```

---

### Local PostgreSQL Recovery

**If local PostgreSQL data is lost:**

1. Ensure PostgreSQL is running:
   ```bash
   # macOS with Homebrew
   brew services start postgresql
   
   # Or manually start
   pg_ctl -D /usr/local/var/postgres start
   ```

2. Restore the backup:
   ```bash
   PGPASSWORD="postgres" psql \
     -h localhost \
     -p 5432 \
     -U postgres \
     -d postgres \
     -f backups/postgres_local_20260609_145206.sql
   ```

3. Verify restoration:
   ```bash
   PGPASSWORD="postgres" psql \
     -h localhost \
     -p 5432 \
     -U postgres \
     -d coaching_platform \
     -c "SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema='public';"
   ```

---

### Railway PostgreSQL Recovery

#### Option 1: Using Manual Snapshot (Recommended)

1. Go to [https://railway.app](https://railway.app)
2. Select the **coaching-platform** project
3. Select the **PostgreSQL** service
4. Click **Metrics & Backups** tab
5. Find the snapshot created at **2026-06-09 14:52:06** (or desired snapshot)
6. Click **Restore from Snapshot**
7. Confirm restoration (⚠️ **This causes downtime**)
8. Wait for restoration to complete

#### Option 2: Using Direct Dump (If Created)

1. Ensure Railway CLI is authenticated:
   ```bash
   railway login
   ```

2. Link to the project:
   ```bash
   railway link
   ```

3. Restore the dump:
   ```bash
   railway run psql -d coaching_platform < backups/railway_postgres_dump_20260609_<timestamp>.sql
   ```

4. Verify restoration:
   ```bash
   railway run psql -d coaching_platform -c "SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema='public';"
   ```

---

## Verification Checklist

### After Each Backup

- [ ] Backup file exists: `ls -lh backups/*.sql`
- [ ] File size > 100 KB (for SQL dumps): `du -h backups/*.sql`
- [ ] Manifest created: `cat backups/BACKUP_MANIFEST_*.txt`
- [ ] Files committed to git: `git log --oneline | head -5`

### Before Migration

- [ ] Supabase backup created and verified
- [ ] PostgreSQL backup created (local) or reference created (Railway)
- [ ] Manifests document all backups
- [ ] All backup files committed to git
- [ ] `.gitignore` allows backup commits (check for SQL exclusions)

### After Recovery (Testing)

- [ ] Database restored without errors
- [ ] All tables present: `\dt` in psql
- [ ] Sample data intact: `SELECT COUNT(*) FROM <table>;`
- [ ] No corruption errors in logs
- [ ] Application can connect to restored database

---

## Migration Workflow

### Pre-Migration Checklist

```bash
# 1. Create Supabase backup
./backup_supabase.sh

# 2. Create PostgreSQL backup
./backup_postgres.sh

# 3. (Optional) Create Railway dump
./backup_railway_db.sh

# 4. Verify all backups
ls -lh backups/
cat backups/BACKUP_MANIFEST_*.txt

# 5. Commit backups
git add backups/
git commit -m "ops: backup databases before quiz data migration"

# 6. Proceed with migration
python fetch_docs.py
python validation_against_supabase.py
# ... other migration scripts
```

---

## Important Notes

⚠️ **DO NOT:**
- Commit database connection strings (even though these are local/reference)
- Share backup files containing sensitive data
- Delete backups until migration is verified and tested

✅ **DO:**
- Test recovery procedures in a non-production environment first
- Keep backups in a secure location
- Consider encrypted storage for production backups
- Document the timestamp of each backup for reference
- Review manifests for recovery instructions specific to each backup

---

## Troubleshooting

### Supabase Backup Fails

**Error:** "Local Supabase is not running"
- **Solution:** Start Supabase first: `supabase start`

**Error:** "Could not extract database URL"
- **Solution:** Check Supabase status: `supabase status`

### PostgreSQL Backup Fails

**Error:** "PostgreSQL is not running on localhost:5432"
- **Solution:** Start PostgreSQL or use Railway backup instead

**Error:** "Could not connect to database 'coaching_platform'"
- **Solution:** Verify database exists: `psql -l`

### Railway Backup Fails

**Error:** "Railway is not authenticated"
- **Solution:** Authenticate: `railway login`

**Error:** "Project is not linked"
- **Solution:** Link the project: `railway link`

---

## Support

For issues with backups:

1. Check the specific script's manifest file
2. Review recovery instructions in BACKUP_MANIFEST_*.txt
3. Verify tool availability: `supabase --version`, `railway --version`, `pg_dump --version`
4. Check git status for committed backups: `git log --name-status | grep backups`

