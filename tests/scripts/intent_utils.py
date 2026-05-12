import os
import glob
import yaml


def load_test_map(path: str) -> dict:
    with open(path, 'r') as f:
        data = yaml.safe_load(f)
    return data.get('features', {})


def is_directory_domain(entry_path: str) -> bool:
    return entry_path.endswith('/') or os.path.isdir(entry_path)


def parse_scope_from_intent(intent_path: str) -> list:
    try:
        with open(intent_path, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        return []
    in_scope = False
    result = []
    for line in lines:
        stripped = line.rstrip('\n')
        if stripped.strip() == 'Scope:':
            in_scope = True
            continue
        if in_scope:
            if stripped and not stripped[0].isspace() and ':' in stripped:
                break
            val = stripped.strip()
            if val:
                result.append(val)
    return result


def parse_scope_from_domain(domain_dir: str) -> list:
    scope_path = os.path.join(domain_dir.rstrip('/'), '.scope')
    try:
        with open(scope_path, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        return []
    return [
        line.strip()
        for line in lines
        if line.strip() and not line.strip().startswith('#')
    ]


def discover_feature_files(domain_dir: str) -> list:
    pattern = os.path.join(domain_dir.rstrip('/'), '*.feature')
    return sorted(glob.glob(pattern))
