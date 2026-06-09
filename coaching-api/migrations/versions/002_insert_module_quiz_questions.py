"""Insert 173 quiz questions and options (162 MCQ + 11 scenario).

Revision ID: 002_insert_module_quiz_questions
Revises: 001_create_training_schema
Create Date: 2026-06-09 10:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
import json
from datetime import datetime, timezone
import uuid
import os

revision = "002_insert_module_quiz_questions"
down_revision = "001_create_training_schema"
branch_labels = None
depends_on = None


def _load_quiz_data():
    """Load extracted_quizzes.json from scripts/migrate-quiz-data/"""
    # Navigate to project root from migrations/versions/
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, "../../.."))
    json_path = os.path.join(project_root, "scripts/migrate-quiz-data/extracted_quizzes.json")

    with open(json_path, "r") as f:
        return json.load(f)


def upgrade() -> None:
    conn = op.get_bind()
    quiz_data = _load_quiz_data()

    # Module metadata: title and description per module
    module_metadata = {
        "module_1": {
            "title": "Foundations of Coaching",
            "description": "Introduction to coaching concepts and principles",
        },
        "module_2": {
            "title": "Coaching Skills",
            "description": "Essential skills for effective coaching",
        },
        "module_3": {
            "title": "Classroom Observation",
            "description": "Techniques for observing and analyzing classroom interactions",
        },
        "module_4": {
            "title": "Feedback Delivery",
            "description": "Providing constructive and actionable feedback",
        },
        "module_5": {
            "title": "Supporting Change",
            "description": "Leading and supporting educational change initiatives",
        },
        "module_6": {
            "title": "Professional Development",
            "description": "Sustaining growth and continuous learning",
        },
    }

    timestamp = datetime.now(timezone.utc)

    # 1. Insert modules
    module_inserts = []
    for idx, module_id in enumerate(sorted(quiz_data.keys()), 1):
        module_uuid = str(uuid.uuid4())
        metadata = module_metadata.get(module_id, {})
        module_inserts.append({
            "id": module_uuid,
            "title": metadata.get("title", module_id),
            "description": metadata.get("description", ""),
            "is_mandatory": True,
            "order_number": idx,
            "competencies": None,
            "persona_required": None,
            "created_at": timestamp,
            "original_module_id": module_id,  # Track for later reference
        })

    # Build module_id_map for lookups
    module_id_map = {}
    for item in module_inserts:
        module_id_map[item["original_module_id"]] = item["id"]

    # Insert modules
    for item in module_inserts:
        original_id = item.pop("original_module_id")
        sql = """
            INSERT INTO export_modules (id, title, description, is_mandatory, order_number, competencies, persona_required, created_at)
            VALUES (:id, :title, :description, :is_mandatory, :order_number, :competencies, :persona_required, :created_at)
            ON CONFLICT (id) DO NOTHING
        """
        conn.execute(sa.text(sql), item)

    # 2. Insert trainings (1 per module)
    training_inserts = []
    training_id_map = {}  # Map: (module_uuid, question_type) -> training_id

    for idx, (original_module_id, module_uuid) in enumerate(module_id_map.items(), 1):
        training_uuid = str(uuid.uuid4())
        training_inserts.append({
            "id": training_uuid,
            "module_id": module_uuid,
            "title": f"{module_metadata.get(original_module_id, {}).get('title', original_module_id)} - Quiz",
            "description": f"Assessment for {module_metadata.get(original_module_id, {}).get('title', original_module_id)}",
            "order_number": 1,
            "created_at": timestamp,
        })
        training_id_map[module_uuid] = training_uuid

    for item in training_inserts:
        sql = """
            INSERT INTO export_trainings (id, module_id, title, description, order_number, created_at)
            VALUES (:id, :module_id, :title, :description, :order_number, :created_at)
            ON CONFLICT (id) DO NOTHING
        """
        conn.execute(sa.text(sql), item)

    # 3. Insert questions and options
    question_inserts = []
    scenario_inserts = []
    option_inserts = []
    scenario_option_inserts = []

    for original_module_id in sorted(quiz_data.keys()):
        module_data = quiz_data[original_module_id]
        module_uuid = module_id_map[original_module_id]
        training_uuid = training_id_map[module_uuid]

        for q_idx, question in enumerate(module_data.get("questions", []), 0):
            question_uuid = str(uuid.uuid4())
            question_type = question.get("question_type", "mcq")

            if question_type == "scenario":
                # Insert as scenario
                scenario_inserts.append({
                    "id": question_uuid,
                    "training_id": training_uuid,
                    "situation": question.get("question_text", ""),
                    "question": question.get("question_text", ""),
                    "difficulty": "medium",
                    "created_at": timestamp,
                })

                # Insert scenario options
                for opt_idx, option in enumerate(question.get("options", []), 0):
                    scenario_opt_uuid = str(uuid.uuid4())
                    scenario_option_inserts.append({
                        "id": scenario_opt_uuid,
                        "scenario_id": question_uuid,
                        "letter": option.get("letter", chr(65 + opt_idx)),  # A, B, C, D
                        "option_text": option.get("option_text", ""),
                        "is_correct": option.get("is_correct", False),
                        "rationale": None,
                        "created_at": timestamp,
                    })
            else:
                # Regular MCQ: insert as question
                question_inserts.append({
                    "id": question_uuid,
                    "training_id": training_uuid,
                    "question_type": question_type,
                    "question_text": question.get("question_text", ""),
                    "order_number": q_idx,
                    "max_score": 1,
                    "created_at": timestamp,
                })

                # Insert options for MCQ
                for opt_idx, option in enumerate(question.get("options", []), 0):
                    option_uuid = str(uuid.uuid4())
                    option_inserts.append({
                        "id": option_uuid,
                        "question_id": question_uuid,
                        "option_text": option.get("option_text", ""),
                        "is_correct": option.get("is_correct", False),
                        "order_number": opt_idx,
                        "created_at": timestamp,
                    })

    # Insert all questions
    for item in question_inserts:
        sql = """
            INSERT INTO export_questions (id, training_id, question_type, question_text, order_number, max_score, created_at)
            VALUES (:id, :training_id, :question_type, :question_text, :order_number, :max_score, :created_at)
            ON CONFLICT (id) DO NOTHING
        """
        conn.execute(sa.text(sql), item)

    # Insert all options
    for item in option_inserts:
        sql = """
            INSERT INTO export_options (id, question_id, option_text, is_correct, order_number, created_at)
            VALUES (:id, :question_id, :option_text, :is_correct, :order_number, :created_at)
            ON CONFLICT (id) DO NOTHING
        """
        conn.execute(sa.text(sql), item)

    # Insert all scenarios
    for item in scenario_inserts:
        sql = """
            INSERT INTO export_scenarios (id, training_id, situation, question, difficulty, created_at)
            VALUES (:id, :training_id, :situation, :question, :difficulty, :created_at)
            ON CONFLICT (id) DO NOTHING
        """
        conn.execute(sa.text(sql), item)

    # Insert all scenario options
    for item in scenario_option_inserts:
        sql = """
            INSERT INTO export_scenario_options (id, scenario_id, letter, option_text, is_correct, rationale, created_at)
            VALUES (:id, :scenario_id, :letter, :option_text, :is_correct, :rationale, :created_at)
            ON CONFLICT (id) DO NOTHING
        """
        conn.execute(sa.text(sql), item)

    # Commit transaction
    conn.commit()


def downgrade() -> None:
    conn = op.get_bind()

    # Delete in reverse order (respecting foreign key constraints)
    # Get all trainings created for this migration (we'll identify by module + "-Quiz" title pattern)
    sql_scenarios = """
        DELETE FROM export_scenario_options
        WHERE scenario_id IN (
            SELECT id FROM export_scenarios
            WHERE training_id IN (
                SELECT id FROM export_trainings
                WHERE title LIKE '%- Quiz'
            )
        )
    """
    conn.execute(sa.text(sql_scenarios))

    sql_scenarios_del = """
        DELETE FROM export_scenarios
        WHERE training_id IN (
            SELECT id FROM export_trainings
            WHERE title LIKE '%- Quiz'
        )
    """
    conn.execute(sa.text(sql_scenarios_del))

    sql_options = """
        DELETE FROM export_options
        WHERE question_id IN (
            SELECT id FROM export_questions
            WHERE training_id IN (
                SELECT id FROM export_trainings
                WHERE title LIKE '%- Quiz'
            )
        )
    """
    conn.execute(sa.text(sql_options))

    sql_questions = """
        DELETE FROM export_questions
        WHERE training_id IN (
            SELECT id FROM export_trainings
            WHERE title LIKE '%- Quiz'
        )
    """
    conn.execute(sa.text(sql_questions))

    sql_trainings = """
        DELETE FROM export_trainings
        WHERE title LIKE '%- Quiz'
    """
    conn.execute(sa.text(sql_trainings))

    # Delete the 6 modules
    sql_modules = """
        DELETE FROM export_modules
        WHERE title IN ('Foundations of Coaching', 'Coaching Skills', 'Classroom Observation',
                        'Feedback Delivery', 'Supporting Change', 'Professional Development')
    """
    conn.execute(sa.text(sql_modules))

    conn.commit()
