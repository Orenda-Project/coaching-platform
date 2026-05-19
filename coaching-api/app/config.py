import os
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application configuration from environment variables."""

    # Database
    database_url: str = os.getenv(
        "DATABASE_URL",
        "postgresql://postgres:postgres@localhost:5432/coaching_content"
    )

    # API
    api_version: str = "1.0"
    api_title: str = "Coaching Platform Content Export API"
    api_description: str = "Extract training content from coaching platform for internal teams"

    # Logging
    log_level: str = os.getenv("LOG_LEVEL", "info")

    # Environment
    environment: str = os.getenv("ENVIRONMENT", "development")

    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()
