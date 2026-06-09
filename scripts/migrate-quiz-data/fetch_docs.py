#!/usr/bin/env python3
"""
Fetch quiz data from 6 Google Docs and parse into structured JSON.
CORRECTED VERSION:
- Proper order_number assignment (unique per question)
- Correct scenario detection
- Captures answer keys (is_correct based on key)
- Removes answer-key text leakage from options
"""

import json
import re
from typing import Dict, List, Any, Tuple
import urllib.request
import urllib.error

# Google Docs export URLs
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


def parse_answer_key(answer_key_str: str) -> Dict[int, str]:
    """
    Parse answer key string like "1-B, 2-B, 3-C, 4-A" into {1: 'B', 2: 'B', ...}
    """
    answer_map = {}
    if not answer_key_str:
        return answer_map

    # Match pattern like "1-B" or "1-B,"
    pattern = r'(\d+)\s*-\s*([A-D])'
    matches = re.findall(pattern, answer_key_str, re.IGNORECASE)

    for question_num_str, answer_letter in matches:
        question_num = int(question_num_str)
        answer_map[question_num] = answer_letter.upper()

    return answer_map


def parse_section(section_text: str, module_id: str, section_name: str, question_type: str) -> Tuple[List[Dict[str, Any]], str]:
    """
    Parse a section (MCQ or Scenario) and return list of questions + section header
    Returns: (questions_list, section_header_text)
    """
    questions = []

    # Extract section header (e.g., "UNIT 1.0: THE COACHING CATALYST")
    header_match = re.search(r'(UNIT\s+[\d.]+[^\n]*)', section_text)
    section_header = header_match.group(1) if header_match else section_name

    # Extract answer key from end of section
    answer_key_match = re.search(r'Answer\s+[Kk]ey\s*:?\s*([^\n]+)', section_text)
    answer_key_str = answer_key_match.group(1) if answer_key_match else ""
    answer_map = parse_answer_key(answer_key_str)

    # Split by question number (e.g., "1. Question text" or "1) Question text")
    # Pattern: line starts with optional whitespace, digit(s), then period or parenthesis
    question_blocks = re.split(r'\n\s*(?=\d+[.)])', section_text)

    order_number = 0
    for block in question_blocks:
        if not block.strip():
            continue

        # Extract question number and question text
        q_match = re.match(r'(\d+)[.)] \s*(.+?)(?=\n[A-D][\))]|$)', block, re.DOTALL)
        if not q_match:
            continue

        question_num = int(q_match.group(1))
        question_text = q_match.group(2).strip()

        # Extract options A, B, C, D
        options = []
        option_pattern = r'[*\s]*([A-D])[)]\s*(.+?)(?=\n[A-D][)]\s|$)'
        option_matches = list(re.finditer(option_pattern, block, re.DOTALL))

        for opt_idx, opt_match in enumerate(option_matches):
            letter = opt_match.group(1).upper()
            option_text = opt_match.group(2).strip()

            # Remove trailing "Answer Key" markers if present
            option_text = re.sub(r'\s*(?:Answer|answer|Answer key|answer key)[s]?\s*:.*$', '', option_text, flags=re.DOTALL)
            option_text = option_text.strip()

            # Determine if this is the correct answer
            is_correct = (letter == answer_map.get(question_num, ''))

            options.append({
                "letter": letter,
                "option_text": option_text,
                "is_correct": is_correct,
                "order_number": opt_idx  # 0=A, 1=B, 2=C, 3=D
            })

        # Only add if we have all 4 options
        if len(options) == 4:
            questions.append({
                "order_number": order_number,
                "question_number_in_section": question_num,
                "question_type": question_type,
                "question_text": question_text,
                "options": options,
                "section_header": section_header,
                "has_correct_answer": answer_map.get(question_num) is not None
            })
            order_number += 1
        else:
            print(f"⚠ {module_id} {section_header} Q{question_num}: Expected 4 options, found {len(options)}")

    return questions, section_header


def parse_module(content: str, module_id: str) -> Dict[str, Any]:
    """
    Parse entire module content into structured MCQ and scenario questions
    """

    module_data = {
        "module_id": module_id,
        "questions": [],
        "sections": {},
        "total_questions": 0,
        "mcq_count": 0,
        "scenario_count": 0
    }

    # === PARSE MCQ SECTIONS ===
    # Split by "Multiple Choice Questions (MCQs):" or "Multiple Choice Questions:" markers
    mcq_blocks = re.split(r'Multiple\s+Choice\s+Questions?\s*\(\s*MCQs?\s*\)\s*:\s*', content, flags=re.IGNORECASE)

    for block_idx, mcq_block in enumerate(mcq_blocks[1:]):  # Skip first split (before any MCQ marker)
        # Find the end of this MCQ section (either "Answer key" followed by separator, or scenario marker)
        mcq_end_match = re.search(r'(Answer\s+[Kk]ey[^\n]*(?:\n[^\n]*)*?)\n_{4,}|(?=Scenario|Senerio)', mcq_block, re.IGNORECASE)
        if mcq_end_match:
            mcq_section = mcq_block[:mcq_end_match.end()]
        else:
            # Take everything up to scenario or end
            scenario_match = re.search(r'(?=Scenario|Senerio)', mcq_block, re.IGNORECASE)
            if scenario_match:
                mcq_section = mcq_block[:scenario_match.start()]
            else:
                mcq_section = mcq_block

        # Parse MCQ questions from this section
        questions, section_header = parse_section(mcq_section, module_id, f"MCQ_Section_{block_idx}", "mcq")
        module_data["questions"].extend(questions)
        module_data["mcq_count"] += len(questions)
        if section_header not in module_data["sections"]:
            module_data["sections"][section_header] = {"mcq_count": 0, "scenario_count": 0}
        module_data["sections"][section_header]["mcq_count"] += len(questions)

    # === PARSE SCENARIO SECTIONS ===
    # Split by "Scenario" or "Senerio" (note: typo in some docs)
    scenario_blocks = re.split(r'(?:Scenario\s+base\s+)?Scenario[s]?\s+(?:based\s+)?Questions?\s*\n', content, flags=re.IGNORECASE)

    if len(scenario_blocks) > 1:
        # Combine all scenario text
        scenario_text = '\n'.join(scenario_blocks[1:])

        # Parse scenario questions
        questions, section_header = parse_section(scenario_text, module_id, "Scenarios", "scenario")
        module_data["questions"].extend(questions)
        module_data["scenario_count"] += len(questions)
        if section_header not in module_data["sections"]:
            module_data["sections"][section_header] = {"mcq_count": 0, "scenario_count": 0}
        module_data["sections"][section_header]["scenario_count"] += len(questions)

    module_data["total_questions"] = len(module_data["questions"])

    return module_data


def main():
    """Main extraction flow."""
    all_modules = {}

    print("Fetching and parsing Google Docs...\n")

    for module_id, url in GOOGLE_DOCS.items():
        content = fetch_google_doc(module_id, url)
        if content:
            module_data = parse_module(content, module_id)
            all_modules[module_id] = module_data

            print(f"✓ Parsed {module_id}: {module_data['total_questions']} questions")
            print(f"  - MCQs: {module_data['mcq_count']}")
            print(f"  - Scenarios: {module_data['scenario_count']}")
            print(f"  - Sections: {len(module_data['sections'])}")

            # Verify order_number uniqueness per section
            order_numbers_per_section = {}
            for q in module_data['questions']:
                section = q.get('section_header', 'unknown')
                if section not in order_numbers_per_section:
                    order_numbers_per_section[section] = []
                order_numbers_per_section[section].append(q['order_number'])

            for section, orders in order_numbers_per_section.items():
                if len(orders) != len(set(orders)):
                    print(f"  ⚠ {section}: order_number collision detected")
        else:
            all_modules[module_id] = {
                "module_id": module_id,
                "total_questions": 0,
                "questions": [],
                "error": "Failed to fetch"
            }
            print(f"✗ Failed to parse {module_id}")

    # Save to JSON
    output_file = "extracted_quizzes.json"
    with open(output_file, 'w') as f:
        json.dump(all_modules, f, indent=2)

    print(f"\n✓ Saved to {output_file}")

    # Summary
    print("\n=== EXTRACTION SUMMARY ===")
    total_q = sum(m["total_questions"] for m in all_modules.values())
    total_mcq = sum(m["mcq_count"] for m in all_modules.values())
    total_scenario = sum(m["scenario_count"] for m in all_modules.values())

    print(f"Total Questions: {total_q}")
    print(f"MCQs: {total_mcq}")
    print(f"Scenarios: {total_scenario}")
    print(f"\nBreakdown by Module:")
    for module_id, data in all_modules.items():
        print(f"  {module_id}: {data['total_questions']} questions ({data['mcq_count']} MCQ + {data['scenario_count']} scenario)")

    # Verify answer keys
    total_with_keys = sum(
        len([q for q in m['questions'] if q.get('has_correct_answer', False)])
        for m in all_modules.values()
    )
    print(f"\nQuestions with answer keys: {total_with_keys}/{total_q}")


if __name__ == "__main__":
    main()
