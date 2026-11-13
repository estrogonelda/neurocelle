"""API tests against an in-memory SQLite database (no external services)."""

from tests.conftest import login


def test_health(client):
    r = client.get("/api/health")
    assert r.json() == {"status": "ok", "database": "ok"}


def test_login_and_me(client, admin_headers):
    r = client.get("/api/auth/me", headers=admin_headers)
    assert r.status_code == 200
    assert r.json()["username"] == "admin" and r.json()["is_admin"] is True


def test_login_bad_password(client):
    r = client.post("/api/auth/login", json={"username": "admin", "password": "nope"})
    assert r.status_code == 401


def test_me_requires_valid_token(client):
    assert client.get("/api/auth/me").status_code == 401
    bad = {"Authorization": "Bearer not-a-jwt"}
    assert client.get("/api/auth/me", headers=bad).status_code == 401


def test_token_for_deleted_user_rejected(client, admin_headers, session):
    from app.core.security import create_access_token

    token = create_access_token("ghost", "test-secret", 5)
    r = client.get("/api/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert r.status_code == 401


def test_admin_creates_users_and_non_admin_cannot(client, admin_headers):
    r = client.post(
        "/api/users", headers=admin_headers, json={"username": "ref", "password": "ref123"}
    )
    assert r.status_code == 201 and r.json()["is_admin"] is False
    dup = client.post(
        "/api/users", headers=admin_headers, json={"username": "ref", "password": "ref123"}
    )
    assert dup.status_code == 409
    ref = login(client, "ref", "ref123")
    r = client.post("/api/users", headers=ref, json={"username": "x12", "password": "abcdef"})
    assert r.status_code == 403


def test_user_validation(client, admin_headers):
    r = client.post("/api/users", headers=admin_headers, json={"username": "a", "password": "x"})
    assert r.status_code == 422


def test_player_crud(client, admin_headers):
    assert client.post("/api/players", json={"name": "Ana"}).status_code == 401
    r = client.post("/api/players", headers=admin_headers, json={"name": "  Ana  "})
    assert r.status_code == 201
    pid = r.json()["id"]
    assert r.json()["name"] == "Ana" and r.json()["rating"] == 1000
    dup = client.post("/api/players", headers=admin_headers, json={"name": "Ana"})
    assert dup.status_code == 409
    blank = client.post("/api/players", headers=admin_headers, json={"name": "  "})
    assert blank.status_code == 422
    assert client.get(f"/api/players/{pid}").json()["name"] == "Ana"
    assert [p["name"] for p in client.get("/api/players").json()] == ["Ana"]
    assert client.delete(f"/api/players/{pid}", headers=admin_headers).status_code == 204
    assert client.get(f"/api/players/{pid}").status_code == 404
    assert client.delete(f"/api/players/{pid}", headers=admin_headers).status_code == 404


def test_match_flow_and_leaderboard(client, admin_headers):
    a = client.post("/api/players", headers=admin_headers, json={"name": "A"}).json()["id"]
    b = client.post("/api/players", headers=admin_headers, json={"name": "B"}).json()["id"]
    body = {"player1_id": a, "player2_id": b, "score1": 7, "score2": 11}
    assert client.post("/api/matches", json=body).status_code == 401
    r = client.post("/api/matches", headers=admin_headers, json=body)
    assert r.status_code == 201, r.text
    m = r.json()
    assert m["winner"]["name"] == "B" and m["rating_change"] == 16
    assert client.get("/api/matches").json()[0]["id"] == m["id"]
    assert len(client.get(f"/api/matches?player_id={a}").json()) == 1
    board = client.get("/api/leaderboard").json()
    assert [(row["name"], row["rating"]) for row in board] == [("B", 1016), ("A", 984)]
    # player with matches cannot be removed
    assert client.delete(f"/api/players/{a}", headers=admin_headers).status_code == 409


def test_match_errors(client, admin_headers):
    a = client.post("/api/players", headers=admin_headers, json={"name": "A"}).json()["id"]
    bad_score = {"player1_id": a, "player2_id": a + 1000, "score1": 11, "score2": 10}
    assert client.post("/api/matches", headers=admin_headers, json=bad_score).status_code == 422
    unknown = {"player1_id": a, "player2_id": 9999, "score1": 11, "score2": 2}
    assert client.post("/api/matches", headers=admin_headers, json=unknown).status_code == 404
    same = {"player1_id": a, "player2_id": a, "score1": 11, "score2": 2}
    assert client.post("/api/matches", headers=admin_headers, json=same).status_code == 422


def test_non_admin_cannot_delete_player(client, admin_headers):
    client.post("/api/users", headers=admin_headers, json={"username": "ref", "password": "ref123"})
    pid = client.post("/api/players", headers=admin_headers, json={"name": "A"}).json()["id"]
    ref = login(client, "ref", "ref123")
    assert client.delete(f"/api/players/{pid}", headers=ref).status_code == 403
