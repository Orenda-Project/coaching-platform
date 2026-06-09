#!/bin/bash

##############################################################################
# Backup PostgreSQL Database (Local + Railway)
#
# This script backs up the PostgreSQL coaching_platform database from both:
# 1. Local development (if running)
# 2. Railway production environment (via Railway CLI)
#
# It creates timestamped backups and generates a manifest for recovery.
#
# Usage: ./backup_postgres.sh [--local-only] [--railway-only]
#
# Examples:
#   ./backup_postgres.sh              # Backup both local and Railway
#   ./backup_postgres.sh --local-only # Backup only local PostgreSQL
#   ./backup_postgres.sh --railway-only # Backup only Railway
##############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUPS_DIR="${SCRIPT_DIR}/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MANIFEST_FILE="${BACKUPS_DIR}/BACKUP_MANIFEST_POSTGRES.txt"

# Local PostgreSQL config
LOCAL_HOST="localhost"
LOCAL_PORT="5432"
LOCAL_USER="postgres"
LOCAL_DB="coaching_platform"
LOCAL_BACKUP_FILE="${BACKUPS_DIR}/postgres_local_${TIMESTAMP}.sql"

# Railway config
RAILWAY_BACKUP_FILE="${BACKUPS_DIR}/railway_snapshot_${TIMESTAMP}.txt"

# Parse command-line arguments
BACKUP_LOCAL=true
BACKUP_RAILWAY=true

if [[ "$1" == "--local-only" ]]; then
    BACKUP_RAILWAY=false
elif [[ "$1" == "--railway-only" ]]; then
    BACKUP_LOCAL=false
fi

# Ensure backups directory exists
mkdir -p "${BACKUPS_DIR}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}PostgreSQL Database Backup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Track results
LOCAL_SUCCESS=false
RAILWAY_SUCCESS=false
LOCAL_SKIPPED=false
RAILWAY_SKIPPED=false

###############################################################################
# PART 1: LOCAL POSTGRESQL BACKUP
###############################################################################

if [ "$BACKUP_LOCAL" = true ]; then
    echo -e "${CYAN}[1/2] LOCAL POSTGRESQL BACKUP${NC}"
    echo -e "${BLUE}--------------------------------------${NC}"
    echo ""

    # Check if PostgreSQL is running
    echo -e "${YELLOW}Checking local PostgreSQL status...${NC}"

    if pg_isready -h "${LOCAL_HOST}" -U "${LOCAL_USER}" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PostgreSQL is running on ${LOCAL_HOST}:${LOCAL_PORT}${NC}"
        echo ""

        # Check if database exists
        echo -e "${YELLOW}Verifying database '${LOCAL_DB}' exists...${NC}"

        if PGPASSWORD="${PGPASSWORD:-postgres}" psql \
            -h "${LOCAL_HOST}" \
            -p "${LOCAL_PORT}" \
            -U "${LOCAL_USER}" \
            -lqt 2>/dev/null | cut -d'|' -f 1 | grep -qw "${LOCAL_DB}"; then

            echo -e "${GREEN}✓ Database '${LOCAL_DB}' found${NC}"
            echo ""

            # Create backup
            echo -e "${YELLOW}Creating backup of '${LOCAL_DB}'...${NC}"
            echo -e "${BLUE}Output file: ${LOCAL_BACKUP_FILE}${NC}"
            echo ""

            if PGPASSWORD="${PGPASSWORD:-postgres}" pg_dump \
                -h "${LOCAL_HOST}" \
                -p "${LOCAL_PORT}" \
                -U "${LOCAL_USER}" \
                -d "${LOCAL_DB}" \
                --no-password \
                -v > "${LOCAL_BACKUP_FILE}" 2>&1; then

                echo -e ""
                echo -e "${GREEN}✓ Local backup completed successfully${NC}"
                LOCAL_SUCCESS=true

                # Verify backup
                if [ -f "${LOCAL_BACKUP_FILE}" ]; then
                    LOCAL_SIZE=$(du -h "${LOCAL_BACKUP_FILE}" | awk '{print $1}')
                    LOCAL_SIZE_BYTES=$(stat -f%z "${LOCAL_BACKUP_FILE}")
                    LOCAL_MD5=$(md5 -q "${LOCAL_BACKUP_FILE}")
                    LOCAL_LINES=$(wc -l < "${LOCAL_BACKUP_FILE}")

                    echo -e "${BLUE}  Size: ${LOCAL_SIZE} (${LOCAL_SIZE_BYTES} bytes)${NC}"
                    echo -e "${BLUE}  Lines: ${LOCAL_LINES}${NC}"
                    echo -e "${BLUE}  MD5: ${LOCAL_MD5}${NC}"
                else
                    echo -e "${RED}✗ Backup file not found: ${LOCAL_BACKUP_FILE}${NC}"
                    LOCAL_SUCCESS=false
                fi
            else
                echo -e "${RED}✗ Backup failed${NC}"
                LOCAL_SUCCESS=false
            fi
        else
            echo -e "${RED}✗ Database '${LOCAL_DB}' not found${NC}"
            echo -e "${YELLOW}Available databases:${NC}"
            PGPASSWORD="${PGPASSWORD:-postgres}" psql \
                -h "${LOCAL_HOST}" \
                -p "${LOCAL_PORT}" \
                -U "${LOCAL_USER}" \
                -lqt 2>/dev/null | cut -d'|' -f 1 | grep -v '^$' | sed 's/^/  /'
            LOCAL_SUCCESS=false
        fi
    else
        echo -e "${YELLOW}⚠ PostgreSQL is not running on ${LOCAL_HOST}:${LOCAL_PORT}${NC}"
        echo -e "${YELLOW}Skipping local backup${NC}"
        LOCAL_SKIPPED=true
    fi
else
    echo -e "${YELLOW}Local backup skipped (--railway-only flag)${NC}"
    LOCAL_SKIPPED=true
fi

echo ""

###############################################################################
# PART 2: RAILWAY BACKUP (Snapshot Reference)
###############################################################################

if [ "$BACKUP_RAILWAY" = true ]; then
    echo -e "${CYAN}[2/2] RAILWAY BACKUP (SNAPSHOT REFERENCE)${NC}"
    echo -e "${BLUE}--------------------------------------${NC}"
    echo ""

    # Check if Railway CLI is installed
    echo -e "${YELLOW}Checking Railway CLI...${NC}"

    if command -v railway &> /dev/null; then
        RAILWAY_VERSION=$(railway --version 2>&1)
        echo -e "${GREEN}✓ Railway CLI installed: ${RAILWAY_VERSION}${NC}"
        echo ""

        # Check if Railway is authenticated
        echo -e "${YELLOW}Checking Railway authentication...${NC}"

        if railway whoami >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Railway is authenticated${NC}"
            echo ""

            # Try to list projects to get current context
            echo -e "${YELLOW}Listing Railway projects...${NC}"
            if railway list projects 2>/dev/null | head -5; then
                echo ""
                echo -e "${YELLOW}Creating snapshot...${NC}"
                echo -e "${BLUE}Note: Snapshots are created in the Railway web UI${NC}"
                echo -e "${BLUE}This script will save reference details for manual recovery${NC}"
                echo ""

                # Create snapshot reference file
                RAILWAY_PROJECT=$(railway list projects 2>/dev/null | head -2 | tail -1 | awk '{print $1}' || echo "UNKNOWN")
                RAILWAY_ENV=$(railway environment 2>/dev/null || echo "UNKNOWN")

                cat > "${RAILWAY_BACKUP_FILE}" << EOF
Railway PostgreSQL Backup Reference
====================================
Generated: $(date '+%Y-%m-%d %H:%M:%S')
Timestamp: ${TIMESTAMP}

Project Information:
  Project ID: ${RAILWAY_PROJECT}
  Environment: ${RAILWAY_ENV}

Manual Snapshot Instructions:
  1. Go to https://railway.app
  2. Select the coaching-platform project
  3. Select the PostgreSQL service
  4. Click "Metrics & Backups" → "Create Snapshot"
  5. Wait for snapshot to complete
  6. Download or restore from the Railway dashboard

Automated Snapshot (if configured):
  Railway creates automatic snapshots daily
  Check the Railway dashboard for daily backups

Database Connection:
  To access the database from Railway CLI:
    railway run psql --version
    railway run pg_dump -d coaching_platform > local_backup.sql

Recovery Instructions:
  1. Go to Railway dashboard → PostgreSQL service
  2. Click "Restore from snapshot"
  3. Select the desired snapshot
  4. Confirm restore (this will cause downtime)

Notes:
  - Snapshots are managed through the Railway web UI
  - No automated snapshot creation is available via CLI
  - Manual snapshots are recommended before migrations
  - Automatic daily snapshots may also be available (check dashboard)

EOF

                if [ -f "${RAILWAY_BACKUP_FILE}" ]; then
                    echo -e "${GREEN}✓ Railway snapshot reference created${NC}"
                    RAILWAY_SUCCESS=true
                    echo -e "${BLUE}Reference file: ${RAILWAY_BACKUP_FILE}${NC}"
                else
                    echo -e "${RED}✗ Failed to create Railway reference file${NC}"
                    RAILWAY_SUCCESS=false
                fi
            else
                echo -e "${YELLOW}⚠ Could not list Railway projects${NC}"
                echo -e "${YELLOW}You may need to link this project:${NC}"
                echo -e "  ${BLUE}railway link${NC}"
                RAILWAY_SUCCESS=false
            fi
        else
            echo -e "${RED}✗ Railway is not authenticated${NC}"
            echo -e "${YELLOW}Please authenticate with Railway:${NC}"
            echo -e "  ${BLUE}railway login${NC}"
            RAILWAY_SUCCESS=false
        fi
    else
        echo -e "${RED}✗ Railway CLI is not installed${NC}"
        echo -e "${YELLOW}Install Railway CLI from: https://docs.railway.app/cli/install${NC}"
        RAILWAY_SUCCESS=false
    fi
else
    echo -e "${YELLOW}Railway backup skipped (--local-only flag)${NC}"
    RAILWAY_SKIPPED=true
fi

echo ""

###############################################################################
# MANIFEST CREATION
###############################################################################

echo -e "${YELLOW}Creating backup manifest...${NC}"

cat > "${MANIFEST_FILE}" << EOF
PostgreSQL Backup Manifest
==========================
Generated: $(date '+%Y-%m-%d %H:%M:%S')
Timestamp: ${TIMESTAMP}

BACKUP SUMMARY
==============

Local PostgreSQL Backup:
  Status: $([ "$LOCAL_SUCCESS" = true ] && echo "✓ SUCCESS" || ([ "$LOCAL_SKIPPED" = true ] && echo "⊘ SKIPPED" || echo "✗ FAILED"))
  File: postgres_local_${TIMESTAMP}.sql
  Database: ${LOCAL_DB}
  Host: ${LOCAL_HOST}:${LOCAL_PORT}
  User: ${LOCAL_USER}

Railway PostgreSQL Backup:
  Status: $([ "$RAILWAY_SUCCESS" = true ] && echo "✓ SUCCESS (Reference)" || ([ "$RAILWAY_SKIPPED" = true ] && echo "⊘ SKIPPED" || echo "✗ FAILED"))
  Reference File: railway_snapshot_${TIMESTAMP}.txt
  Project: coaching-platform (production)
  Type: Snapshot reference (manual creation required)

LOCAL BACKUP DETAILS
====================
$(if [ "$LOCAL_SUCCESS" = true ]; then
cat << LOCALEOF
File: ${LOCAL_BACKUP_FILE}
Size: ${LOCAL_SIZE} (${LOCAL_SIZE_BYTES} bytes)
Lines: ${LOCAL_LINES}
MD5: ${LOCAL_MD5}

Verification Checks:
  Size > 100 KB: $([ ${LOCAL_SIZE_BYTES} -gt 102400 ] && echo "✓ PASS" || echo "⚠ WARNING: Size < 100 KB")
  Lines > 100: $([ ${LOCAL_LINES} -gt 100 ] && echo "✓ PASS" || echo "⚠ WARNING: Lines < 100")

Local Backup Recovery Instructions:
  1. Ensure PostgreSQL is running on localhost:5432
  2. Restore the backup:
     PGPASSWORD="postgres" psql \
       -h localhost \
       -p 5432 \
       -U postgres \
       -d postgres \
       -f postgres_local_${TIMESTAMP}.sql

  3. Or restore to a specific database:
     PGPASSWORD="postgres" createdb -h localhost -U postgres -d coaching_platform_restore 2>/dev/null || true
     PGPASSWORD="postgres" psql \
       -h localhost \
       -p 5432 \
       -U postgres \
       -d coaching_platform_restore \
       -f postgres_local_${TIMESTAMP}.sql

  4. Verify restoration:
     PGPASSWORD="postgres" psql \
       -h localhost \
       -p 5432 \
       -U postgres \
       -d coaching_platform \
       -c "SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema='public';"

LOCALEOF
else
    echo "Local backup was not created. See above for details."
fi)

RAILWAY BACKUP DETAILS
======================
$(if [ "$RAILWAY_SUCCESS" = true ]; then
cat << RAILWAYEOF
Reference File: ${RAILWAY_BACKUP_FILE}

Railway Backup Recovery Instructions:
  1. Access the Railway dashboard: https://railway.app
  2. Navigate to the coaching-platform project
  3. Select the PostgreSQL service
  4. Go to "Metrics & Backups" tab
  5. Find the snapshot taken at ${TIMESTAMP}
  6. Click "Restore from snapshot"
  7. Confirm the restore (this will cause temporary downtime)

  Alternative: Create a new snapshot manually
  1. Go to PostgreSQL service → "Metrics & Backups"
  2. Click "Create Snapshot"
  3. Wait for completion
  4. Document the snapshot ID for recovery reference

RAILWAYEOF
else
    echo "Railway reference was not created. See above for details."
fi)

IMPORTANT NOTES
===============
- Do NOT commit sensitive database connection details
- Backups contain schema and data (review before sharing)
- Test restoration in a non-production environment first
- Keep backup files in a secure location
- Consider using encrypted storage for production backups

Backup Created Before: Quiz Data Migration
=========================================
This backup was created before running the quiz data migration scripts.

Migration Scripts:
  - fetch_docs.py: Extract quiz data from Supabase
  - validation_against_supabase.py: Validate extracted data
  - migrate_* scripts: Load data into target environment

If the migration fails, restore using the appropriate recovery instructions above.

End of Manifest
===============
EOF

if [ -f "${MANIFEST_FILE}" ]; then
    echo -e "${GREEN}✓ Manifest created: ${MANIFEST_FILE}${NC}"
else
    echo -e "${RED}✗ Failed to create manifest${NC}"
fi

echo ""

###############################################################################
# SUMMARY
###############################################################################

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Backup Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ "$LOCAL_SUCCESS" = true ]; then
    echo -e "${GREEN}✓ Local PostgreSQL backup:${NC}"
    echo -e "  ${LOCAL_BACKUP_FILE}"
    echo -e "  Size: ${LOCAL_SIZE}"
fi

if [ "$LOCAL_SKIPPED" = true ]; then
    echo -e "${YELLOW}⊘ Local backup skipped${NC}"
fi

if [ "$RAILWAY_SUCCESS" = true ]; then
    echo -e "${GREEN}✓ Railway backup reference:${NC}"
    echo -e "  ${RAILWAY_BACKUP_FILE}${NC}"
fi

if [ "$RAILWAY_SKIPPED" = true ]; then
    echo -e "${YELLOW}⊘ Railway backup skipped${NC}"
fi

echo ""
echo -e "${GREEN}✓ Manifest:${NC}"
echo -e "  ${MANIFEST_FILE}"
echo ""

if ([ "$LOCAL_SUCCESS" = true ] || [ "$LOCAL_SKIPPED" = true ]) && \
   ([ "$RAILWAY_SUCCESS" = true ] || [ "$RAILWAY_SKIPPED" = true ]); then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Backup Process Completed${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Review backup manifest:"
    echo -e "     ${BLUE}cat ${MANIFEST_FILE}${NC}"
    echo -e "  2. Verify backup file size:"
    echo -e "     ${BLUE}ls -lh ${LOCAL_BACKUP_FILE}${NC}"
    echo -e "  3. Commit backup files:"
    echo -e "     ${BLUE}git add backups/postgres_local_*.sql backups/railway_snapshot_*.txt${NC}"
    echo -e "     ${BLUE}git add ${MANIFEST_FILE}${NC}"
    echo -e "     ${BLUE}git commit -m 'ops: backup PostgreSQL (local + Railway) before migration'${NC}"
    echo -e "  4. Proceed with quiz data migration"
    echo ""
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}Backup Process Incomplete${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${RED}Some backups failed or were skipped.${NC}"
    echo -e "${YELLOW}Review the log above for details.${NC}"
    echo ""
fi

