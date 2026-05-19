"""Create training content schema.

Revision ID: 001_create_training_schema
Revises:
Create Date: 2026-05-18 10:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = "001_create_training_schema"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create modules table
    op.create_table(
        "modules",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("title", sa.String(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("is_mandatory", sa.Boolean(), nullable=True),
        sa.Column("order_number", sa.Integer(), nullable=True),
        sa.Column("competencies", sa.String(), nullable=True),
        sa.Column("persona_required", sa.ARRAY(sa.String()), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create trainings table
    op.create_table(
        "trainings",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("module_id", sa.String(), nullable=False),
        sa.Column("title", sa.String(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("order_number", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["module_id"], ["modules.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create training_content table
    op.create_table(
        "training_content",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("training_id", sa.String(), nullable=False),
        sa.Column("format_type", sa.String(), nullable=True),
        sa.Column("content_url", sa.String(), nullable=True),
        sa.Column("duration_minutes", sa.Integer(), nullable=True),
        sa.Column("metadata", sa.JSON(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["training_id"], ["trainings.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create questions table
    op.create_table(
        "questions",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("training_id", sa.String(), nullable=False),
        sa.Column("question_type", sa.String(), nullable=True),
        sa.Column("question_text", sa.Text(), nullable=False),
        sa.Column("order_number", sa.Integer(), nullable=True),
        sa.Column("max_score", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["training_id"], ["trainings.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create options table
    op.create_table(
        "options",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("question_id", sa.String(), nullable=False),
        sa.Column("option_text", sa.Text(), nullable=False),
        sa.Column("is_correct", sa.Boolean(), nullable=True),
        sa.Column("order_number", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["question_id"], ["questions.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create scenarios table
    op.create_table(
        "scenarios",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("training_id", sa.String(), nullable=False),
        sa.Column("situation", sa.Text(), nullable=True),
        sa.Column("question", sa.Text(), nullable=True),
        sa.Column("difficulty", sa.String(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["training_id"], ["trainings.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create scenario_options table
    op.create_table(
        "scenario_options",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("scenario_id", sa.String(), nullable=False),
        sa.Column("letter", sa.String(), nullable=True),
        sa.Column("option_text", sa.Text(), nullable=True),
        sa.Column("is_correct", sa.Boolean(), nullable=True),
        sa.Column("rationale", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["scenario_id"], ["scenarios.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create indexes
    op.create_index("idx_trainings_module_id", "trainings", ["module_id"])
    op.create_index("idx_questions_training_id", "questions", ["training_id"])
    op.create_index("idx_scenarios_training_id", "scenarios", ["training_id"])


def downgrade() -> None:
    # Drop indexes
    op.drop_index("idx_scenarios_training_id", table_name="scenarios")
    op.drop_index("idx_questions_training_id", table_name="questions")
    op.drop_index("idx_trainings_module_id", table_name="trainings")

    # Drop tables
    op.drop_table("scenario_options")
    op.drop_table("scenarios")
    op.drop_table("options")
    op.drop_table("questions")
    op.drop_table("training_content")
    op.drop_table("trainings")
    op.drop_table("modules")
