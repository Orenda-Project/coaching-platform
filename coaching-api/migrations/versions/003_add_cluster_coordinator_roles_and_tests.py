"""Add roles table, role-scoped content, and baseline/midline/endline tests.

Ticket: MC20-18837 — introduce the cluster_coordinator audience without
breaking existing content.

All changes are additive / backward-compatible:
  1. New `roles` lookup table, seeded with the known roles (incl. cluster_coordinator).
  2. New `tests` table — baseline/midline/endline test *definitions*, scoped to a
     role. (Distinct from the attempt-focused `assessments` table.)
  3. `export_modules.role_id` and `export_trainings.role_id` FKs → roles.
     Existing rows are backfilled to the 'coach' track, so current behaviour is
     unchanged (the export API does not yet filter on role_id).
  4. `export_questions` may now belong to a training OR a test: `test_id` FK added,
     `training_id` relaxed to nullable, and a CHECK enforces exactly one parent.
     Existing rows keep training_id (test_id NULL) and satisfy the constraint.

Revision ID: 003_add_cluster_coordinator_roles_and_tests
Revises: 002_insert_module_quiz_questions
Create Date: 2026-06-10 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
import uuid
from datetime import datetime, timezone

# revision identifiers, used by Alembic.
revision = "003_add_cluster_coordinator_roles_and_tests"
down_revision = "002_insert_module_quiz_questions"
branch_labels = None
depends_on = None


# Roles seeded by this migration. 'coach' is the default track for existing content.
SEED_ROLES = [
    ("cluster_coordinator", "Cluster Coordinator — separate learning track and tests"),
    ("coach", "Coach (default track for existing content)"),
    ("learner", "Generic learner"),
    ("admin", "Administrator"),
    ("regional_admin", "Regional administrator"),
]


def upgrade() -> None:
    conn = op.get_bind()
    now = datetime.now(timezone.utc)

    # 1. roles lookup table -----------------------------------------------------
    op.create_table(
        "roles",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("name", name="uq_roles_name"),
    )

    role_ids = {name: str(uuid.uuid4()) for name, _ in SEED_ROLES}
    roles_tbl = sa.table(
        "roles",
        sa.column("id", sa.String),
        sa.column("name", sa.String),
        sa.column("description", sa.Text),
        sa.column("created_at", sa.DateTime),
        sa.column("updated_at", sa.DateTime),
    )
    op.bulk_insert(
        roles_tbl,
        [
            {"id": role_ids[name], "name": name, "description": desc,
             "created_at": now, "updated_at": now}
            for name, desc in SEED_ROLES
        ],
    )

    # 2. tests table (baseline/midline/endline definitions) ---------------------
    op.create_table(
        "tests",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("role_id", sa.String(), nullable=True),
        sa.Column("test_type", sa.String(), nullable=False),
        sa.Column("title", sa.String(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("order_number", sa.Integer(), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["role_id"], ["roles.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.CheckConstraint(
            "test_type IN ('baseline', 'midline', 'endline')",
            name="ck_tests_test_type",
        ),
    )
    op.create_index("idx_tests_role_id", "tests", ["role_id"])

    # 3. role_id on existing content + backfill to the coach track --------------
    op.add_column("export_modules", sa.Column("role_id", sa.String(), nullable=True))
    op.create_foreign_key(
        "fk_export_modules_role_id", "export_modules", "roles", ["role_id"], ["id"]
    )
    op.create_index("idx_modules_role_id", "export_modules", ["role_id"])

    op.add_column("export_trainings", sa.Column("role_id", sa.String(), nullable=True))
    op.create_foreign_key(
        "fk_export_trainings_role_id", "export_trainings", "roles", ["role_id"], ["id"]
    )
    op.create_index("idx_trainings_role_id", "export_trainings", ["role_id"])

    conn.execute(
        sa.text("UPDATE export_modules SET role_id = :rid WHERE role_id IS NULL"),
        {"rid": role_ids["coach"]},
    )
    conn.execute(
        sa.text("UPDATE export_trainings SET role_id = :rid WHERE role_id IS NULL"),
        {"rid": role_ids["coach"]},
    )

    # 4. questions: training OR test (exactly one) ------------------------------
    op.add_column("export_questions", sa.Column("test_id", sa.String(), nullable=True))
    op.create_foreign_key(
        "fk_export_questions_test_id", "export_questions", "tests", ["test_id"], ["id"]
    )
    op.create_index("idx_questions_test_id", "export_questions", ["test_id"])
    op.alter_column(
        "export_questions", "training_id",
        existing_type=sa.String(), nullable=True,
    )
    op.create_check_constraint(
        "ck_questions_one_parent",
        "export_questions",
        "num_nonnulls(training_id, test_id) = 1",
    )


def downgrade() -> None:
    # 4. questions: revert to training-only
    op.drop_constraint("ck_questions_one_parent", "export_questions", type_="check")
    # Remove any test-only questions so training_id can be made NOT NULL again.
    op.execute("DELETE FROM export_questions WHERE test_id IS NOT NULL")
    op.drop_index("idx_questions_test_id", table_name="export_questions")
    op.drop_constraint("fk_export_questions_test_id", "export_questions", type_="foreignkey")
    op.drop_column("export_questions", "test_id")
    op.alter_column(
        "export_questions", "training_id",
        existing_type=sa.String(), nullable=False,
    )

    # 3. role_id on content
    op.drop_index("idx_trainings_role_id", table_name="export_trainings")
    op.drop_constraint("fk_export_trainings_role_id", "export_trainings", type_="foreignkey")
    op.drop_column("export_trainings", "role_id")

    op.drop_index("idx_modules_role_id", table_name="export_modules")
    op.drop_constraint("fk_export_modules_role_id", "export_modules", type_="foreignkey")
    op.drop_column("export_modules", "role_id")

    # 2. tests
    op.drop_index("idx_tests_role_id", table_name="tests")
    op.drop_table("tests")

    # 1. roles
    op.drop_table("roles")
