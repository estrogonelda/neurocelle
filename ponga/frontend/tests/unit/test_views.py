def test_index_shows_leaderboard_and_matches(client):
    html = client.get("/").get_data(as_text=True)
    assert "Leaderboard" in html
    assert html.index("Ana") < html.index("Bruno")
    assert "11 – 5" in html
    assert "Log in" in html


def test_healthz(client, backend):
    assert client.get("/healthz").json == {"status": "ok", "backend": "ok"}
    backend.down = True
    r = client.get("/healthz")
    assert r.status_code == 503 and r.json["backend"] == "down"


def test_backend_down_renders_error_page(client, backend):
    backend.down = True
    r = client.get("/")
    assert r.status_code == 503
    assert "Something went wrong" in r.get_data(as_text=True)


def test_login_success_and_logout(client):
    r = client.post("/login", data={"username": "admin", "password": "admin"})
    assert r.status_code == 302 and r.headers["Location"] == "/"
    html = client.get("/").get_data(as_text=True)
    assert "admin (admin)" in html and "Welcome, admin!" in html
    client.post("/logout")
    assert "Log in" in client.get("/").get_data(as_text=True)


def test_login_failure(client):
    r = client.post("/login", data={"username": "admin", "password": "bad"})
    assert r.status_code == 401
    assert "Invalid username or password." in r.get_data(as_text=True)


def test_login_redirects_to_safe_next_only(client):
    r = client.post("/login?next=/matches", data={"username": "ref", "password": "ref123"})
    assert r.headers["Location"] == "/matches"
    r = client.post("/login?next=//evil.com", data={"username": "ref", "password": "ref123"})
    assert r.headers["Location"] == "/"


def test_login_page_renders(client):
    assert client.get("/login").status_code == 200


def test_add_player_requires_login(client, backend):
    r = client.post("/players", data={"name": "Carla"})
    assert r.status_code == 302 and "/login" in r.headers["Location"]
    assert backend.calls == []


def test_add_player(logged_in, backend):
    c = logged_in()
    r = c.post("/players", data={"name": " Carla "}, follow_redirects=True)
    assert "Player Carla added." in r.get_data(as_text=True)
    assert ("create_player", "Carla") in backend.calls


def test_add_player_blank_and_duplicate(logged_in):
    c = logged_in()
    assert "required" in c.post("/players", data={"name": ""}, follow_redirects=True).get_data(
        as_text=True
    )
    r = c.post("/players", data={"name": "Ana"}, follow_redirects=True)
    assert "already exists" in r.get_data(as_text=True)


def test_delete_button_only_for_admin(logged_in, client):
    assert "Delete" not in client.get("/players").get_data(as_text=True)
    logged_in("ref", "ref123")
    assert "Delete Ana" not in client.get("/players").get_data(as_text=True)
    logged_in("admin", "admin")
    assert "Delete Ana" in client.get("/players").get_data(as_text=True)


def test_delete_player(logged_in, backend):
    c = logged_in()
    r = c.post("/players/2/delete", follow_redirects=True)
    assert "Player removed." in r.get_data(as_text=True)
    assert ("delete_player", 2) in backend.calls


def test_delete_player_forbidden_for_non_admin(logged_in):
    c = logged_in("ref", "ref123")
    r = c.post("/players/2/delete", follow_redirects=True)
    assert "Admin only" in r.get_data(as_text=True)


def test_player_detail(client):
    html = client.get("/players/1").get_data(as_text=True)
    assert "1016" in html and "Bruno" in html
    assert client.get("/players/42").status_code == 404


def test_matches_page_anonymous(client):
    html = client.get("/matches").get_data(as_text=True)
    assert "to record a match" in html and "Record match" not in html


def test_record_match(logged_in, backend):
    c = logged_in()
    assert "Record match" in c.get("/matches").get_data(as_text=True)
    data = {"player1_id": "2", "player2_id": "1", "score1": "11", "score2": "9"}
    r = c.post("/matches", data=data, follow_redirects=True)
    assert "Match recorded: Bruno wins" in r.get_data(as_text=True)
    assert ("record_match", 2, 1, 11, 9) in backend.calls


def test_record_match_validation(logged_in):
    c = logged_in()
    bad = {"player1_id": "1", "player2_id": "2", "score1": "x", "score2": "9"}
    assert "must be numbers" in c.post("/matches", data=bad, follow_redirects=True).get_data(
        as_text=True
    )
    draw = {"player1_id": "1", "player2_id": "2", "score1": "5", "score2": "5"}
    assert "draw" in c.post("/matches", data=draw, follow_redirects=True).get_data(as_text=True)


def test_expired_token_logs_out(logged_in, client, backend):
    logged_in()
    backend.users.pop("admin")  # token no longer valid
    r = client.post("/players", data={"name": "Z"})
    assert r.status_code == 302 and r.headers["Location"].endswith("/login")
    assert "Log in" in client.get("/").get_data(as_text=True)


def test_matches_form_needs_two_players(logged_in, backend):
    backend.players_ = backend.players_[:1]
    html = logged_in().get("/matches").get_data(as_text=True)
    assert "at least two players" in html
