#!/usr/bin/env python3
"""Test script to verify schema creation without running migrations."""
import os
import sys
from app.config import settings
from app.models.training import Base
from sqlalchemy import text

print("Database Configuration Test")
print("=" * 50)
print(f"Database URL (masked): postgresql://***@{settings.database_url.split('@')[1] if '@' in settings.database_url else 'unknown'}")
print(f"Models to create: 7 tables")
print("- modules")
print("- trainings")
print("- training_content")
print("- questions")
print("- options")
print("- scenarios")
print("- scenario_options")
print()
print("Schema Definition Preview:")
print("=" * 50)

# Print table names from metadata
for table_name in sorted(Base.metadata.tables.keys()):
    table = Base.metadata.tables[table_name]
    print(f"\nTable: {table_name}")
    for column in table.columns:
        print(f"  - {column.name}: {column.type}")

print("\n" + "=" * 50)
print("To create schema in Railway PostgreSQL:")
print("1. Ensure DATABASE_URL is set to your Railway public URL")
print("2. Run: alembic upgrade head")
print("3. Verify: psql $DATABASE_URL -c '\\dt'")
