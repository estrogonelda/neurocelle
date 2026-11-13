from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from app.core.config import Settings
from app.db import Database
from app.main import create_app

ADMIN = ("admin", "admin-pass")


def make_settings(url: str, **overrides) -> Settings:
    values = dict(
        database_url=url,
        migration_database_url=url,
        db_schema=None,
        secret_key="test-secret",
        token_ttl_minutes=5,
        admin_username=ADMIN[0],
        admin_password=ADMIN[1],
        elo_k_factor=32,
    )
    values.update(overrides)
    return Settings(**values)


def login(client: TestClient, username: str, password: str) -> dict[str, str]:
    r = client.post("/api/auth/login", json={"username": username, "password": password})
    assert r.status_code == 200, r.text
    return {"Authorization": f"Bearer {r.json()['access_token']}"}


@pytest.fixture
def settings() -> Settings:
    return make_settings("sqlite://")


@pytest.fixture
def database(settings) -> Database:
    db = Database(settings.database_url)
    db.create_schema()
    yield db
    db.engine.dispose()


@pytest.fixture
def client(settings, database):
    with TestClient(create_app(settings, database)) as c:
        yield c


@pytest.fixture
def admin_headers(client):
    return login(client, *ADMIN)


@pytest.fixture
def session(database):
    with database.SessionLocal() as s:
        yield s
