"""Integration tests run against a real PostgreSQL created by db/init scripts.

Required env vars (the docker-compose `db` service provides the server):
    TEST_DATABASE_URL            ponga_app role
    TEST_MIGRATION_DATABASE_URL  ponga_owner role
    TEST_READONLY_DATABASE_URL   ponga_readonly role (optional)
"""

from __future__ import annotations

import os

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import text

from app.db import Database, make_engine
from app.main import create_app
from tests.conftest import make_settings

APP_URL = os.getenv("TEST_DATABASE_URL")
OWNER_URL = os.getenv("TEST_MIGRATION_DATABASE_URL")
RO_URL = os.getenv("TEST_READONLY_DATABASE_URL")

pytestmark = pytest.mark.integration


def pytest_collection_modifyitems(config, items):
    if APP_URL and OWNER_URL:
        return
    skip = pytest.mark.skip(reason="TEST_DATABASE_URL / TEST_MIGRATION_DATABASE_URL not set")
    for item in items:
        if "integration" in str(item.fspath):
            item.add_marker(skip)


@pytest.fixture(scope="session")
def pg_settings():
    return make_settings(APP_URL, migration_database_url=OWNER_URL)


@pytest.fixture(scope="session", autouse=True)
def _schema(pg_settings):
    owner = Database(pg_settings.migration_database_url)
    owner.create_schema()
    owner.engine.dispose()


@pytest.fixture(autouse=True)
def clean_tables():
    engine = make_engine(OWNER_URL)
    with engine.begin() as conn:
        conn.execute(text("TRUNCATE matches, players, users RESTART IDENTITY CASCADE"))
    engine.dispose()
    yield


@pytest.fixture
def pg_database(pg_settings):
    db = Database(pg_settings.database_url)
    yield db
    db.engine.dispose()


@pytest.fixture
def pg_client(pg_settings, pg_database):
    with TestClient(create_app(pg_settings, pg_database)) as c:
        yield c
