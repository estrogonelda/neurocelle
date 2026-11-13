"""Business logic, independent from HTTP."""

from __future__ import annotations

from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.core import elo
from app.core.security import hash_password, verify_password
from app.models import Match, Player, User


class NotFound(Exception):
    pass


class Conflict(Exception):
    pass


class Invalid(Exception):
    pass


# --- users -------------------------------------------------------------------
def get_user_by_username(db: Session, username: str) -> User | None:
    return db.scalar(select(User).where(User.username == username))


def authenticate(db: Session, username: str, password: str) -> User | None:
    user = get_user_by_username(db, username)
    if user and verify_password(password, user.password_hash):
        return user
    return None


def create_user(db: Session, username: str, password: str, is_admin: bool = False) -> User:
    if get_user_by_username(db, username):
        raise Conflict(f"user '{username}' already exists")
    user = User(username=username, password_hash=hash_password(password), is_admin=is_admin)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def ensure_admin(db: Session, username: str, password: str) -> User:
    """Create the bootstrap admin account if it does not exist yet."""
    user = get_user_by_username(db, username)
    if user is None:
        user = create_user(db, username, password, is_admin=True)
    return user


# --- players -----------------------------------------------------------------
def list_players(db: Session) -> list[Player]:
    return list(db.scalars(select(Player).order_by(Player.name)))


def get_player(db: Session, player_id: int) -> Player:
    player = db.get(Player, player_id)
    if player is None:
        raise NotFound(f"player {player_id} not found")
    return player


def create_player(db: Session, name: str) -> Player:
    if db.scalar(select(Player).where(Player.name == name)):
        raise Conflict(f"player '{name}' already exists")
    player = Player(name=name, rating=elo.DEFAULT_RATING, wins=0, losses=0)
    db.add(player)
    db.commit()
    db.refresh(player)
    return player


def delete_player(db: Session, player_id: int) -> None:
    player = get_player(db, player_id)
    has_matches = db.scalar(
        select(Match.id)
        .where(or_(Match.player1_id == player_id, Match.player2_id == player_id))
        .limit(1)
    )
    if has_matches:
        raise Conflict("player has recorded matches and cannot be deleted")
    db.delete(player)
    db.commit()


def leaderboard(db: Session) -> list[dict]:
    players = db.scalars(
        select(Player).order_by(Player.rating.desc(), Player.wins.desc(), Player.name)
    ).all()
    rows = []
    for rank, p in enumerate(players, start=1):
        games = p.wins + p.losses
        rows.append(
            {
                "rank": rank,
                "id": p.id,
                "name": p.name,
                "rating": p.rating,
                "wins": p.wins,
                "losses": p.losses,
                "games": games,
                "win_rate": round(p.wins / games, 3) if games else 0.0,
            }
        )
    return rows


# --- matches -----------------------------------------------------------------
def list_matches(db: Session, player_id: int | None = None, limit: int = 50) -> list[Match]:
    stmt = select(Match).order_by(Match.played_at.desc(), Match.id.desc()).limit(limit)
    if player_id is not None:
        stmt = stmt.where(or_(Match.player1_id == player_id, Match.player2_id == player_id))
    return list(db.scalars(stmt).unique())


def record_match(
    db: Session,
    player1_id: int,
    player2_id: int,
    score1: int,
    score2: int,
    *,
    k_factor: int = 32,
    recorded_by: User | None = None,
) -> Match:
    if player1_id == player2_id:
        raise Invalid("a player cannot play against themselves")
    try:
        elo.validate_score(score1, score2)
    except ValueError as exc:
        raise Invalid(str(exc)) from exc

    p1 = get_player(db, player1_id)
    p2 = get_player(db, player2_id)
    p1_won = score1 > score2
    new1, new2 = elo.new_ratings(p1.rating, p2.rating, p1_won, k=k_factor)
    change = abs(new1 - p1.rating)
    p1.rating, p2.rating = new1, new2
    winner, loser = (p1, p2) if p1_won else (p2, p1)
    winner.wins += 1
    loser.losses += 1

    match = Match(
        player1_id=p1.id,
        player2_id=p2.id,
        score1=score1,
        score2=score2,
        winner_id=winner.id,
        rating_change=change,
        recorded_by_id=recorded_by.id if recorded_by else None,
    )
    db.add(match)
    db.commit()
    db.refresh(match)
    return match
