"""HTTP routes under /api."""

from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import text
from sqlalchemy.orm import Session

from app import services
from app.api.deps import admin_user, current_user, get_db, get_settings
from app.core.config import Settings
from app.core.security import create_access_token
from app.models import User
from app.schemas import (
    Health,
    LeaderboardEntry,
    LoginIn,
    MatchCreate,
    MatchOut,
    PlayerCreate,
    PlayerOut,
    Token,
    UserCreate,
    UserOut,
)

router = APIRouter()


def _raise(exc: Exception) -> None:
    if isinstance(exc, services.NotFound):
        raise HTTPException(status.HTTP_404_NOT_FOUND, str(exc)) from exc
    if isinstance(exc, services.Conflict):
        raise HTTPException(status.HTTP_409_CONFLICT, str(exc)) from exc
    if isinstance(exc, services.Invalid):
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, str(exc)) from exc
    raise exc


@router.get("/health", response_model=Health, tags=["meta"])
def health(db: Session = Depends(get_db)) -> Health:
    try:
        db.execute(text("SELECT 1"))
        return Health(status="ok", database="ok")
    except Exception:  # pragma: no cover - exercised only when the DB is down
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "database unavailable") from None


# --- auth ----------------------------------------------------------------------
@router.post("/auth/login", response_model=Token, tags=["auth"])
def login(
    body: LoginIn, db: Session = Depends(get_db), settings: Settings = Depends(get_settings)
) -> Token:
    user = services.authenticate(db, body.username, body.password)
    if user is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid username or password")
    token = create_access_token(
        user.username,
        settings.secret_key,
        settings.token_ttl_minutes,
        extra={"admin": user.is_admin},
    )
    return Token(access_token=token)


@router.get("/auth/me", response_model=UserOut, tags=["auth"])
def me(user: User = Depends(current_user)) -> User:
    return user


@router.post("/users", response_model=UserOut, status_code=201, tags=["users"])
def create_user(
    body: UserCreate, db: Session = Depends(get_db), _: User = Depends(admin_user)
) -> User:
    try:
        return services.create_user(db, body.username, body.password, body.is_admin)
    except services.Conflict as exc:
        _raise(exc)


# --- players -------------------------------------------------------------------
@router.get("/players", response_model=list[PlayerOut], tags=["players"])
def list_players(db: Session = Depends(get_db)):
    return services.list_players(db)


@router.post("/players", response_model=PlayerOut, status_code=201, tags=["players"])
def create_player(
    body: PlayerCreate, db: Session = Depends(get_db), _: User = Depends(current_user)
):
    try:
        return services.create_player(db, body.name)
    except services.Conflict as exc:
        _raise(exc)


@router.get("/players/{player_id}", response_model=PlayerOut, tags=["players"])
def get_player(player_id: int, db: Session = Depends(get_db)):
    try:
        return services.get_player(db, player_id)
    except services.NotFound as exc:
        _raise(exc)


@router.delete("/players/{player_id}", status_code=204, tags=["players"])
def delete_player(player_id: int, db: Session = Depends(get_db), _: User = Depends(admin_user)):
    try:
        services.delete_player(db, player_id)
    except (services.NotFound, services.Conflict) as exc:
        _raise(exc)


@router.get("/leaderboard", response_model=list[LeaderboardEntry], tags=["players"])
def leaderboard(db: Session = Depends(get_db)):
    return services.leaderboard(db)


# --- matches -------------------------------------------------------------------
@router.get("/matches", response_model=list[MatchOut], tags=["matches"])
def list_matches(
    player_id: int | None = None,
    limit: int = Query(50, ge=1, le=500),
    db: Session = Depends(get_db),
):
    return services.list_matches(db, player_id=player_id, limit=limit)


@router.post("/matches", response_model=MatchOut, status_code=201, tags=["matches"])
def create_match(
    body: MatchCreate,
    db: Session = Depends(get_db),
    settings: Settings = Depends(get_settings),
    user: User = Depends(current_user),
):
    try:
        return services.record_match(
            db,
            body.player1_id,
            body.player2_id,
            body.score1,
            body.score2,
            k_factor=settings.elo_k_factor,
            recorded_by=user,
        )
    except (services.NotFound, services.Invalid) as exc:
        _raise(exc)
