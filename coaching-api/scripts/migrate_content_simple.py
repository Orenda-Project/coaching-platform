#!/usr/bin/env python3
"""Simplified migration: Training content only (modules, trainings, training_content).

Assessment questions (endline, baseline) are EXCLUDED as they're separate from training.

Usage:
    python scripts/migrate_content_simple.py --dry-run    # Preview
    python scripts/migrate_content_simple.py --commit      # Execute
"""
import os
import sys
import uuid
from typing import Any, Dict, List
from pathlib import Path

import typer
from dotenv import load_dotenv
from supabase import create_client
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session, sessionmaker

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

# Load environment
load_dotenv(Path(__file__).parent.parent / ".env")

app = typer.Typer()

from app.models.training import Module, Training, TrainingContent

# Database setup
db_url = os.getenv("DATABASE_URL").replace("postgresql://", "postgresql+psycopg://")
engine = create_engine(db_url)
SessionLocal = sessionmaker(bind=engine)

# Supabase
supabase_url = os.getenv("SUPABASE_URL")
supabase_key = os.getenv("SUPABASE_SERVICE_KEY")

if not supabase_url or not supabase_key:
    print("❌ Error: SUPABASE_URL and SUPABASE_SERVICE_KEY required")
    sys.exit(1)

supabase = create_client(supabase_url, supabase_key)


def fetch_supabase_table(table_name: str) -> List[Dict[str, Any]]:
    """Fetch all rows from Supabase table."""
    try:
        result = supabase.table(table_name).select("*").execute()
        return result.data if result.data else []
    except Exception as e:
        print(f"⚠️  Could not fetch {table_name}: {e}")
        return []


def migrate_modules(db: Session, modules: List[Dict], dry_run: bool = False) -> int:
    """Migrate modules."""
    count = 0
    for mod in modules:
        try:
            module = Module(
                id=mod.get("id", str(uuid.uuid4())),
                title=mod.get("title", "Untitled"),
                description=mod.get("description"),
                is_mandatory=mod.get("is_mandatory", False),
                order_number=mod.get("order_number"),
                competencies=mod.get("competencies"),
                persona_required=mod.get("persona_required") or [],
                created_at=mod.get("created_at"),
            )
            if not dry_run:
                db.merge(module)
            count += 1
        except Exception as e:
            db.rollback()
            print(f"⚠️  Error migrating module {mod.get('id')}: {e}")

    if not dry_run:
        db.commit()
    return count


def migrate_trainings(db: Session, trainings: List[Dict], dry_run: bool = False) -> int:
    """Migrate trainings (units), skipping orphaned records."""
    count = 0
    skipped = 0
    for training_data in trainings:
        try:
            # Skip orphaned records
            if not training_data.get("module_id"):
                skipped += 1
                continue

            training = Training(
                id=training_data.get("id", str(uuid.uuid4())),
                module_id=training_data.get("module_id"),
                title=training_data.get("title", "Untitled"),
                description=training_data.get("description"),
                order_number=training_data.get("order_number"),
                created_at=training_data.get("created_at"),
            )
            if not dry_run:
                db.merge(training)
            count += 1
        except Exception as e:
            db.rollback()
            print(f"⚠️  Error migrating training {training_data.get('id')}: {e}")

    if not dry_run:
        db.commit()

    if skipped > 0:
        print(f"   (skipped {skipped} orphaned trainings without module_id)")

    return count


def migrate_training_content(
    db: Session, content_items: List[Dict], dry_run: bool = False
) -> int:
    """Migrate training content, skipping records with missing training_id."""
    count = 0
    skipped = 0
    for content in content_items:
        try:
            if not content.get("training_id"):
                skipped += 1
                continue

            tc = TrainingContent(
                id=content.get("id", str(uuid.uuid4())),
                training_id=content.get("training_id"),
                format_type=content.get("format_type"),
                content_url=content.get("content_url"),
                duration_minutes=content.get("duration_minutes"),
                extra_data=content.get("metadata"),
                created_at=content.get("created_at"),
            )
            if not dry_run:
                db.merge(tc)
            count += 1
        except Exception as e:
            db.rollback()
            print(f"⚠️  Error migrating training content {content.get('id')}: {e}")

    if not dry_run:
        db.commit()

    if skipped > 0:
        print(f"   (skipped {skipped} orphaned content items without training_id)")

    return count


@app.command()
def migrate(
    dry_run: bool = typer.Option(
        False, "--dry-run", help="Preview migration without committing"
    ),
    commit: bool = typer.Option(False, "--commit", help="Execute migration"),
) -> None:
    """Migrate training content only (modules, trainings, training_content)."""

    if not dry_run and not commit:
        print("ℹ️  Usage:")
        print("  python scripts/migrate_content_simple.py --dry-run   # Preview")
        print("  python scripts/migrate_content_simple.py --commit    # Execute")
        return

    mode = "DRY RUN" if dry_run else "COMMIT"
    print(f"\n{'='*60}")
    print(f"Training Content Migration: {mode}")
    print(f"(Assessment questions excluded - separate schema)")
    print(f"{'='*60}\n")

    # Fetch data
    print("📥 Fetching Supabase data...")
    modules = fetch_supabase_table("modules")
    trainings = fetch_supabase_table("trainings")
    content = fetch_supabase_table("training_content")

    print(f"✓ Fetched {len(modules)} modules")
    print(f"✓ Fetched {len(trainings)} trainings")
    print(f"✓ Fetched {len(content)} training content items\n")

    # Create session
    db = SessionLocal()

    try:
        print("📝 Migrating data...\n")

        module_count = migrate_modules(db, modules, dry_run)
        print(f"✓ Modules: {module_count} migrated")

        training_count = migrate_trainings(db, trainings, dry_run)
        print(f"✓ Trainings: {training_count} migrated")

        content_count = migrate_training_content(db, content, dry_run)
        print(f"✓ Training content: {content_count} migrated\n")

        # Summary
        total_migrated = module_count + training_count + content_count
        print(f"{'='*60}")
        print(f"Migration Summary")
        print(f"{'='*60}\n")
        print(f"Modules:           {module_count}")
        print(f"Trainings:         {training_count}")
        print(f"Training Content:  {content_count}")
        print(f"Total:             {total_migrated}\n")

        if dry_run:
            print(f"💡 Tip: Run with --commit to execute migration")
        else:
            print(f"✅ Migration committed to Railway PostgreSQL")

    except Exception as e:
        print(f"\n❌ Migration failed: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
        sys.exit(1)

    finally:
        db.close()


if __name__ == "__main__":
    app()
