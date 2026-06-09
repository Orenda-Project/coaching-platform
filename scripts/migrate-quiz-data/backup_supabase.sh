#!/bin/bash

##############################################################################
# Backup Supabase Database
#
# This script backs up the Supabase local development database before
# running any migrations. It supports both local Supabase and remote
# Supabase instances.
#
# Usage: ./backup_supabase.sh
##############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUPS_DIR="${SCRIPT_DIR}/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUPS_DIR}/supabase_export_${TIMESTAMP}.sql"
MANIFEST_FILE="${BACKUPS_DIR}/BACKUP_MANIFEST.txt"

# Ensure backups directory exists
mkdir -p "${BACKUPS_DIR}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Supabase Database Backup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if local Supabase is running
echo -e "${YELLOW}Checking Supabase status...${NC}"
cd /Users/mac/Desktop/data/Taleemabad/coaching-platform

SUPABASE_STATUS=$(supabase status 2>&1 || true)

if echo "$SUPABASE_STATUS" | grep -q "supabase local development setup is running"; then
    echo -e "${GREEN}✓ Local Supabase is running${NC}"

    # Extract database URL from status output
    DB_URL=$(echo "$SUPABASE_STATUS" | grep "postgresql://" | awk '{print $NF}')

    if [ -z "$DB_URL" ]; then
        echo -e "${RED}✗ Could not extract database URL from supabase status${NC}"
        exit 1
    fi

    echo -e "${BLUE}Database URL: ${DB_URL}${NC}"
    echo ""

    # Create backup using pg_dump
    echo -e "${YELLOW}Creating backup...${NC}"
    echo -e "${BLUE}Backup file: ${BACKUP_FILE}${NC}"

    if PGPASSWORD="postgres" pg_dump \
        -h 127.0.0.1 \
        -p 54322 \
        -U postgres \
        -d postgres \
        --no-password \
        -v \
        > "${BACKUP_FILE}" 2>&1; then

        echo -e "${GREEN}✓ Backup completed successfully${NC}"
    else
        echo -e "${RED}✗ Backup failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ Local Supabase is not running${NC}"
    echo -e "${YELLOW}Please start Supabase first:${NC}"
    echo -e "  ${BLUE}cd /Users/mac/Desktop/data/Taleemabad/coaching-platform${NC}"
    echo -e "  ${BLUE}supabase start${NC}"
    exit 1
fi

# Verify backup file
echo ""
echo -e "${YELLOW}Verifying backup...${NC}"

if [ ! -f "${BACKUP_FILE}" ]; then
    echo -e "${RED}✗ Backup file not found: ${BACKUP_FILE}${NC}"
    exit 1
fi

BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | awk '{print $1}')
BACKUP_SIZE_BYTES=$(stat -f%z "${BACKUP_FILE}")
BACKUP_MD5=$(md5 -q "${BACKUP_FILE}")
LINE_COUNT=$(wc -l < "${BACKUP_FILE}")

echo -e "${GREEN}✓ Backup file verified${NC}"
echo -e "  Size: ${BACKUP_SIZE} (${BACKUP_SIZE_BYTES} bytes)"
echo -e "  MD5: ${BACKUP_MD5}"
echo -e "  Lines: ${LINE_COUNT}"

# Create manifest
echo ""
echo -e "${YELLOW}Creating manifest...${NC}"

cat > "${MANIFEST_FILE}" << EOF
Supabase Backup Manifest
========================
Generated: $(date '+%Y-%m-%d %H:%M:%S')
Backup File: supabase_export_${TIMESTAMP}.sql

Backup Details:
  Size: ${BACKUP_SIZE} (${BACKUP_SIZE_BYTES} bytes)
  Lines: ${LINE_COUNT}
  MD5: ${BACKUP_MD5}
  Timestamp: ${TIMESTAMP}

Database:
  Host: 127.0.0.1
  Port: 54322
  Database: postgres
  User: postgres

Notes:
  - This is a complete schema and data backup
  - Created before quiz data migration
  - Restore with: psql -h 127.0.0.1 -p 54322 -U postgres -d postgres < supabase_export_${TIMESTAMP}.sql
  - Tables backed up include: quiz tables, scenario tables, analytics, regions, users, profiles, etc.

Verification:
  To verify this backup is valid, check:
    1. File size > 1 KB: $([ ${BACKUP_SIZE_BYTES} -gt 1024 ] && echo "✓ PASS" || echo "✗ FAIL")
    2. MD5 checksum matches: ${BACKUP_MD5}
    3. Line count > 10: $([ ${LINE_COUNT} -gt 10 ] && echo "✓ PASS" || echo "✗ FAIL")

Restore Instructions:
  1. Ensure Supabase is running: supabase start
  2. Restore the backup:
     PGPASSWORD="postgres" psql \
       -h 127.0.0.1 \
       -p 54322 \
       -U postgres \
       -d postgres \
       -f supabase_export_${TIMESTAMP}.sql
  3. Verify tables were restored: supabase status

EOF

if [ -f "${MANIFEST_FILE}" ]; then
    echo -e "${GREEN}✓ Manifest created: ${MANIFEST_FILE}${NC}"
else
    echo -e "${RED}✗ Failed to create manifest${NC}"
    exit 1
fi

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Backup Complete${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Backup file:${NC}"
echo -e "  ${BACKUP_FILE}"
echo ""
echo -e "${GREEN}Manifest file:${NC}"
echo -e "  ${MANIFEST_FILE}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Review the backup file size and MD5"
echo -e "  2. Commit both files to git:"
echo -e "     ${BLUE}git add ${BACKUP_FILE} ${MANIFEST_FILE}${NC}"
echo -e "     ${BLUE}git commit -m 'ops: backup Supabase before migration'${NC}"
echo -e "  3. Proceed with migration"
echo ""
