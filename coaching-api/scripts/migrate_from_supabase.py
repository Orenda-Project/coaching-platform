#!/usr/bin/env python3
"""Full data migration: Supabase → Railway Postgres.

Migrates all application tables from a Supabase project to a Railway Postgres
database using the Supabase REST API (read) and SQLAlchemy (write).

Tables are migrated in FK-dependency order. Uses merge (upsert) so it is safe
to re-run — existing rows are updated, new rows are inserted.

Usage:
    # Set env vars first:
    #   SUPABASE_URL=https://<ref>.supabase.co
    #   SUPABASE_SERVICE_KEY=eyJ...  (service_role key)
    #   DATABASE_URL=postgresql://...  (Railway Postgres)

    python scripts/migrate_from_supabase.py --dry-run    # Preview row counts
    python scripts/migrate_from_supabase.py --commit      # Execute migration
"""
import argparse
import json
import os
import sys
from typing import Any, Dict, List
from pathlib import Path

from dotenv import load_dotenv
from supabase import create_client
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session, sessionmaker

# Add parent directory to path so we can import app modules
sys.path.insert(0, str(Path(__file__).parent.parent))

# Load environment from .env file in coaching-api/
load_dotenv(Path(__file__).parent.parent / ".env")

parser = argparse.ArgumentParser(description="Migrate Supabase data to Railway Postgres")
parser.add_argument("--dry-run", action="store_true", help="Preview without writing")
parser.add_argument("--commit", action="store_true", help="Execute migration")
parser.add_argument("--tables", type=str, default=None, help="Comma-separated tables to migrate")

# ---------------------------------------------------------------------------
# Database setup
# ---------------------------------------------------------------------------
db_url = os.getenv("DATABASE_URL", "")
if not db_url:
    print("ERROR: DATABASE_URL is required")
    sys.exit(1)

# psycopg v3 needs postgresql+psycopg:// prefix
if db_url.startswith("postgresql://"):
    db_url = db_url.replace("postgresql://", "postgresql+psycopg://", 1)

engine = create_engine(db_url)
SessionLocal = sessionmaker(bind=engine)

# ---------------------------------------------------------------------------
# Supabase client
# ---------------------------------------------------------------------------
supabase_url = os.getenv("SUPABASE_URL")
supabase_key = os.getenv("SUPABASE_SERVICE_KEY")

if not supabase_url or not supabase_key:
    print("ERROR: SUPABASE_URL and SUPABASE_SERVICE_KEY are required")
    sys.exit(1)

sb = create_client(supabase_url, supabase_key)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def fetch_all(table: str) -> List[Dict[str, Any]]:
    """Fetch all rows from a Supabase table via REST API."""
    try:
        result = sb.table(table).select("*").execute()
        return result.data or []
    except Exception as e:
        print(f"  WARNING: Could not fetch {table}: {e}")
        return []


def _get_target_columns(db: Session, table: str) -> set:
    """Get the set of column names that exist in the target table."""
    try:
        result = db.execute(
            text("SELECT column_name FROM information_schema.columns WHERE table_name = :t"),
            {"t": table},
        )
        return {r[0] for r in result}
    except Exception:
        return set()


def _get_array_columns(db: Session, table: str) -> set:
    """Get columns that are Postgres ARRAY types (not jsonb)."""
    try:
        result = db.execute(
            text(
                "SELECT column_name FROM information_schema.columns "
                "WHERE table_name = :t AND data_type = 'ARRAY'"
            ),
            {"t": table},
        )
        return {r[0] for r in result}
    except Exception:
        return set()


def _to_pg_array(lst: list) -> str:
    """Convert a Python list to a Postgres array literal string."""
    if not lst:
        return "{}"
    escaped = []
    for item in lst:
        s = str(item).replace("\\", "\\\\").replace('"', '\\"')
        escaped.append(f'"{s}"')
    return "{" + ",".join(escaped) + "}"


def _prepare_row(row: Dict[str, Any], target_cols: set, array_cols: set) -> Dict[str, Any]:
    """Prepare a row for insertion: serialize JSON, handle arrays, drop unknown columns."""
    prepared = {}
    for k, v in row.items():
        # Drop columns that don't exist in the target table
        if target_cols and k not in target_cols:
            continue
        if isinstance(v, list) and k in array_cols:
            # Postgres ARRAY column — use Postgres array literal
            prepared[k] = _to_pg_array(v)
        elif isinstance(v, (dict, list)):
            # jsonb column — use JSON string
            prepared[k] = json.dumps(v)
        else:
            prepared[k] = v
    return prepared


def upsert_raw(db: Session, table: str, rows: List[Dict[str, Any]], dry_run: bool) -> int:
    """Insert rows into Railway Postgres using raw SQL with ON CONFLICT DO UPDATE.

    This avoids needing SQLAlchemy model definitions for every table — we just
    mirror the row dict directly. JSON values are serialized and unknown columns
    are dropped.
    """
    if not rows:
        return 0

    # Get target table columns to drop unknown source columns
    target_cols = _get_target_columns(db, table)
    array_cols = _get_array_columns(db, table)

    count = 0
    for row in rows:
        prepared = _prepare_row(row, target_cols, array_cols)
        cols = list(prepared.keys())
        if not cols:
            continue

        placeholders = ", ".join(f":{c}" for c in cols)
        col_names = ", ".join(f'"{c}"' for c in cols)
        # ON CONFLICT on primary key (id) → update all columns
        updates = ", ".join(f'"{c}" = EXCLUDED."{c}"' for c in cols if c != "id")

        sql = f'INSERT INTO "{table}" ({col_names}) VALUES ({placeholders})'
        if updates:
            sql += f" ON CONFLICT (id) DO UPDATE SET {updates}"
        else:
            sql += " ON CONFLICT (id) DO NOTHING"

        if not dry_run:
            try:
                db.execute(text(sql), prepared)
                count += 1
            except Exception as e:
                db.rollback()
                # Compact error message
                err_msg = str(e).split('\n')[0][:200]
                print(f"  WARNING: {row.get('id', '?')}: {err_msg}")
                continue
        else:
            count += 1

    if not dry_run:
        db.commit()

    return count


# ---------------------------------------------------------------------------
# Migration order — respects FK dependencies (parents before children)
# ---------------------------------------------------------------------------
MIGRATION_ORDER = [
    "modules",
    "trainings",
    "training_content",
    "assessments",
    "questions",
    "options",
    "profiles",
    "training_progress",
    "module_quiz_attempts",
    "certificates",
    "cot_observations",
    "teacher_dc_scores",
    "regions",
    "field_issues",
    "feedback",
    "scenarios",
    "scenario_options",
    "coach_assignments",
    "coach_vacation_config",
]


def migrate(dry_run: bool, commit: bool, tables: str = None) -> None:
    """Migrate data from Supabase to Railway Postgres."""

    if not dry_run and not commit:
        print("Usage:")
        print("  python scripts/migrate_from_supabase.py --dry-run")
        print("  python scripts/migrate_from_supabase.py --commit")
        print("  python scripts/migrate_from_supabase.py --commit --tables modules,trainings")
        return

    mode = "DRY RUN" if dry_run else "COMMIT"
    print(f"\n{'='*60}")
    print(f"  Full Data Migration: Supabase -> Railway Postgres")
    print(f"  Mode: {mode}")
    print(f"  Source: {supabase_url}")
    print(f"  Target: {db_url[:50]}...")
    print(f"{'='*60}\n")

    # Determine which tables to migrate
    if tables is not None:
        table_list = [t.strip() for t in tables.split(",") if t.strip()]
    else:
        table_list = MIGRATION_ORDER

    db = SessionLocal()
    results: Dict[str, Dict[str, int]] = {}

    try:
        for table in table_list:
            print(f"  [{table}]")

            # Fetch from Supabase
            rows = fetch_all(table)
            source_count = len(rows)

            if source_count == 0:
                print(f"    Source: 0 rows (skipping)")
                results[table] = {"source": 0, "migrated": 0}
                continue

            # Upsert into Railway Postgres
            migrated = upsert_raw(db, table, rows, dry_run)
            results[table] = {"source": source_count, "migrated": migrated}
            print(f"    Source: {source_count} rows -> Migrated: {migrated} rows")

        # Verification: count rows in target
        if not dry_run:
            print(f"\n{'='*60}")
            print(f"  Verification: Row counts in target DB")
            print(f"{'='*60}\n")

            for table in table_list:
                try:
                    result = db.execute(text(f'SELECT COUNT(*) FROM "{table}"'))
                    target_count = result.scalar()
                    source_count = results.get(table, {}).get("source", "?")
                    match = "OK" if target_count == source_count else "MISMATCH"
                    print(f"  {table}: source={source_count}, target={target_count} [{match}]")
                except Exception as e:
                    print(f"  {table}: could not verify ({e})")

        # Summary
        print(f"\n{'='*60}")
        print(f"  Migration Summary")
        print(f"{'='*60}\n")

        total_source = 0
        total_migrated = 0
        for table, counts in results.items():
            src = counts["source"]
            mig = counts["migrated"]
            total_source += src
            total_migrated += mig
            status = "OK" if src == mig else f"PARTIAL ({mig}/{src})"
            print(f"  {table:30s}  {src:6d} -> {mig:6d}  [{status}]")

        print(f"\n  {'TOTAL':30s}  {total_source:6d} -> {total_migrated:6d}")
        print()

        if dry_run:
            print("  This was a dry run. Run with --commit to execute.")
        else:
            print("  Migration committed successfully.")

    except Exception as e:
        print(f"\n  Migration failed: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
        sys.exit(1)

    finally:
        db.close()


if __name__ == "__main__":
    args = parser.parse_args()
    migrate(dry_run=args.dry_run, commit=args.commit, tables=args.tables)
