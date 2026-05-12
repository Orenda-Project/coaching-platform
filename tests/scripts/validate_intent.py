import os
import sys
import argparse
import subprocess
import tempfile
from datetime import datetime, timezone

sys.path.insert(0, os.path.dirname(__file__))
from intent_utils import (
    load_test_map,
    is_directory_domain,
    parse_scope_from_domain,
    parse_scope_from_intent,
    discover_feature_files,
)

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

IDD_SKILLS = [
    '.claude/skills/idd/gherkin-parser/SKILL.md',
    '.claude/skills/idd/scope-resolver/SKILL.md',
    '.claude/skills/idd/code-mapper/SKILL.md',
    '.claude/skills/idd/behavior-analyzer/SKILL.md',
    '.claude/skills/idd/scenario-validator/SKILL.md',
    '.claude/skills/idd/report-formatter/SKILL.md',
]

_SKIP_PATTERNS = ('.spec.', '.test.', '.map.')


def verify_skills_exist() -> None:
    missing = [
        p for p in IDD_SKILLS
        if not os.path.exists(os.path.join(REPO_ROOT, p))
    ]
    if missing:
        print('ERROR: Missing IDD skill files:')
        for p in missing:
            print(f'  {p}')
        sys.exit(1)


def _should_skip(path: str) -> bool:
    return any(pat in os.path.basename(path) for pat in _SKIP_PATTERNS)


def load_source_files(scope_paths: list) -> str:
    extensions = ('.py', '.ts', '.tsx', '.js', '.jsx')
    parts = []
    for scope_path in scope_paths:
        abs_path = os.path.join(REPO_ROOT, scope_path)
        if os.path.isdir(abs_path):
            for root, _, files in os.walk(abs_path):
                for fname in sorted(files):
                    if fname.endswith(extensions) and not _should_skip(fname):
                        fpath = os.path.join(root, fname)
                        rel = os.path.relpath(fpath, REPO_ROOT)
                        try:
                            with open(fpath, 'r', encoding='utf-8', errors='replace') as f:
                                content = f.read()
                            parts.append(f'\n\n=== {rel} ===\n{content}')
                        except OSError as e:
                            print(f'WARNING: could not read {rel}: {e}', file=sys.stderr)
        elif os.path.isfile(abs_path):
            rel = scope_path
            try:
                with open(abs_path, 'r', encoding='utf-8', errors='replace') as f:
                    content = f.read()
                parts.append(f'\n\n=== {rel} ===\n{content}')
            except OSError as e:
                print(f'WARNING: could not read {rel}: {e}', file=sys.stderr)
        else:
            print(f'WARNING: scope path not found: {scope_path}', file=sys.stderr)
    return ''.join(parts)


def build_idd_prompt(
    feature_content: str,
    scope_files_list: list,
    source_files_content: str,
    mode: str,
    feature_filename: str,
) -> str:
    scope_files_list_text = '\n'.join(scope_files_list)
    return f"""You are the IDD QA Validation Agent. Execute the following pipeline exactly.

## CRITICAL OUTPUT RULE

⛔ DO NOT OUTPUT ANYTHING until all 6 skills have completed.
⛔ DO NOT print skill steps, intermediate findings, tables, or analysis.
⛔ Your ENTIRE response must be ONLY the final markdown report from report-formatter.
⛔ No preamble. No "Step 1:", "Step 2:", no skill summaries. Nothing before the report.

If you output anything other than the final report, the CI pipeline will break.

## Instructions

Execute these 6 IDD skills silently IN ORDER. All reasoning is internal — never printed:
1. Read and execute (silently): .claude/skills/idd/gherkin-parser/SKILL.md
2. Read and execute (silently): .claude/skills/idd/scope-resolver/SKILL.md
3. Read and execute (silently): .claude/skills/idd/code-mapper/SKILL.md
4. Read and execute (silently): .claude/skills/idd/behavior-analyzer/SKILL.md
5. Read and execute (silently): .claude/skills/idd/scenario-validator/SKILL.md
6. Read and execute: .claude/skills/idd/report-formatter/SKILL.md → OUTPUT THIS ONLY

Apply all rules from .claude/rules/idd/ throughout (internally).
Your response = the report-formatter output and nothing else.

## Feature File

Feature: {feature_filename}
Mode hint: {mode} (detected from @chunk tags in feature content)

=== FEATURE FILE ===
{feature_content}
=== END FEATURE FILE ===

## Scope

The following files define the scope boundary for this feature:
=== SCOPE FILES ===
{scope_files_list_text}
=== END SCOPE FILES ===

## Source Code

=== SOURCE CODE ===
{source_files_content}
=== END SOURCE CODE ===
"""


def build_validation_prompt(feature_name: str, entry_path: str, test_map_path: str):
    if is_directory_domain(entry_path):
        abs_dir = os.path.join(REPO_ROOT, entry_path.rstrip('/'))
        feature_files = discover_feature_files(abs_dir)
        feature_content = '\n\n'.join(
            open(ff, 'r', encoding='utf-8').read() for ff in feature_files
        )
        scope_paths = parse_scope_from_domain(abs_dir)
        first_base = os.path.basename(feature_files[0]) if feature_files else 'unknown.feature'
        feature_filename = f'{feature_name}/{first_base}'
    else:
        abs_path = os.path.join(REPO_ROOT, entry_path)
        with open(abs_path, 'r', encoding='utf-8') as f:
            raw = f.read()
        # Extract GHERKIN: block
        if 'Gherkin:' in raw:
            feature_content = raw.split('Gherkin:', 1)[1].strip()
        else:
            feature_content = raw
        scope_paths = parse_scope_from_intent(abs_path)
        feature_filename = os.path.basename(entry_path)

    mode = 'chunk' if '@chunk' in feature_content else 'full'
    source_content = load_source_files(scope_paths)
    prompt = build_idd_prompt(feature_content, scope_paths, source_content, mode, feature_filename)
    return prompt, mode


def validate_with_agent(feature_name: str, entry_path: str, test_map_path: str) -> str:
    prompt, mode = build_validation_prompt(feature_name, entry_path, test_map_path)

    tmp = tempfile.NamedTemporaryFile(
        mode='w', suffix='.txt', delete=False, encoding='utf-8'
    )
    try:
        tmp.write(prompt)
        tmp.close()
        cmd = f'cat {tmp.name} | claude -p --allowedTools Read --output-format text --max-turns 15'
        result = subprocess.run(
            ['bash', '-c', cmd],
            cwd=REPO_ROOT,
            env=os.environ.copy(),
            capture_output=True,
            text=True,
            timeout=600,
        )
        if result.returncode != 0:
            err = result.stderr.strip()
            return f'**ERROR validating `{feature_name}`:**\n```\n{err}\n```'
        return result.stdout
    except subprocess.TimeoutExpired:
        return f'**TIMEOUT validating `{feature_name}` (>600s)**'
    except Exception as e:
        return f'**EXCEPTION validating `{feature_name}`: {e}**'
    finally:
        try:
            os.unlink(tmp.name)
        except OSError:
            pass


def build_report(
    validation_texts: list,
    pr_number: str,
    pr_title: str,
    run_url: str,
) -> str:
    timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')
    has_chunk = any('@chunk' in text for _, text in validation_texts)

    # Derive a short feature label for the header line
    feature_labels = ', '.join(f'`{name}`' for name, _ in validation_texts)
    chunk_note = '`@chunk` = deep validation · no `@chunk` = all scenarios · human QA still required'

    lines = [
        '<!-- github-actions-intent-validation-report -->',
        '## 🤖 GitHub Actions — Intent Validation Report',
        '',
        '## 🔍 Intent Validation',
        '',
        f'PR #{pr_number} · {pr_title} · Features {feature_labels} · {timestamp} · [logs]({run_url})',
        '',
        chunk_note,
        '',
    ]

    for feature_name, output in validation_texts:
        lines.append(output.strip())
        lines.append('')

    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description='Run IDD validation via Claude agent')
    parser.add_argument('--features', required=True, help='Comma-separated feature names')
    parser.add_argument('--test-map', required=True, help='Path to test-map.yml')
    parser.add_argument('--output-file', required=True, help='Output markdown path')
    parser.add_argument('--pr-number', default='', help='PR number')
    parser.add_argument('--pr-title', default='', help='PR title')
    parser.add_argument('--run-url', default='', help='GHA run URL')
    args = parser.parse_args()

    verify_skills_exist()

    features_map = load_test_map(args.test_map)
    feature_names = [f.strip() for f in args.features.split(',') if f.strip()]

    validation_texts = []
    for feature_name in feature_names:
        entry_path = features_map.get(feature_name)
        if not entry_path:
            validation_texts.append(
                (feature_name, f'**ERROR:** Feature `{feature_name}` not found in test-map.yml')
            )
            continue
        print(f'Validating feature: {feature_name}', flush=True)
        output = validate_with_agent(feature_name, entry_path, args.test_map)
        validation_texts.append((feature_name, output))

    report = build_report(validation_texts, args.pr_number, args.pr_title, args.run_url)

    with open(args.output_file, 'w', encoding='utf-8') as f:
        f.write(report)
    print(f'Report written to {args.output_file}')
    sys.exit(0)


if __name__ == '__main__':
    main()
