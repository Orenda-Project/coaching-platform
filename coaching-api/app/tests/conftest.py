"""Shared pytest fixtures and configuration."""

import pytest
import sys
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool
from sqlalchemy.types import TypeDecorator, String

# Monkey-patch ARRAY type BEFORE any imports from app
original_ARRAY = None
try:
    from sqlalchemy import ARRAY as original_ARRAY
except ImportError:
    pass


class TestARRAY(TypeDecorator):
    """SQLite-compatible ARRAY type for testing."""
    impl = String
    cache_ok = True


# Patch sqlalchemy.ARRAY before any app imports
import sqlalchemy
sqlalchemy.ARRAY = TestARRAY


@pytest.fixture(scope="function")
def test_db() -> Session:
    """Create a test database session with in-memory SQLite."""
    from app.database import Base, get_db
    from app.main import app

    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )

    # Create tables
    Base.metadata.create_all(bind=engine)

    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db

    db = TestingSessionLocal()
    yield db
    db.close()

    app.dependency_overrides.clear()
