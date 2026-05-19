#!/bin/bash
source venv/bin/activate
source .env
python scripts/migrate_content.py "$@"
