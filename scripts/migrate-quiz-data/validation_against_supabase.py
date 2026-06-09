#!/usr/bin/env python3
"""
Validation Script: Extracted Quiz Data vs Supabase
Compares extracted_quizzes.json against current Supabase state.
"""

import json
from pathlib import Path
from datetime import datetime

EXTRACTED_FILE = Path(__file__).parent / "extracted_quizzes.json"

# Supabase data (collected from direct SQL queries)
SUPABASE_ASSESSMENTS = [
    {"type": "module_quiz", "title": "Unit 1.0: The Coaching Catalyst — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 1.1: The Partnership Posture — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 1.2: The Shared Mirror — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 1.3: The Growth Engine — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 1.4: The Trust Bridge — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 1.5: The Human Filter — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 1.6: Coding the Classroom — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 2.1: Status & Psychological Safety — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 2.2: Evidence-Based Dialogue — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 2.3: Goal-Setting as Co-Creation — Quiz", "question_count": 8},
    {"type": "baseline", "title": "Coach Baseline Assessment", "question_count": 30},
    {"type": "module_quiz", "title": "Unit 3.1: The Mirror Specialist — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 3.2: The Artifact Architect — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 3.3: Data Into Dialogue — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 4.1: The Digital Journal — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 4.2: The Adaptive Facilitator — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 4.3: The Partnership Advocate — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 4.4: The Consistency Guardian (WRER) — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 5.1: The Power of Choice Within the Impact Cycle — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 5.2: Finding the 'Why' — Identifying Intellectual Gaps — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 5.3: Closing the Loop — Side-by-Side Modeling — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 5.4: Diagnosing the 3 Loops — Precision Coaching — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 6.1: Closing the Loop — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 6.2: The Protocol Guardrail — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 6.3: Responsive Contextualization and Praxis — Quiz", "question_count": 8},
    {"type": "module_quiz", "title": "Unit 6.4: Reciprocity — The Ethical Defense — Quiz", "question_count": 8},
]

# Map units to extracted modules
UNIT_TO_MODULE = {
    "Unit 1.0": "module_1",
    "Unit 1.1": "module_1",
    "Unit 1.2": "module_1",
    "Unit 1.3": "module_1",
    "Unit 1.4": "module_1",
    "Unit 1.5": "module_1",
    "Unit 1.6": "module_1",
    "Unit 2.1": "module_2",
    "Unit 2.2": "module_2",
    "Unit 2.3": "module_2",
    "Unit 3.1": "module_3",
    "Unit 3.2": "module_3",
    "Unit 3.3": "module_3",
    "Unit 4.1": "module_4",
    "Unit 4.2": "module_4",
    "Unit 4.3": "module_4",
    "Unit 4.4": "module_4",
    "Unit 5.1": "module_5",
    "Unit 5.2": "module_5",
    "Unit 5.3": "module_5",
    "Unit 5.4": "module_5",
    "Unit 6.1": "module_6",
    "Unit 6.2": "module_6",
    "Unit 6.3": "module_6",
    "Unit 6.4": "module_6",
}

def load_extracted_data():
    """Load extracted quiz data from JSON."""
    if not EXTRACTED_FILE.exists():
        print(f"Error: {EXTRACTED_FILE} not found")
        return None

    with open(EXTRACTED_FILE) as f:
        return json.load(f)

def analyze_extracted_data(extracted):
    """Analyze extracted quiz data structure."""
    analysis = {
        'total_questions': 0,
        'per_module': {},
        'questions_with_answer_keys': 0,
        'module_details': {}
    }

    for module_id, module_data in extracted.items():
        questions = module_data.get('questions', [])
        count = len(questions)

        analysis['total_questions'] += count
        analysis['per_module'][module_id] = count

        # Count questions with correct answers
        with_answers = sum(1 for q in questions if q.get('has_correct_answer', False))
        analysis['questions_with_answer_keys'] += with_answers

        analysis['module_details'][module_id] = {
            'count': count,
            'with_answer_keys': with_answers,
            'without_answer_keys': count - with_answers
        }

    return analysis

def analyze_supabase_data(assessments):
    """Analyze current Supabase quiz data."""
    analysis = {
        'total_quiz_questions': 0,
        'baseline_questions': 0,
        'per_module': {},
        'units': {}
    }

    for assessment in assessments:
        unit_key = assessment['title'].split(':')[0]  # "Unit X.Y"
        question_count = assessment['question_count']

        if assessment['type'] == 'baseline':
            analysis['baseline_questions'] = question_count
        else:
            analysis['total_quiz_questions'] += question_count

            # Map to module
            if unit_key in UNIT_TO_MODULE:
                module_id = UNIT_TO_MODULE[unit_key]
                if module_id not in analysis['per_module']:
                    analysis['per_module'][module_id] = 0
                analysis['per_module'][module_id] += question_count

            analysis['units'][unit_key] = question_count

    return analysis

def generate_audit_report(extracted_analysis, supabase_analysis):
    """Generate markdown audit report."""
    report = []
    report.append("# Quiz Data Audit Report\n")
    report.append(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

    # Summary
    report.append("## Summary\n")
    report.append(f"- **Extracted MCQ Questions:** {extracted_analysis['total_questions']}")
    report.append(f"- **Extracted with Answer Keys:** {extracted_analysis['questions_with_answer_keys']}")
    report.append(f"- **Extracted without Answer Keys:** {extracted_analysis['total_questions'] - extracted_analysis['questions_with_answer_keys']}\n")

    report.append(f"- **Supabase Module Quiz Questions:** {supabase_analysis['total_quiz_questions']}")
    report.append(f"- **Supabase Baseline Questions:** {supabase_analysis['baseline_questions']}\n")

    # Overall match analysis
    report.append("## Count Analysis\n")
    report.append("### Extracted vs Supabase Module Quizzes\n")

    extracted_total = extracted_analysis['total_questions']
    supabase_total = supabase_analysis['total_quiz_questions']
    baseline_questions = supabase_analysis['baseline_questions']

    if extracted_total == supabase_total:
        report.append(f"✅ **MATCH:** Extracted ({extracted_total}) = Supabase module quizzes ({supabase_total})\n")
        match_status = "PASS"
    else:
        diff = extracted_total - supabase_total
        report.append(f"⚠️ **MISMATCH:** Extracted has {diff:+d} questions")
        report.append(f"   - Extracted: {extracted_total}")
        report.append(f"   - Supabase module quizzes: {supabase_total}\n")
        match_status = "CONCERN"

    # Per-module comparison
    report.append("## Per-Module Breakdown\n")
    report.append("| Module | Extracted | Extracted w/ Keys | Supabase Module Quizzes | Status |\n")
    report.append("|--------|-----------|-------------------|------------------------|--------|\n")

    all_modules = sorted(set(list(extracted_analysis['per_module'].keys()) + list(supabase_analysis['per_module'].keys())))

    for module_id in all_modules:
        extracted_count = extracted_analysis['per_module'].get(module_id, 0)
        with_keys = extracted_analysis['module_details'].get(module_id, {}).get('with_answer_keys', 0)
        supabase_count = supabase_analysis['per_module'].get(module_id, 0)

        if extracted_count == supabase_count:
            status = "✅"
        else:
            status = "⚠️"

        report.append(f"| {module_id} | {extracted_count} | {with_keys} | {supabase_count} | {status} |\n")

    # Unit breakdown
    report.append("\n## Unit-Level Breakdown (Supabase)\n")
    report.append("| Unit | Questions | Status |\n")
    report.append("|------|-----------|--------|\n")
    for unit_key in sorted(supabase_analysis['units'].keys()):
        count = supabase_analysis['units'][unit_key]
        report.append(f"| {unit_key} | {count} | ✓ |\n")

    # Details
    report.append("\n## Module Details (Extracted Data)\n")
    for module_id in sorted(extracted_analysis['module_details'].keys()):
        details = extracted_analysis['module_details'][module_id]
        report.append(f"\n### {module_id}\n")
        report.append(f"- Total: {details['count']}\n")
        report.append(f"- With Answer Keys: {details['with_answer_keys']}\n")
        report.append(f"- Without Answer Keys: {details['without_answer_keys']}\n")

    # Additional context
    report.append("\n## Context\n")
    report.append(f"- **Baseline Assessment:** {baseline_questions} questions (currently in Supabase, separate from module quizzes)\n")
    report.append("- **Extraction Source:** Google Docs (extracted_quizzes.json)\n")
    report.append("- **Target:** Migrate extracted MCQ data to replace/supplement existing module quizzes\n")

    # Recommendation
    report.append("\n## Recommendation\n")

    all_modules_match = all(
        extracted_analysis['per_module'].get(m, 0) == supabase_analysis['per_module'].get(m, 0)
        for m in extracted_analysis['per_module'].keys()
        if m in supabase_analysis['per_module']
    )

    if match_status == "PASS" and all_modules_match:
        report.append("✅ **PROCEED WITH MIGRATION**\n\n")
        report.append("All extracted questions match Supabase counts by module. ")
        report.append("Data is ready for migration (consider backup before import).\n")
        status = "DONE"
    elif match_status == "CONCERN":
        report.append("⚠️ **INVESTIGATE MISMATCH BEFORE MIGRATION**\n\n")
        report.append("Question counts don't match. Possible explanations:\n")
        report.append("1. Extracted data is newer/different version than what's in Supabase\n")
        report.append("2. Some questions were removed or added to Supabase\n")
        report.append("3. Baseline assessment questions are separate (not in module quizzes)\n\n")
        report.append("**Action:** Review the per-module breakdown to identify which modules differ.\n")
        status = "DONE_WITH_CONCERNS"
    else:
        report.append("✅ **READY FOR REVIEW**\n\n")
        report.append("Data extracted successfully. Review per-module breakdown before migrating.\n")
        status = "DONE"

    return '\n'.join(report), status

def main():
    """Main validation flow."""
    print("Loading extracted quiz data...")
    extracted = load_extracted_data()
    if not extracted:
        return 1

    extracted_analysis = analyze_extracted_data(extracted)
    print(f"✓ Loaded {extracted_analysis['total_questions']} extracted questions")
    print(f"  - With answer keys: {extracted_analysis['questions_with_answer_keys']}")

    print("\nAnalyzing Supabase data...")
    supabase_analysis = analyze_supabase_data(SUPABASE_ASSESSMENTS)
    print(f"✓ Analyzed Supabase: {supabase_analysis['total_quiz_questions']} module quiz questions")
    print(f"  - Plus {supabase_analysis['baseline_questions']} baseline questions")

    print("\nGenerating audit report...")
    report_text, status = generate_audit_report(extracted_analysis, supabase_analysis)

    # Write report
    report_path = Path(__file__).parent / "quiz_audit_report.md"
    report_path.write_text(report_text)
    print(f"✓ Report written to {report_path}")

    # Print summary
    print("\n" + "="*70)
    print(report_text)
    print("="*70)
    print(f"\nStatus: {status}")

    return 0

if __name__ == "__main__":
    exit(main())
