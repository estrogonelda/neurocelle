import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError, IntegrityError

from app.db import make_engine
from app.models import Match
from tests.conftest import ADMIN, login
from tests.integration.conftest import RO_URL

pytestmark = pytest.mark.integration


def test_connected_as_app_role_in_ponga_schema(pg_database):
    with pg_database.engine.connect() as conn:
        assert conn.scalar(text("SELECT current_user")) == "ponga_app"
        assert conn.scalar(text("SELECT current_schema()")) == "ponga"


def test_tables_exist(pg_database):
    with pg_database.engine.connect() as conn:
        names = set(
            conn.scalars(
                text("SELECT table_name FROM information_schema.tables WHERE table_schema='ponga'")
            )
        )
    assert {"users", "players", "matches"} <= names


def test_app_role_cannot_run_ddl(pg_database):
    with pg_database.engine.connect() as conn, pytest.raises(DBAPIError, match="permission"):
        conn.execute(text("CREATE TABLE ponga.nope (id int)"))


@pytest.mark.skipif(not RO_URL, reason="TEST_READONLY_DATABASE_URL not set")
def test_readonly_role():
    engine = make_engine(RO_URL)
    with engine.connect() as conn:
        assert conn.scalar(text("SELECT count(*) FROM players")) == 0
        with pytest.raises(DBAPIError, match="permission denied"):
            conn.execute(
                text(
                    "INSERT INTO users (username, password_hash, is_admin) "
                    "VALUES ('x', 'y', false)"
                )
            )
    engine.dispose()


def test_check_constraint_enforced_by_db(pg_client, pg_database):
    h = login(pg_client, *ADMIN)
    a = pg_client.post("/api/players", headers=h, json={"name": "A"}).json()["id"]
    with pg_database.SessionLocal() as s:
        s.add(Match(player1_id=a, player2_id=a, score1=11, score2=0, winner_id=a))
        with pytest.raises(IntegrityError):
            s.commit()


def test_full_api_flow_on_postgres(pg_client):
    h = login(pg_client, *ADMIN)
    assert pg_client.get("/api/health").json()["database"] == "ok"
    ids = [
        pg_client.post("/api/players", headers=h, json={"name": n}).json()["id"]
        for n in ("Ana", "Bruno", "Carla")
    ]
    games = [(0, 1, 11, 4), (1, 2, 13, 11), (2, 0, 8, 11), (0, 2, 11, 9)]
    for i, j, s1, s2 in games:
        r = pg_client.post(
            "/api/matches",
            headers=h,
            json={"player1_id": ids[i], "player2_id": ids[j], "score1": s1, "score2": s2},
        )
        assert r.status_code == 201, r.text
    board = pg_client.get("/api/leaderboard").json()
    assert board[0]["name"] == "Ana" and board[0]["wins"] == 3
    assert sum(row["rating"] for row in board) == 3000
    assert len(pg_client.get("/api/matches").json()) == len(games)
    assert pg_client.delete(f"/api/players/{ids[0]}", headers=h).status_code == 409


def test_populate_script_on_postgres(monkeypatch, pg_settings):
    from scripts import populate_db

    monkeypatch.setenv("DATABASE_URL", pg_settings.database_url)
    monkeypatch.setenv("MIGRATION_DATABASE_URL", pg_settings.migration_database_url)
    if RO_URL:
        monkeypatch.setenv("READONLY_DATABASE_URL", RO_URL)
    assert populate_db.main(["--reset"]) == 0
