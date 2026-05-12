import os
import sys
import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'scripts'))

_SCOPE_DATA = {
    'tests/features/login/': ['src/pages/Login.tsx', 'src/contexts/AuthContext.tsx'],
    'tests/features/baseline-assessment/': ['src/pages/Assessment.tsx'],
}


def _fake_scope(domain_dir):
    return _SCOPE_DATA.get(domain_dir.rstrip('/') + '/', [])


# Import and patch before importing match_features
import intent_utils as _iu
_iu.parse_scope_from_domain = _fake_scope

from match_features import file_matches_scope, match_features


FEATURES_MAP = {
    'login': 'tests/features/login/',
    'baseline': 'tests/features/baseline-assessment/',
}


def test_file_matches_scope_exact():
    assert file_matches_scope('src/pages/Login.tsx', 'src/pages/Login.tsx') is True


def test_file_matches_scope_prefix():
    assert file_matches_scope('src/pages/Login.tsx', 'src/pages/') is True


def test_file_matches_scope_no_match():
    assert file_matches_scope('src/pages/Signup.tsx', 'src/pages/Login.tsx') is False


def test_file_matches_scope_strips_dot_slash():
    assert file_matches_scope('./src/pages/Login.tsx', './src/pages/Login.tsx') is True


def test_match_features_hit():
    result = match_features(FEATURES_MAP, ['src/pages/Login.tsx'])
    assert 'login' in result
    assert 'baseline' not in result


def test_match_features_multiple():
    result = match_features(FEATURES_MAP, ['src/pages/Login.tsx', 'src/pages/Assessment.tsx'])
    assert set(result) == {'login', 'baseline'}


def test_match_features_no_match():
    result = match_features(FEATURES_MAP, ['src/components/unrelated/Foo.tsx'])
    assert result == []
