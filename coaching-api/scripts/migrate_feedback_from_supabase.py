#!/usr/bin/env python3
"""Migrate feedback data from Supabase 'feedback' table to Railway Postgres 'user_feedback' table.

Also ensures referenced users and profiles exist in Railway Postgres by fetching
them from Supabase auth.users and profiles tables.

Usage:
    # Set env vars first:
    #   SUPABASE_URL=https://<ref>.supabase.co
    #   SUPABASE_SERVICE_KEY=eyJ...  (service_role key)
    #   DATABASE_URL=postgresql://...  (Railway Postgres)

    python scripts/migrate_feedback_from_supabase.py --dry-run    # Preview
    python scripts/migrate_feedback_from_supabase.py --commit      # Execute
"""
import argparse
import os
import sys
from pathlib import Path

from dotenv import load_dotenv

# Load .env from coaching-api directory
load_dotenv(Path(__file__).resolve().parent.parent / ".env")

from supabase import create_client
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker


def ensure_user_exists(session, sb, user_id: str) -> bool:
    """Ensure user + profile exist in Railway Postgres. Create from Supabase if missing."""
    user_exists = session.execute(
        text("SELECT id FROM users WHERE id = :id"),
        {"id": user_id}
    ).fetchone()

    if user_exists:
        return True

    # Fetch user from Supabase auth.users via admin API
    try:
        auth_user = sb.auth.admin.get_user_by_id(user_id)
        email = auth_user.user.email or f"{user_id[:8]}@placeholder.local"
    except Exception:
        email = f"{user_id[:8]}@placeholder.local"

    # Create user in Railway Postgres
    session.execute(
        text("INSERT INTO users (id, email) VALUES (:id, :email) ON CONFLICT (id) DO NOTHING"),
        {"id": user_id, "email": email}
    )
    print(f"    Created user: {user_id[:8]}... ({email})")

    # Ensure profile exists too
    profile_exists = session.execute(
        text("SELECT id FROM profiles WHERE id = :id"),
        {"id": user_id}
    ).fetchone()

    if not profile_exists:
        # Fetch profile from Supabase
        try:
            profile_result = sb.table("profiles").select("*").eq("id", user_id).execute()
            profile_data = profile_result.data[0] if profile_result.data else {}
        except Exception:
            profile_data = {}

        session.execute(
            text("""
                INSERT INTO profiles (id, user_id, full_name, phone, persona, role)
                VALUES (:id, :user_id, :full_name, :phone, :persona, :role)
                ON CONFLICT (id) DO NOTHING
            """),
            {
                "id": user_id,
                "user_id": user_id,
                "full_name": profile_data.get("full_name"),
                "phone": profile_data.get("phone"),
                "persona": profile_data.get("persona"),
                "role": "learner",
            }
        )
        print(f"    Created profile: {user_id[:8]}... (name={profile_data.get('full_name', 'unknown')})")

    return True


def main():
    parser = argparse.ArgumentParser(description="Migrate feedback from Supabase to Railway Postgres")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--dry-run", action="store_true", help="Preview without writing")
    group.add_argument("--commit", action="store_true", help="Execute migration")
    args = parser.parse_args()

    supabase_url = os.getenv("SUPABASE_URL")
    supabase_key = os.getenv("SUPABASE_SERVICE_KEY")
    database_url = os.getenv("DATABASE_URL")

    if not supabase_url or not supabase_key:
        print("ERROR: SUPABASE_URL and SUPABASE_SERVICE_KEY are required")
        sys.exit(1)
    if not database_url:
        print("ERROR: DATABASE_URL is required")
        sys.exit(1)

    # Connect to Supabase
    sb = create_client(supabase_url, supabase_key)

    # Fetch all feedback from Supabase
    print("Fetching feedback from Supabase 'feedback' table...")
    result = sb.table("feedback").select("*").order("created_at", desc=True).execute()
    rows = result.data
    print(f"  Found {len(rows)} feedback records in Supabase")

    if not rows:
        print("No records to migrate.")
        return

    for r in rows:
        print(f"  - [{r['created_at'][:10]}] user={r['user_id'][:8]}... "
              f"cat={r['category']} rating={r['rating']}")

    if args.dry_run:
        print("\n[DRY RUN] No changes made. Use --commit to execute.")
        return

    # Connect to Railway Postgres
    db_url = database_url.replace("postgresql://", "postgresql+psycopg://")
    engine = create_engine(db_url)
    Session = sessionmaker(bind=engine)
    session = Session()

    inserted = 0
    skipped = 0

    for r in rows:
        feedback_id = r["id"]

        # Check if already migrated
        existing = session.execute(
            text("SELECT id FROM user_feedback WHERE id = :id"),
            {"id": feedback_id}
        ).fetchone()

        if existing:
            print(f"  SKIP (already exists): {feedback_id[:8]}...")
            skipped += 1
            continue

        # Ensure user + profile exist in Railway Postgres
        ensure_user_exists(session, sb, r["user_id"])

        # Insert into user_feedback
        session.execute(
            text("""
                INSERT INTO user_feedback (id, user_id, category, rating,
                    positive_feedback, improvement_feedback, context_page,
                    module_id, training_id, persona, user_agent, created_at)
                VALUES (:id, :user_id, :category, :rating,
                    :positive_feedback, :improvement_feedback, :context_page,
                    :module_id, :training_id, :persona, :user_agent, :created_at)
            """),
            {
                "id": feedback_id,
                "user_id": r["user_id"],
                "category": r["category"],
                "rating": r["rating"],
                "positive_feedback": r.get("positive_feedback"),
                "improvement_feedback": r.get("improvement_feedback"),
                "context_page": r.get("context_page"),
                "module_id": r.get("module_id"),
                "training_id": r.get("training_id"),
                "persona": r.get("persona"),
                "user_agent": r.get("user_agent"),
                "created_at": r["created_at"],
            }
        )
        inserted += 1
        print(f"  INSERT: {feedback_id[:8]}...")

    session.commit()
    session.close()
    print(f"\nDone: {inserted} inserted, {skipped} skipped")


if __name__ == "__main__":
    main()
