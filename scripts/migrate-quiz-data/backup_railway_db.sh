#!/bin/bash

##############################################################################
# Backup PostgreSQL from Railway via CLI
#
# This script dumps the coaching_platform database directly from Railway
# using the railway run command.
#
# Usage: ./backup_railway_db.sh
#
# Requirements:
#   - Railway CLI installed and authenticated
#   - Current directory linked to coaching-platform project
#   - PostgreSQL service running in Railway
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
BACKUP_FILE="${BACKUPS_DIR}/railway_postgres_dump_${TIMESTAMP}.sql"

# Ensure backups directory exists
mkdir -p "${BACKUPS_DIR}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Railway PostgreSQL Backup (CLI Dump)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Railway CLI is installed
echo -e "${YELLOW}Checking Railway CLI...${NC}"

if ! command -v railway &> /dev/null; then
    echo -e "${RED}✗ Railway CLI is not installed${NC}"
    echo -e "${YELLOW}Install from: https://docs.railway.app/cli/install${NC}"
    exit 1
fi

RAILWAY_VERSION=$(railway --version 2>&1)
echo -e "${GREEN}✓ Railway CLI installed: ${RAILWAY_VERSION}${NC}"
echo ""

# Check if Railway is authenticated
echo -e "${YELLOW}Checking Railway authentication...${NC}"

if ! railway whoami >/dev/null 2>&1; then
    echo -e "${RED}✗ Railway is not authenticated${NC}"
    echo -e "${YELLOW}Please authenticate with Railway:${NC}"
    echo -e "  ${BLUE}railway login${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Railway is authenticated${NC}"
echo ""

# Check if project is linked
echo -e "${YELLOW}Checking Railway project link...${NC}"

if ! railway status >/dev/null 2>&1; then
    echo -e "${RED}✗ Current directory is not linked to a Railway project${NC}"
    echo -e "${YELLOW}Link this directory to the coaching-platform project:${NC}"
    echo -e "  ${BLUE}railway link${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Project is linked${NC}"
echo ""

# Create backup using railway run
echo -e "${YELLOW}Creating PostgreSQL dump from Railway...${NC}"
echo -e "${BLUE}Output file: ${BACKUP_FILE}${NC}"
echo ""

if railway run pg_dump -d coaching_platform > "${BACKUP_FILE}" 2>&1; then
    echo ""
    echo -e "${GREEN}✓ Dump completed successfully${NC}"

    # Verify backup
    if [ -f "${BACKUP_FILE}" ]; then
        BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | awk '{print $1}')
        BACKUP_SIZE_BYTES=$(stat -f%z "${BACKUP_FILE}")
        BACKUP_MD5=$(md5 -q "${BACKUP_FILE}")
        BACKUP_LINES=$(wc -l < "${BACKUP_FILE}")

        echo ""
        echo -e "${BLUE}Backup Details:${NC}"
        echo -e "  Size: ${BACKUP_SIZE} (${BACKUP_SIZE_BYTES} bytes)"
        echo -e "  Lines: ${BACKUP_LINES}"
        echo -e "  MD5: ${BACKUP_MD5}"
        echo ""

        if [ ${BACKUP_SIZE_BYTES} -gt 102400 ]; then
            echo -e "${GREEN}✓ Backup size is reasonable (> 100 KB)${NC}"
        else
            echo -e "${YELLOW}⚠ Backup size is small (< 100 KB)${NC}"
            echo -e "${YELLOW}Verify the database contains data${NC}"
        fi
    else
        echo -e "${RED}✗ Backup file not found${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ Dump failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Backup Complete${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Backup file:${NC}"
echo -e "  ${BACKUP_FILE}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Verify the backup file:"
echo -e "     ${BLUE}ls -lh ${BACKUP_FILE}${NC}"
echo -e "  2. Review the backup content (sample):"
echo -e "     ${BLUE}head -20 ${BACKUP_FILE}${NC}"
echo -e "  3. Commit the backup:"
echo -e "     ${BLUE}git add ${BACKUP_FILE}${NC}"
echo -e "     ${BLUE}git commit -m 'ops: backup Railway PostgreSQL database'${NC}"
echo ""

