from sqlalchemy import create_engine
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import declarative_base, sessionmaker
from app.config import settings

# Synchronous engine for Alembic migrations
engine = create_engine(
    settings.database_url,
    echo=False,
)

# Async engine for API (optional, for future async support)
async_engine = create_async_engine(
    settings.database_url.replace("postgresql://", "postgresql+asyncpg://"),
    echo=False,
)

# Session factory
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

# Base class for ORM models
Base = declarative_base()


def get_db():
    """Dependency: get database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
