#!/usr/bin/env python3
"""Migrate training content from Supabase to Railway PostgreSQL.

Usage:
    python scripts/migrate_content.py --dry-run    # Preview what will be migrated
    python scripts/migrate_content.py --commit      # Execute migration
"""
import os
import sys
import json
import uuid
from typing import Any, Dict, List, Optional
from datetime import datetime
from pathlib import Path

import typer
from dotenv import load_dotenv
from supabase import create_client
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session, sessionmaker

# Add parent directory to path so we can import app module
sys.path.insert(0, str(Path(__file__).parent.parent))

# Load environment variables from .env file
load_dotenv(Path(__file__).parent.parent / ".env")

app = typer.Typer()

# Load environment
from app.config import settings
from app.models.training import (
    Module, Training, TrainingContent, Question, Option, Scenario, ScenarioOption
)

# Supabase client
supabase_url = os.getenv("SUPABASE_URL")
supabase_key = os.getenv("SUPABASE_SERVICE_KEY")

if not supabase_url or not supabase_key:
    print("❌ Error: SUPABASE_URL and SUPABASE_SERVICE_KEY environment variables required")
    print("\n📋 To get SUPABASE_SERVICE_KEY:")
    print("   1. Go to Supabase dashboard: https://app.supabase.com/project/agziuwqpkfmxtospfxns")
    print("   2. Settings → API → Project API keys")
    print("   3. Copy the 'service_role' secret key (long key starting with 'eyJ...')")
    print("   4. Add to .env: SUPABASE_SERVICE_KEY=<your-key>")
    sys.exit(1)

supabase = create_client(supabase_url, supabase_key)

# Railway PostgreSQL
db_url = settings.database_url.replace("postgresql://", "postgresql+psycopg://")
engine = create_engine(db_url)
SessionLocal = sessionmaker(bind=engine)


def fetch_supabase_table(table_name: str) -> List[Dict[str, Any]]:
    """Fetch all rows from a Supabase table."""
    try:
        result = supabase.table(table_name).select("*").execute()
        return result.data if result.data else []
    except Exception as e:
        print(f"⚠️  Could not fetch {table_name}: {e}")
        return []


def migrate_modules(db: Session, modules: List[Dict], dry_run: bool = False) -> int:
    """Migrate modules from Supabase to Railway PostgreSQL."""
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
                db.merge(module)  # Use merge to handle duplicates
            count += 1
        except Exception as e:
            print(f"⚠️  Error migrating module {mod.get('id')}: {e}")

    if not dry_run:
        db.commit()

    return count


def migrate_trainings(db: Session, trainings: List[Dict], dry_run: bool = False) -> int:
    """Migrate trainings (units) from Supabase to Railway PostgreSQL."""
    count = 0
    for training_data in trainings:
        try:
            # Skip if module_id is missing (data integrity)
            if not training_data.get("module_id"):
                print(f"⚠️  Skipping training {training_data.get('id')}: missing module_id")
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
            db.rollback()  # Reset session on error
            print(f"⚠️  Error migrating training {training_data.get('id')}: {e}")

    if not dry_run:
        db.commit()

    return count


def migrate_training_content(
    db: Session, content_items: List[Dict], dry_run: bool = False
) -> int:
    """Migrate training content from Supabase to Railway PostgreSQL."""
    count = 0
    for content in content_items:
        try:
            if not content.get("training_id"):
                print(f"⚠️  Skipping training content {content.get('id')}: missing training_id")
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

    return count


def migrate_questions(db: Session, questions: List[Dict], dry_run: bool = False) -> int:
    """Migrate quiz questions from Supabase to Railway PostgreSQL."""
    count = 0
    for question_data in questions:
        try:
            if not question_data.get("training_id"):
                print(f"⚠️  Skipping question {question_data.get('id')}: missing training_id")
                continue

            question = Question(
                id=question_data.get("id", str(uuid.uuid4())),
                training_id=question_data.get("training_id"),
                question_type=question_data.get("question_type", "mcq"),
                question_text=question_data.get("question_text", ""),
                order_number=question_data.get("order_number"),
                max_score=question_data.get("max_score", 1),
                created_at=question_data.get("created_at"),
            )
            if not dry_run:
                db.merge(question)
            count += 1
        except Exception as e:
            db.rollback()
            print(f"⚠️  Error migrating question {question_data.get('id')}: {e}")

    if not dry_run:
        db.commit()

    return count


def migrate_options(db: Session, options: List[Dict], dry_run: bool = False) -> int:
    """Migrate multiple-choice options from Supabase to Railway PostgreSQL."""
    count = 0
    for option_data in options:
        try:
            if not option_data.get("question_id"):
                print(f"⚠️  Skipping option {option_data.get('id')}: missing question_id")
                continue

            option = Option(
                id=option_data.get("id", str(uuid.uuid4())),
                question_id=option_data.get("question_id"),
                option_text=option_data.get("option_text", ""),
                is_correct=option_data.get("is_correct", False),
                order_number=option_data.get("order_number"),
                created_at=option_data.get("created_at"),
            )
            if not dry_run:
                db.merge(option)
            count += 1
        except Exception as e:
            db.rollback()
            print(f"⚠️  Error migrating option {option_data.get('id')}: {e}")

    if not dry_run:
        db.commit()

    return count


def migrate_scenarios(db: Session, scenarios: List[Dict], dry_run: bool = False) -> int:
    """Migrate scenario-based learning from Supabase to Railway PostgreSQL."""
    count = 0
    for scenario_data in scenarios:
        try:
            scenario = Scenario(
                id=scenario_data.get("id", str(uuid.uuid4())),
                training_id=scenario_data.get("training_id"),
                situation=scenario_data.get("situation"),
                question=scenario_data.get("question"),
                difficulty=scenario_data.get("difficulty"),
                created_at=scenario_data.get("created_at"),
            )
            if not dry_run:
                db.merge(scenario)
            count += 1
        except Exception as e:
            print(f"⚠️  Error migrating scenario {scenario_data.get('id')}: {e}")

    if not dry_run:
        db.commit()

    return count


def migrate_scenario_options(
    db: Session, options: List[Dict], dry_run: bool = False
) -> int:
    """Migrate scenario options from Supabase to Railway PostgreSQL."""
    count = 0
    for option_data in options:
        try:
            scenario_option = ScenarioOption(
                id=option_data.get("id", str(uuid.uuid4())),
                scenario_id=option_data.get("scenario_id"),
                letter=option_data.get("letter"),
                option_text=option_data.get("option_text"),
                is_correct=option_data.get("is_correct", False),
                rationale=option_data.get("rationale"),
                created_at=option_data.get("created_at"),
            )
            if not dry_run:
                db.merge(scenario_option)
            count += 1
        except Exception as e:
            print(f"⚠️  Error migrating scenario option {option_data.get('id')}: {e}")

    if not dry_run:
        db.commit()

    return count


def get_supabase_counts() -> Dict[str, int]:
    """Get row counts from Supabase tables."""
    counts = {}
    tables = [
        "modules",
        "trainings",
        "training_content",
        "questions",
        "options",
        "scenarios",
        "scenario_options",
    ]

    for table in tables:
        try:
            result = supabase.table(table).select("id", count="exact").execute()
            counts[table] = result.count or 0
        except Exception as e:
            print(f"⚠️  Could not count {table}: {e}")
            counts[table] = 0

    return counts


def get_railway_counts(db: Session) -> Dict[str, int]:
    """Get row counts from Railway PostgreSQL tables."""
    counts = {}
    tables = [
        "export_modules",
        "export_trainings",
        "export_training_content",
        "export_questions",
        "export_options",
        "export_scenarios",
        "export_scenario_options",
    ]

    for table in tables:
        try:
            result = db.execute(text(f"SELECT COUNT(*) FROM {table}"))
            count = result.scalar() or 0
            counts[table] = count
        except Exception as e:
            print(f"⚠️  Could not count {table}: {e}")
            counts[table] = 0

    return counts


@app.command()
def migrate(
    dry_run: bool = typer.Option(
        False, "--dry-run", help="Preview migration without committing"
    ),
    commit: bool = typer.Option(False, "--commit", help="Execute migration"),
) -> None:
    """Migrate training content from Supabase to Railway PostgreSQL."""

    if not dry_run and not commit:
        print("ℹ️  Usage:")
        print("  python scripts/migrate_content.py --dry-run   # Preview")
        print("  python scripts/migrate_content.py --commit    # Execute")
        return

    mode = "DRY RUN" if dry_run else "COMMIT"
    print(f"\n{'='*60}")
    print(f"Migration Mode: {mode}")
    print(f"{'='*60}\n")

    # Get Supabase counts
    print("📊 Fetching Supabase data...")
    supabase_counts = get_supabase_counts()
    total_supabase = sum(supabase_counts.values())

    print(f"✓ Supabase totals:")
    for table, count in supabase_counts.items():
        print(f"  - {table}: {count} rows")
    print(f"  Total: {total_supabase} rows\n")

    # Fetch data
    print("📥 Fetching Supabase data...")
    modules = fetch_supabase_table("modules")
    trainings = fetch_supabase_table("trainings")
    content = fetch_supabase_table("training_content")
    questions = fetch_supabase_table("questions")
    options = fetch_supabase_table("options")
    scenarios = fetch_supabase_table("scenarios")
    scenario_options = fetch_supabase_table("scenario_options")

    print(f"✓ Fetched {len(modules)} modules")
    print(f"✓ Fetched {len(trainings)} trainings")
    print(f"✓ Fetched {len(content)} training content items")
    print(f"✓ Fetched {len(questions)} questions")
    print(f"✓ Fetched {len(options)} options")
    print(f"✓ Fetched {len(scenarios)} scenarios")
    print(f"✓ Fetched {len(scenario_options)} scenario options\n")

    # Create database session
    db = SessionLocal()

    try:
        # Migrate each table
        print("📝 Migrating data...\n")

        module_count = migrate_modules(db, modules, dry_run)
        print(f"✓ Modules: {module_count} migrated")

        training_count = migrate_trainings(db, trainings, dry_run)
        print(f"✓ Trainings: {training_count} migrated")

        content_count = migrate_training_content(db, content, dry_run)
        print(f"✓ Training content: {content_count} migrated")

        question_count = migrate_questions(db, questions, dry_run)
        print(f"✓ Questions: {question_count} migrated")

        option_count = migrate_options(db, options, dry_run)
        print(f"✓ Options: {option_count} migrated")

        scenario_count = migrate_scenarios(db, scenarios, dry_run)
        print(f"✓ Scenarios: {scenario_count} migrated")

        scenario_option_count = migrate_scenario_options(db, scenario_options, dry_run)
        print(f"✓ Scenario options: {scenario_option_count} migrated\n")

        # Verify counts
        total_migrated = (
            module_count
            + training_count
            + content_count
            + question_count
            + option_count
            + scenario_count
            + scenario_option_count
        )

        railway_counts = get_railway_counts(db)
        total_railway = sum(railway_counts.values())

        print(f"{'='*60}")
        print(f"Migration Summary")
        print(f"{'='*60}\n")
        print(f"Supabase:        {total_supabase:,} rows")
        print(f"Railway:         {total_railway:,} rows")
        print(f"Migrated:        {total_migrated:,} rows\n")

        if total_railway == total_supabase:
            print("✅ SUCCESS: All data migrated correctly!")
        else:
            print(f"⚠️  WARNING: Row count mismatch!")
            print(f"   Expected {total_supabase}, got {total_railway}")

        if dry_run:
            print(f"\n💡 Tip: Run with --commit to execute migration")
        else:
            print(f"\n✅ Migration committed to Railway PostgreSQL")

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
