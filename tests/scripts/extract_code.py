import os
import sys
import argparse

sys.path.insert(0, os.path.dirname(__file__))
from intent_utils import (
    load_test_map,
    is_directory_domain,
    parse_scope_from_domain,
    parse_scope_from_intent,
    discover_feature_files,
)

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
_SKIP_PATTERNS = ('.spec.', '.test.', '.map.')
_EXTENSIONS = ('.py', '.ts', '.tsx', '.js', '.jsx')


def collect_file_paths(scope_paths: list) -> list:
    result = []
    for scope_path in scope_paths:
        abs_path = os.path.join(REPO_ROOT, scope_path)
        if os.path.isdir(abs_path):
            for root, _, files in os.walk(abs_path):
                for fname in sorted(files):
                    if fname.endswith(_EXTENSIONS) and not any(p in fname for p in _SKIP_PATTERNS):
                        result.append(os.path.relpath(os.path.join(root, fname), REPO_ROOT))
        elif os.path.isfile(abs_path):
            result.append(scope_path)
    return result


def extract_feature_bundle(feature_name: str, entry_path: str) -> str:
    abs_entry = os.path.join(REPO_ROOT, entry_path.rstrip('/'))
    if is_directory_domain(entry_path):
        feature_files = discover_feature_files(abs_entry)
        feature_text = '\n\n'.join(
            open(ff, 'r', encoding='utf-8').read() for ff in feature_files
        )
        scope_paths = parse_scope_from_domain(abs_entry)
    else:
        with open(abs_entry, 'r', encoding='utf-8') as f:
            feature_text = f.read()
        scope_paths = parse_scope_from_intent(abs_entry)

    source_paths = collect_file_paths(scope_paths)

    lines = ['=== FEATURE FILE(S) ===', feature_text, '', '=== SOURCE FILES ===']
    for rel_path in source_paths:
        abs_path = os.path.join(REPO_ROOT, rel_path)
        try:
            with open(abs_path, 'r', encoding='utf-8', errors='replace') as f:
                content = f.read()
            lines.append(f'\n--- {rel_path} ---\n{content}')
        except OSError as e:
            lines.append(f'\n--- {rel_path} --- [ERROR: {e}]')
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description='Bundle feature + source files for inspection')
    parser.add_argument('--feature', required=True)
    parser.add_argument('--test-map', required=True)
    parser.add_argument('--output', default=None)
    args = parser.parse_args()

    features_map = load_test_map(args.test_map)
    entry_path = features_map.get(args.feature)
    if not entry_path:
        print(f'ERROR: Feature "{args.feature}" not in test-map', file=sys.stderr)
        sys.exit(1)

    bundle = extract_feature_bundle(args.feature, entry_path)

    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(bundle)
        print(f'Written to {args.output}')
    else:
        print(bundle)


if __name__ == '__main__':
    main()
