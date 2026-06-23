"""Add punjab_cluster and rawalpindi_cluster columns to profiles.

Revision ID: 003_add_cluster_columns_to_profiles
Revises: 002_insert_module_quiz_questions
Create Date: 2026-06-21 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

revision = "003_add_cluster_columns_to_profiles"
down_revision = "002_insert_module_quiz_questions"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("profiles", sa.Column("punjab_cluster", sa.String(), nullable=True))
    op.add_column("profiles", sa.Column("rawalpindi_cluster", sa.String(), nullable=True))


def downgrade() -> None:
    op.drop_column("profiles", "rawalpindi_cluster")
    op.drop_column("profiles", "punjab_cluster")
