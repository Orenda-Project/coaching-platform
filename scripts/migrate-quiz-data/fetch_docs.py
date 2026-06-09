#!/usr/bin/env python3
"""
Fetch quiz data from 6 Google Docs and parse into structured JSON.
FINAL VERSION: Handles multi-line and single-line option formats.
"""

import json
import re
from typing import Dict, List, Any, Tuple
import urllib.request
import urllib.error

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
    """Parse answer key: '1-B, 2-B, 3-C' → {1: 'B', 2: 'B', 3: 'C'}"""
    answer_map = {}
    if not answer_key_str:
        return answer_map
    pattern = r'(\d+)\s*-\s*([A-D])'
    for question_num_str, answer_letter in re.findall(pattern, answer_key_str, re.IGNORECASE):
        answer_map[int(question_num_str)] = answer_letter.upper()
    return answer_map


def extract_options(block: str) -> List[Tuple[str, str]]:
    """
    Extract options from a question block.
    Handles: "A) option" and "* A) option" and inline "A) opt B) opt C) opt D) opt"
    Returns: [(letter, option_text), ...]
    """
    options = []

    # Try multi-line pattern first: \n followed by optional *, then A-D
    multiline_pattern = r'\n\s*\*?\s*([A-D])\)\s*(.+?)(?=\n\s*\*?\s*[A-D]\)|$)'
    multiline_matches = list(re.finditer(multiline_pattern, block, re.DOTALL))

    if len(multiline_matches) == 4:
        # Multiline format works
        for match in multiline_matches:
            letter = match.group(1).upper()
            option_text = match.group(2).strip()
            options.append((letter, option_text))
    else:
        # Try inline pattern: " A) text B) text C) text D) text"
        # This handles options on the same line as question
        inline_pattern = r'([A-D])\)\s*([^A-D]*?)(?=[A-D]\)|$)'
        inline_matches = list(re.finditer(inline_pattern, block))

        if len(inline_matches) >= 4:
            for match in inline_matches[:4]:
                letter = match.group(1).upper()
                option_text = match.group(2).strip()
                # Clean up text
                option_text = re.sub(r'^\s*\*\s*', '', option_text)  # Remove leading asterisk
                option_text = re.sub(r'\s+$', '', option_text)  # Remove trailing whitespace
                options.append((letter, option_text))

    return options


def parse_section(section_text: str, module_id: str, section_name: str, question_type: str) -> Tuple[List[Dict[str, Any]], str]:
    """Parse a section (MCQ or Scenario) and return questions + section header"""
    questions = []

    # Extract section header
    header_match = re.search(r'(UNIT\s+[\d.]+[^\n]*)', section_text)
    section_header = header_match.group(1) if header_match else section_name

    # Extract answer key
    answer_key_match = re.search(r'Answer\s+[Kk]ey\s*:?\s*([^\n]+)', section_text)
    answer_key_str = answer_key_match.group(1) if answer_key_match else ""
    answer_map = parse_answer_key(answer_key_str)

    # Split by question number - handle both "1. " and "1) "
    question_blocks = re.split(r'\n\s*(?=\d+[.)])', section_text)

    order_number = 0
    for block in question_blocks:
        if not block.strip():
            continue

        # Extract question number and text (up to first option)
        q_match = re.match(r'(\d+)[.)] \s*(.+?)(?=[A-D]\)|$)', block, re.DOTALL)
        if not q_match:
            continue

        question_num = int(q_match.group(1))
        question_text = q_match.group(2).strip()

        # Extract options
        options_list = extract_options(block)

        if len(options_list) == 4:
            options = []
            for opt_idx, (letter, option_text) in enumerate(options_list):
                # Remove answer key markers
                option_text = re.sub(r'\s*(?:Answer|answer)[s]?\s*:.*$', '', option_text, flags=re.DOTALL)
                option_text = option_text.strip()

                # Determine if correct
                is_correct = (letter == answer_map.get(question_num, ''))

                options.append({
                    "letter": letter,
                    "option_text": option_text,
                    "is_correct": is_correct,
                    "order_number": opt_idx
                })

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
            print(f"⚠ {module_id} {section_header} Q{question_num}: Expected 4 options, found {len(options_list)}")

    return questions, section_header


def parse_module(content: str, module_id: str) -> Dict[str, Any]:
    """Parse entire module into MCQ and scenario questions"""

    module_data = {
        "module_id": module_id,
        "questions": [],
        "sections": {},
        "total_questions": 0,
        "mcq_count": 0,
        "scenario_count": 0
    }

    # === PARSE MCQ SECTIONS ===
    mcq_blocks = re.split(r'Multiple\s+Choice\s+Questions?\s*\(\s*MCQs?\s*\)\s*:\s*', content, flags=re.IGNORECASE)

    for block_idx, mcq_block in enumerate(mcq_blocks[1:]):
        # Find end of MCQ section
        mcq_end_match = re.search(r'(Answer\s+[Kk]ey[^\n]*(?:\n[^\n]*)*?)\n_{4,}|(?=Scenario|Senerio)', mcq_block, re.IGNORECASE)
        if mcq_end_match:
            mcq_section = mcq_block[:mcq_end_match.end()]
        else:
            scenario_match = re.search(r'(?=Scenario|Senerio)', mcq_block, re.IGNORECASE)
            mcq_section = mcq_block[:scenario_match.start()] if scenario_match else mcq_block

        # Parse MCQ section
        questions, section_header = parse_section(mcq_section, module_id, f"MCQ_Section_{block_idx}", "mcq")
        module_data["questions"].extend(questions)
        module_data["mcq_count"] += len(questions)
        if section_header not in module_data["sections"]:
            module_data["sections"][section_header] = {"mcq_count": 0, "scenario_count": 0}
        module_data["sections"][section_header]["mcq_count"] += len(questions)

    # === PARSE SCENARIO SECTIONS ===
    scenario_blocks = re.split(r'(?:Scenario\s+base\s+)?Scenario[s]?\s+(?:based\s+)?Questions?\s*\n', content, flags=re.IGNORECASE)

    if len(scenario_blocks) > 1:
        scenario_text = '\n'.join(scenario_blocks[1:])
        questions, section_header = parse_section(scenario_text, module_id, "Scenarios", "scenario")
        module_data["questions"].extend(questions)
        module_data["scenario_count"] += len(questions)
        if section_header not in module_data["sections"]:
            module_data["sections"][section_header] = {"mcq_count": 0, "scenario_count": 0}
        module_data["sections"][section_header]["scenario_count"] += len(questions)

    module_data["total_questions"] = len(module_data["questions"])
    return module_data


def main():
    """Main extraction flow"""
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
        else:
            all_modules[module_id] = {
                "module_id": module_id,
                "total_questions": 0,
                "questions": [],
                "error": "Failed to fetch"
            }
            print(f"✗ Failed to parse {module_id}")

    # Save to JSON
    with open("extracted_quizzes.json", 'w') as f:
        json.dump(all_modules, f, indent=2)

    print(f"\n✓ Saved to extracted_quizzes.json")

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

    total_with_keys = sum(
        len([q for q in m['questions'] if q.get('has_correct_answer', False)])
        for m in all_modules.values()
    )
    print(f"\nQuestions with answer keys: {total_with_keys}/{total_q}")


if __name__ == "__main__":
    main()
