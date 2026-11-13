"""Runtime configuration, read from environment variables."""

from __future__ import annotations

import os
from dataclasses import dataclass, field


def _env(name: str, default: str | None = None) -> str:
    value = os.getenv(name, default)
    if value is None:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


@dataclass(frozen=True)
class Settings:
    # Runtime connection (DML-only role).
    database_url: str = field(default_factory=lambda: _env("DATABASE_URL", "sqlite:///./ponga.db"))
    # Connection used to create/upgrade the schema (owner role). Falls back to
    # DATABASE_URL so local SQLite development works with one variable.
    migration_database_url: str = field(
        default_factory=lambda: os.getenv("MIGRATION_DATABASE_URL")
        or _env("DATABASE_URL", "sqlite:///./ponga.db")
    )
    db_schema: str | None = field(default_factory=lambda: os.getenv("DB_SCHEMA") or None)
    secret_key: str = field(default_factory=lambda: _env("SECRET_KEY", "dev-secret-change-me"))
    token_ttl_minutes: int = field(default_factory=lambda: int(_env("TOKEN_TTL_MINUTES", "120")))
    admin_username: str = field(default_factory=lambda: _env("ADMIN_USERNAME", "admin"))
    admin_password: str = field(default_factory=lambda: _env("ADMIN_PASSWORD", "admin"))
    elo_k_factor: int = field(default_factory=lambda: int(_env("ELO_K_FACTOR", "32")))


def get_settings() -> Settings:
    return Settings()
