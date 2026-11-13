"""Thin HTTP client for the ponga backend API."""

from __future__ import annotations

from typing import Any

import requests


class ApiError(Exception):
    def __init__(self, status: int, detail: str) -> None:
        super().__init__(detail)
        self.status = status
        self.detail = detail


class BackendClient:
    def __init__(self, base_url: str, timeout: float = 5.0, session=None) -> None:
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self.http = session or requests.Session()

    def _request(self, method: str, path: str, token: str | None = None, **kw) -> Any:
        headers = kw.pop("headers", {})
        if token:
            headers["Authorization"] = f"Bearer {token}"
        try:
            resp = self.http.request(
                method, f"{self.base_url}/api{path}", headers=headers, timeout=self.timeout, **kw
            )
        except requests.RequestException as exc:
            raise ApiError(503, f"backend unavailable: {exc.__class__.__name__}") from exc
        if resp.status_code >= 400:
            raise ApiError(resp.status_code, _detail(resp))
        if resp.status_code == 204 or not resp.content:
            return None
        return resp.json()

    # meta
    def health(self) -> dict:
        return self._request("GET", "/health")

    # auth
    def login(self, username: str, password: str) -> str:
        data = self._request(
            "POST", "/auth/login", json={"username": username, "password": password}
        )
        return data["access_token"]

    def me(self, token: str) -> dict:
        return self._request("GET", "/auth/me", token)

    # players
    def players(self) -> list[dict]:
        return self._request("GET", "/players")

    def create_player(self, token: str, name: str) -> dict:
        return self._request("POST", "/players", token, json={"name": name})

    def delete_player(self, token: str, player_id: int) -> None:
        self._request("DELETE", f"/players/{player_id}", token)

    def leaderboard(self) -> list[dict]:
        return self._request("GET", "/leaderboard")

    # matches
    def matches(self, limit: int = 50, player_id: int | None = None) -> list[dict]:
        params: dict[str, Any] = {"limit": limit}
        if player_id is not None:
            params["player_id"] = player_id
        return self._request("GET", "/matches", params=params)

    def record_match(self, token: str, p1: int, p2: int, s1: int, s2: int) -> dict:
        body = {"player1_id": p1, "player2_id": p2, "score1": s1, "score2": s2}
        return self._request("POST", "/matches", token, json=body)


def _detail(resp) -> str:
    try:
        detail = resp.json().get("detail", resp.text)
    except ValueError:
        return resp.text or resp.reason
    if isinstance(detail, list):  # FastAPI validation errors
        return "; ".join(
            f"{'.'.join(str(x) for x in d.get('loc', [])[1:])}: {d.get('msg')}" for d in detail
        )
    return str(detail)
