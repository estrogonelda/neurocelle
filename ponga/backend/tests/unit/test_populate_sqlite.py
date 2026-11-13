"""The populate script also works on SQLite (privilege checks are Postgres-only)."""

from scripts import populate_db


def test_populate_and_verify_sqlite(tmp_path, monkeypatch, capsys):
    url = f"sqlite:///{tmp_path / 'p.db'}"
    from app.db import Database

    Database(url).create_schema()
    monkeypatch.setenv("DATABASE_URL", url)
    assert populate_db.main([]) == 0
    # idempotent second run
    assert populate_db.main([]) == 0
    assert populate_db.main(["--verify-only"]) == 0
    out = capsys.readouterr().out
    assert "Elo points are conserved" in out
    assert "populated and verified" in out


def test_populate_requires_url(monkeypatch):
    monkeypatch.delenv("DATABASE_URL", raising=False)
    assert populate_db.main([]) == 2
