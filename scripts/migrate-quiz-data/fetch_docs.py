#!/usr/bin/env python3
"""
Fetch quiz data from 6 Google Docs and parse into structured JSON.
Module 1-6: 16 MCQs + 4 scenarios each = 20 questions per module.
"""

import json
import re
from typing import Dict, List, Any
import urllib.request
import urllib.error

# Google Docs export URLs (as CSV/txt via export endpoint)
GOOGLE_DOCS = {
    "module_1": "https://docs.google.com/document/d/1ixQ9SWZDald2ERxNArQTTKid0OClHvipUOhCSj4Yjow/export?format=txt",
    "module_2": "https://docs.google.com/document/d/10XimDrx3Nkces2uTmc8_zvR79TAPuIEvbo2Syf5v8EU/export?format=txt",
    "module_3": "https://docs.google.com/document/d/1Fw_mPzaT5lGLfA2BIQhKlEdoWAZmgt1avfoQcNcs-L0/export?format=txt",
    "module_4": "https://docs.google.com/document/d/1gYBORKhJ1USVV20WYJXaQhaAp41OD4FDy-5t4f4jc64/export?format=txt",
    "module_5": "https://docs.google.com/document/d/1gH9a-6Ih2Dgi6NLjS4lT2LlNgh5IAek0oRWRvIIqONE/export?format=txt",
    "module_6": "https://docs.google.com/document/d/1IDEtEqiwzCWPVChP0jLLoK8QxFyfnaHP2vn35vbDvek/export?format=txt",
}

def fetch_google_doc(module_id: str, url: str) -> str:
    """Fetch raw text from Google Doc export URL."""
    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            content = response.read().decode('utf-8')
            print(f"✓ Fetched {module_id} ({len(content)} chars)")
            return content
    except urllib.error.URLError as e:
        print(f"✗ Failed to fetch {module_id}: {e}")
        return ""

def parse_questions(content: str, module_id: str) -> List[Dict[str, Any]]:
    """
    Parse questions from raw Google Doc text.
    Format:
    - Questions 1-16: MCQ (question text, then A) B) C) D) options)
    - Questions 17-20: Scenario (situation + question, then A) B) C) D) options)
    """
    questions = []

    # Split by numbered question (e.g., "1. What is...")
    # More flexible pattern to capture optional leading whitespace
    question_blocks = re.split(r'\n\s*(?=\d+\.)', content.strip())

    for block in question_blocks:
        if not block.strip():
            continue

        # Extract question number and text
        # Match: optional whitespace + digits + period + space + text up to next option
        match = re.match(r'\s*(\d+)\.\s+(.+?)(?=\n\s*[A-D]\)|$)', block, re.DOTALL)
        if not match:
            continue

        question_num = int(match.group(1))
        question_text = match.group(2).strip()

        # Determine question type: 1-16 = MCQ, 17-20 = Scenario
        question_type = "mcq" if question_num <= 16 else "scenario"

        # Extract options A, B, C, D
        # Pattern to match options like "A) text" or "A) text\nB) text"
        options = []
        option_pattern = r'[A-D]\)\s+(.+?)(?=\n\s*[A-D]\)|$)'
        for letter_match in re.finditer(r'([A-D])\)\s+', block):
            letter = letter_match.group(1)
            letter_pos = letter_match.end()

            # Find text until next option or end
            next_option = re.search(r'\n\s*[A-D]\)', block[letter_pos:])
            if next_option:
                option_text = block[letter_pos:letter_pos + next_option.start()].strip()
            else:
                option_text = block[letter_pos:].strip()

            # Remove "Answer Key:" section if present
            if "Answer Key:" in option_text:
                option_text = option_text.split("Answer Key:")[0].strip()

            if option_text:
                options.append({
                    "letter": letter,
                    "option_text": option_text,
                    "is_correct": False,  # Will be marked during validation
                    "order_number": ord(letter) - ord('A')  # 0=A, 1=B, 2=C, 3=D
                })

        # If we have exactly 4 options, add the question
        if len(options) == 4:
            questions.append({
                "order_number": question_num,
                "question_type": question_type,
                "question_text": question_text,
                "options": options,
                "module_id": module_id
            })
        else:
            if len(options) > 0:  # Only warn if we found some options but not 4
                print(f"⚠ {module_id} Q{question_num}: Expected 4 options, found {len(options)}")

    return questions

def main():
    """Main extraction flow."""
    all_quizzes = {}

    print("Fetching Google Docs...\n")

    for module_id, url in GOOGLE_DOCS.items():
        content = fetch_google_doc(module_id, url)
        if content:
            questions = parse_questions(content, module_id)
            all_quizzes[module_id] = {
                "module_id": module_id,
                "total_questions": len(questions),
                "mcq_count": len([q for q in questions if q["question_type"] == "mcq"]),
                "scenario_count": len([q for q in questions if q["question_type"] == "scenario"]),
                "questions": questions
            }
            print(f"✓ Parsed {module_id}: {len(questions)} questions")
        else:
            all_quizzes[module_id] = {
                "module_id": module_id,
                "total_questions": 0,
                "questions": [],
                "error": "Failed to fetch"
            }

    # Save to JSON
    output_file = "extracted_quizzes.json"
    with open(output_file, 'w') as f:
        json.dump(all_quizzes, f, indent=2)

    print(f"\n✓ Saved to {output_file}")

    # Summary
    print("\n=== EXTRACTION SUMMARY ===")
    total_q = sum(q["total_questions"] for q in all_quizzes.values())
    total_mcq = sum(q["mcq_count"] for q in all_quizzes.values())
    total_scenario = sum(q["scenario_count"] for q in all_quizzes.values())
    print(f"Total Questions: {total_q}")
    print(f"MCQs: {total_mcq}")
    print(f"Scenarios: {total_scenario}")

if __name__ == "__main__":
    main()
