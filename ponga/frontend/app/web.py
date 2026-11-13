"""Flask web UI that talks to the backend over HTTP."""

from __future__ import annotations

import os
from functools import wraps

from flask import Flask, flash, g, redirect, render_template, request, session, url_for

from app.api_client import ApiError, BackendClient


def create_app(config: dict | None = None, client: BackendClient | None = None) -> Flask:
    app = Flask(__name__)
    app.config.update(
        SECRET_KEY=os.getenv("FRONTEND_SECRET_KEY", "dev-frontend-secret"),
        BACKEND_URL=os.getenv("BACKEND_URL", "http://localhost:8000"),
        SESSION_COOKIE_HTTPONLY=True,
        SESSION_COOKIE_SAMESITE="Lax",
    )
    if config:
        app.config.update(config)
    api = client or BackendClient(app.config["BACKEND_URL"])
    app.extensions["ponga_api"] = api

    @app.before_request
    def _load_user():
        g.user = session.get("user")
        g.token = session.get("token")

    def login_required(view):
        @wraps(view)
        def wrapped(*args, **kwargs):
            if not g.token:
                flash("Please log in first.", "error")
                return redirect(url_for("login", next=request.path))
            return view(*args, **kwargs)

        return wrapped

    def handle_api_error(exc: ApiError, fallback: str):
        if exc.status == 401:
            session.clear()
            flash("Your session expired, please log in again.", "error")
            return redirect(url_for("login"))
        flash(f"Error: {exc.detail}", "error")
        return redirect(fallback)

    @app.errorhandler(ApiError)
    def _api_down(exc: ApiError):
        return render_template("error.html", error=exc), exc.status if exc.status >= 500 else 502

    @app.get("/healthz")
    def healthz():
        try:
            backend = api.health()["status"]
        except ApiError:
            backend = "down"
        code = 200 if backend == "ok" else 503
        return {"status": "ok" if code == 200 else "degraded", "backend": backend}, code

    @app.get("/")
    def index():
        return render_template(
            "index.html", leaderboard=api.leaderboard(), matches=api.matches(limit=10)
        )

    @app.route("/login", methods=["GET", "POST"])
    def login():
        if request.method == "POST":
            username = request.form.get("username", "").strip()
            password = request.form.get("password", "")
            try:
                token = api.login(username, password)
                me = api.me(token)
            except ApiError as exc:
                msg = "Invalid username or password." if exc.status == 401 else exc.detail
                flash(msg, "error")
                return render_template("login.html", username=username), 401
            session.clear()
            session["token"] = token
            session["user"] = {"username": me["username"], "is_admin": me["is_admin"]}
            flash(f"Welcome, {me['username']}!", "success")
            nxt = request.args.get("next", "")
            return redirect(nxt if nxt.startswith("/") and not nxt.startswith("//") else "/")
        return render_template("login.html", username="")

    @app.post("/logout")
    def logout():
        session.clear()
        flash("Logged out.", "success")
        return redirect(url_for("index"))

    @app.get("/players")
    def players():
        return render_template("players.html", players=api.players())

    @app.post("/players")
    @login_required
    def add_player():
        name = request.form.get("name", "").strip()
        if not name:
            flash("Player name is required.", "error")
            return redirect(url_for("players"))
        try:
            api.create_player(g.token, name)
        except ApiError as exc:
            return handle_api_error(exc, url_for("players"))
        flash(f"Player {name} added.", "success")
        return redirect(url_for("players"))

    @app.post("/players/<int:player_id>/delete")
    @login_required
    def delete_player(player_id: int):
        try:
            api.delete_player(g.token, player_id)
        except ApiError as exc:
            return handle_api_error(exc, url_for("players"))
        flash("Player removed.", "success")
        return redirect(url_for("players"))

    @app.get("/players/<int:player_id>")
    def player_detail(player_id: int):
        player = next((p for p in api.players() if p["id"] == player_id), None)
        if player is None:
            return render_template("error.html", error=ApiError(404, "Player not found")), 404
        return render_template(
            "player.html", player=player, matches=api.matches(player_id=player_id)
        )

    @app.get("/matches")
    def matches():
        return render_template("matches.html", matches=api.matches(), players=api.players())

    @app.post("/matches")
    @login_required
    def add_match():
        try:
            p1, p2, s1, s2 = (
                int(request.form[k]) for k in ("player1_id", "player2_id", "score1", "score2")
            )
        except (KeyError, ValueError):
            flash("All match fields are required and must be numbers.", "error")
            return redirect(url_for("matches"))
        try:
            m = api.record_match(g.token, p1, p2, s1, s2)
        except ApiError as exc:
            return handle_api_error(exc, url_for("matches"))
        flash(
            f"Match recorded: {m['winner']['name']} wins (±{m['rating_change']} rating).",
            "success",
        )
        return redirect(url_for("matches"))

    return app
