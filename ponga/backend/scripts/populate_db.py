"""Populate the ponga database with demo data and verify it.

Usage (inside the backend container, or anywhere with the env vars set):

    python -m scripts.populate_db            # populate (idempotent) + verify
    python -m scripts.populate_db --reset    # wipe data first (needs owner URL)
    python -m scripts.populate_db --verify-only

Environment:
    DATABASE_URL            app role (DML)           - required
    MIGRATION_DATABASE_URL  owner role, for --reset  - optional
    READONLY_DATABASE_URL   read-only role           - optional, enables privilege checks
"""

from __future__ import annotations

import argparse
import os
import random
import sys

from sqlalchemy import func, select, text
from sqlalchemy.exc import DBAPIError

from app import services
from app.core.elo import DEFAULT_RATING
from app.db import Database, make_engine
from app.models import Match, Player, User

DEMO_USERS = [
    # username, password, is_admin
    ("admin", os.getenv("ADMIN_PASSWORD", "admin"), True),
    ("referee", "referee123", False),
    ("alice", "alice123", False),
    ("bob", "bob12345", False),
]
DEMO_PLAYERS = ["Ana", "Bruno", "Carla", "Diego", "Elisa", "Fábio", "Gabi", "Hugo"]
DEMO_MATCHES = 40
SEED = 42


class CheckFailed(AssertionError):
    pass


def _random_score(rng: random.Random) -> tuple[int, int]:
    if rng.random() < 0.2:  # deuce game
        loser = rng.randint(10, 14)
        winner = loser + 2
    else:
        winner, loser = 11, rng.randint(0, 9)
    return (winner, loser) if rng.random() < 0.5 else (loser, winner)


def reset(owner_url: str) -> None:
    engine = make_engine(owner_url)
    with engine.begin() as conn:
        conn.execute(text("TRUNCATE matches, players, users RESTART IDENTITY CASCADE"))
    engine.dispose()
    print("reset: all ponga tables truncated")


def populate(db_url: str) -> None:
    database = Database(db_url)
    rng = random.Random(SEED)
    with database.SessionLocal() as db:
        for username, password, is_admin in DEMO_USERS:
            if services.get_user_by_username(db, username) is None:
                services.create_user(db, username, password, is_admin)
                print(f"  + user {username}{' (admin)' if is_admin else ''}")

        existing = {p.name for p in services.list_players(db)}
        for name in DEMO_PLAYERS:
            if name not in existing:
                services.create_player(db, name)
                print(f"  + player {name}")

        if db.scalar(select(func.count()).select_from(Match)) == 0:
            referee = services.get_user_by_username(db, "referee")
            players = services.list_players(db)
            for _ in range(DEMO_MATCHES):
                p1, p2 = rng.sample(players, 2)
                s1, s2 = _random_score(rng)
                services.record_match(db, p1.id, p2.id, s1, s2, recorded_by=referee)
            print(f"  + {DEMO_MATCHES} matches")
    database.engine.dispose()


def _check(cond: bool, message: str) -> None:
    if not cond:
        raise CheckFailed(message)
    print(f"  ok  {message}")


def verify(db_url: str, readonly_url: str | None) -> None:
    database = Database(db_url)
    with database.SessionLocal() as db:
        n_users = db.scalar(select(func.count()).select_from(User))
        n_players = db.scalar(select(func.count()).select_from(Player))
        n_matches = db.scalar(select(func.count()).select_from(Match))
        _check(n_users >= len(DEMO_USERS), f"{n_users} users present")
        _check(n_players >= len(DEMO_PLAYERS), f"{n_players} players present")
        _check(n_matches >= DEMO_MATCHES, f"{n_matches} matches present")

        admins = db.scalar(select(func.count()).select_from(User).where(User.is_admin))
        _check(admins >= 1, "at least one admin account exists")
        _check(
            services.authenticate(db, "referee", "referee123") is not None,
            "demo user 'referee' can authenticate",
        )

        rating_sum = db.scalar(select(func.sum(Player.rating)))
        _check(rating_sum == DEFAULT_RATING * n_players, "Elo points are conserved")

        wl = db.execute(select(func.sum(Player.wins), func.sum(Player.losses))).one()
        _check(wl[0] == n_matches and wl[1] == n_matches, "wins == losses == number of matches")

        bad = db.scalar(
            select(func.count())
            .select_from(Match)
            .where((Match.winner_id != Match.player1_id) & (Match.winner_id != Match.player2_id))
        )
        _check(bad == 0, "every match winner is one of its players")

        board = services.leaderboard(db)
        ratings = [row["rating"] for row in board]
        _check(ratings == sorted(ratings, reverse=True), "leaderboard sorted by rating")

    if database.engine.dialect.name == "postgresql":
        _check_privileges(database, readonly_url)
    database.engine.dispose()


def _expect_denied(engine, sql: str, message: str) -> None:
    with engine.connect() as conn:
        try:
            conn.execute(text(sql))
            conn.rollback()
        except DBAPIError as exc:
            conn.rollback()
            err = str(exc.orig).lower()
            _check("permission denied" in err or "must be owner" in err, message)
            return
    raise CheckFailed(f"{message}: statement unexpectedly succeeded: {sql}")


def _check_privileges(database: Database, readonly_url: str | None) -> None:
    with database.engine.connect() as conn:
        role = conn.scalar(text("SELECT current_user"))
        schema = conn.scalar(text("SELECT current_schema()"))
    _check(role == "ponga_app", f"backend connects as '{role}'")
    _check(schema == "ponga", f"tables live in schema '{schema}'")
    _expect_denied(database.engine, "CREATE TABLE ponga.evil (id int)", "app role cannot run DDL")
    _expect_denied(database.engine, "DROP TABLE ponga.matches", "app role cannot drop tables")

    if readonly_url:
        ro = make_engine(readonly_url)
        with ro.connect() as conn:
            n = conn.scalar(text("SELECT count(*) FROM players"))
        _check(n > 0, "read-only role can SELECT")
        _expect_denied(
            ro,
            "INSERT INTO players (name, rating, wins, losses) " "VALUES ('x', 1000, 0, 0)",
            "read-only role cannot INSERT",
        )
        _expect_denied(ro, "DELETE FROM matches", "read-only role cannot DELETE")
        ro.dispose()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--reset", action="store_true", help="truncate all data first")
    parser.add_argument("--verify-only", action="store_true", help="skip populating")
    args = parser.parse_args(argv)

    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        print("DATABASE_URL is required", file=sys.stderr)
        return 2

    if args.reset:
        owner_url = os.environ.get("MIGRATION_DATABASE_URL", db_url)
        reset(owner_url)
    if not args.verify_only:
        print("populating…")
        populate(db_url)
    print("verifying…")
    try:
        verify(db_url, os.environ.get("READONLY_DATABASE_URL"))
    except CheckFailed as exc:
        print(f"  FAIL {exc}", file=sys.stderr)
        return 1
    print("database populated and verified ✔")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
