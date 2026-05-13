import os
import sys
import argparse

sys.path.insert(0, os.path.dirname(__file__))
from intent_utils import (
    load_test_map,
    is_directory_domain,
    parse_scope_from_domain,
    parse_scope_from_intent,
)


def get_changed_files(args) -> list:
    if args.files:
        return [f.strip() for f in args.files if f.strip()]
    env_files = os.environ.get('CHANGED_FILES', '')
    if env_files:
        return [f.strip() for f in env_files.replace('\n', ' ').split() if f.strip()]
    return [line.strip() for line in sys.stdin if line.strip()]


def file_matches_scope(changed_file: str, scope_path: str) -> bool:
    cf = changed_file.lstrip('./')
    sp = scope_path.lstrip('./')
    return cf == sp or cf.startswith(sp)


def match_features(features_map: dict, changed_files: list) -> list:
    matched = []
    for feature_name, entry_path in features_map.items():
        if is_directory_domain(entry_path):
            scope_paths = parse_scope_from_domain(entry_path)
        else:
            scope_paths = parse_scope_from_intent(entry_path)
        for scope_path in scope_paths:
            if any(file_matches_scope(cf, scope_path) for cf in changed_files):
                matched.append(feature_name)
                break
    return matched


def write_github_output(matched: list) -> None:
    lines = [
        f"matched_features={','.join(matched)}",
        f"has_matches={'true' if matched else 'false'}",
    ]
    for line in lines:
        print(line)
    output_path = os.environ.get('GITHUB_OUTPUT')
    if output_path:
        with open(output_path, 'a') as f:
            for line in lines:
                f.write(line + '\n')


def main():
    parser = argparse.ArgumentParser(description='Match changed files to IDD feature domains')
    parser.add_argument('--test-map', required=True, help='Path to test-map.yml')
    parser.add_argument('--files', nargs='*', default=None, help='Changed file paths')
    args = parser.parse_args()

    features_map = load_test_map(args.test_map)
    changed_files = get_changed_files(args)
    matched = match_features(features_map, changed_files)
    write_github_output(matched)
    sys.exit(0)


if __name__ == '__main__':
    main()
