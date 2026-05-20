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
        "export_modules",
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
        "export_trainings",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("module_id", sa.String(), nullable=False),
        sa.Column("title", sa.String(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("order_number", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["module_id"], ["export_modules.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create training_content table
    op.create_table(
        "export_training_content",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("training_id", sa.String(), nullable=False),
        sa.Column("format_type", sa.String(), nullable=True),
        sa.Column("content_url", sa.String(), nullable=True),
        sa.Column("duration_minutes", sa.Integer(), nullable=True),
        sa.Column("extra_data", sa.JSON(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["training_id"], ["export_trainings.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create questions table
    op.create_table(
        "export_questions",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("training_id", sa.String(), nullable=False),
        sa.Column("question_type", sa.String(), nullable=True),
        sa.Column("question_text", sa.Text(), nullable=False),
        sa.Column("order_number", sa.Integer(), nullable=True),
        sa.Column("max_score", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["training_id"], ["export_trainings.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create options table
    op.create_table(
        "export_options",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("question_id", sa.String(), nullable=False),
        sa.Column("option_text", sa.Text(), nullable=False),
        sa.Column("is_correct", sa.Boolean(), nullable=True),
        sa.Column("order_number", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["question_id"], ["export_questions.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create scenarios table
    op.create_table(
        "export_scenarios",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("training_id", sa.String(), nullable=False),
        sa.Column("situation", sa.Text(), nullable=True),
        sa.Column("question", sa.Text(), nullable=True),
        sa.Column("difficulty", sa.String(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["training_id"], ["export_trainings.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create scenario_options table
    op.create_table(
        "export_scenario_options",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("scenario_id", sa.String(), nullable=False),
        sa.Column("letter", sa.String(), nullable=True),
        sa.Column("option_text", sa.Text(), nullable=True),
        sa.Column("is_correct", sa.Boolean(), nullable=True),
        sa.Column("rationale", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["scenario_id"], ["export_scenarios.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    # Create indexes
    op.create_index("idx_trainings_module_id", "export_trainings", ["module_id"])
    op.create_index("idx_questions_training_id", "export_questions", ["training_id"])
    op.create_index("idx_scenarios_training_id", "export_scenarios", ["training_id"])


def downgrade() -> None:
    # Drop indexes
    op.drop_index("idx_scenarios_training_id", table_name="export_scenarios")
    op.drop_index("idx_questions_training_id", table_name="export_questions")
    op.drop_index("idx_trainings_module_id", table_name="export_trainings")

    # Drop tables
    op.drop_table("export_scenario_options")
    op.drop_table("export_scenarios")
    op.drop_table("export_options")
    op.drop_table("export_questions")
    op.drop_table("export_training_content")
    op.drop_table("export_trainings")
    op.drop_table("export_modules")
