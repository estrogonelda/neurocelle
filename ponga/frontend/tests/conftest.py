from __future__ import annotations

import pytest

from app import create_app
from app.api_client import ApiError


def _player(pid, name, rating=1000, wins=0, losses=0):
    return {"id": pid, "name": name, "rating": rating, "wins": wins, "losses": losses}


class FakeBackend:
    """In-memory stand-in for BackendClient used by the frontend unit tests."""

    def __init__(self):
        self.users = {"admin": ("admin", True), "ref": ("ref123", False)}
        self.players_ = [_player(1, "Ana", 1016, 1, 0), _player(2, "Bruno", 984, 0, 1)]
        self.matches_ = [
            {
                "id": 1,
                "player1": self.players_[0],
                "player2": self.players_[1],
                "score1": 11,
                "score2": 5,
                "winner": self.players_[0],
                "rating_change": 16,
                "played_at": "2026-01-01T10:00:00+00:00",
            }
        ]
        self.calls = []
        self.down = False

    def _check(self, token):
        if self.down:
            raise ApiError(503, "backend unavailable")
        if token is not None and token not in {f"tok-{u}" for u in self.users}:
            raise ApiError(401, "Not authenticated")

    def health(self):
        self._check(None)
        return {"status": "ok", "database": "ok"}

    def login(self, username, password):
        self._check(None)
        if self.users.get(username, (None,))[0] != password:
            raise ApiError(401, "Invalid username or password")
        return f"tok-{username}"

    def me(self, token):
        self._check(token)
        name = token.removeprefix("tok-")
        return {"id": 1, "username": name, "is_admin": self.users[name][1]}

    def players(self):
        self._check(None)
        return list(self.players_)

    def leaderboard(self):
        self._check(None)
        rows = sorted(self.players_, key=lambda p: -p["rating"])
        return [
            dict(
                p,
                rank=i,
                games=p["wins"] + p["losses"],
                win_rate=p["wins"] / max(1, p["wins"] + p["losses"]),
            )
            for i, p in enumerate(rows, 1)
        ]

    def matches(self, limit=50, player_id=None):
        self._check(None)
        ms = [
            m
            for m in self.matches_
            if player_id is None or player_id in (m["player1"]["id"], m["player2"]["id"])
        ]
        return ms[:limit]

    def create_player(self, token, name):
        self._check(token)
        if any(p["name"] == name for p in self.players_):
            raise ApiError(409, f"player '{name}' already exists")
        p = _player(len(self.players_) + 1, name)
        self.players_.append(p)
        self.calls.append(("create_player", name))
        return p

    def delete_player(self, token, player_id):
        self._check(token)
        if not self.users[token.removeprefix("tok-")][1]:
            raise ApiError(403, "Admin only")
        self.players_ = [p for p in self.players_ if p["id"] != player_id]
        self.calls.append(("delete_player", player_id))

    def record_match(self, token, p1, p2, s1, s2):
        self._check(token)
        if s1 == s2:
            raise ApiError(422, "a game cannot end in a draw")
        a = next(p for p in self.players_ if p["id"] == p1)
        b = next(p for p in self.players_ if p["id"] == p2)
        m = {
            "id": 99,
            "player1": a,
            "player2": b,
            "score1": s1,
            "score2": s2,
            "winner": a if s1 > s2 else b,
            "rating_change": 16,
            "played_at": "2026-01-02T10:00:00+00:00",
        }
        self.matches_.insert(0, m)
        self.calls.append(("record_match", p1, p2, s1, s2))
        return m


@pytest.fixture
def backend():
    return FakeBackend()


@pytest.fixture
def app(backend):
    return create_app({"TESTING": True, "SECRET_KEY": "t"}, client=backend)


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture
def logged_in(client):
    def _login(user="admin", pw="admin"):
        r = client.post("/login", data={"username": user, "password": pw})
        assert r.status_code == 302
        return client

    return _login
