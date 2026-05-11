import os
import sys
import tempfile
import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'scripts'))
from intent_utils import (
    load_test_map,
    is_directory_domain,
    parse_scope_from_intent,
    parse_scope_from_domain,
    discover_feature_files,
)


def write_tmp(content, suffix=''):
    f = tempfile.NamedTemporaryFile(mode='w', suffix=suffix, delete=False)
    f.write(content)
    f.close()
    return f.name


def test_load_test_map():
    path = write_tmp("features:\n  auth: tests/features/auth/\n  obs: tests/features/obs.intent\n", '.yml')
    result = load_test_map(path)
    assert result == {'auth': 'tests/features/auth/', 'obs': 'tests/features/obs.intent'}
    os.unlink(path)


def test_is_directory_domain_trailing_slash():
    assert is_directory_domain('tests/features/auth/') is True


def test_is_directory_domain_no_slash():
    assert is_directory_domain('tests/features/auth.intent') is False


def test_is_directory_domain_real_dir(tmp_path):
    assert is_directory_domain(str(tmp_path)) is True


def test_parse_scope_from_domain(tmp_path):
    scope = tmp_path / '.scope'
    scope.write_text('# comment\nsrc/pages/Login.tsx\n\nsrc/contexts/AuthContext.tsx\n')
    result = parse_scope_from_domain(str(tmp_path))
    assert result == ['src/pages/Login.tsx', 'src/contexts/AuthContext.tsx']


def test_parse_scope_from_domain_missing(tmp_path):
    result = parse_scope_from_domain(str(tmp_path / 'nonexistent'))
    assert result == []


def test_parse_scope_from_intent():
    content = "Title: Auth\n\nScope:\n  src/pages/Login.tsx\n  src/contexts/AuthContext.tsx\n\nGherkin:\n  Feature: Login\n"
    path = write_tmp(content, '.intent')
    result = parse_scope_from_intent(path)
    assert 'src/pages/Login.tsx' in result
    assert 'src/contexts/AuthContext.tsx' in result
    os.unlink(path)


def test_parse_scope_from_intent_missing():
    result = parse_scope_from_intent('/nonexistent/path.intent')
    assert result == []


def test_discover_feature_files(tmp_path):
    (tmp_path / 'login.feature').write_text('Feature: Login')
    (tmp_path / 'signup.feature').write_text('Feature: Signup')
    (tmp_path / 'notes.txt').write_text('ignore')
    result = discover_feature_files(str(tmp_path))
    assert len(result) == 2
    assert all(f.endswith('.feature') for f in result)
