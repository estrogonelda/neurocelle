"""ORM models: application users, players and matches."""

from __future__ import annotations

from datetime import UTC, datetime

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Integer,
    String,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.elo import DEFAULT_RATING
from app.db import Base


def _now() -> datetime:
    return datetime.now(UTC)


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    is_admin: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class Player(Base):
    __tablename__ = "players"
    __table_args__ = (
        CheckConstraint("wins >= 0", name="ck_players_wins"),
        CheckConstraint("losses >= 0", name="ck_players_losses"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(80), unique=True, nullable=False)
    rating: Mapped[int] = mapped_column(Integer, nullable=False, default=DEFAULT_RATING)
    wins: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    losses: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class Match(Base):
    __tablename__ = "matches"
    __table_args__ = (
        CheckConstraint("player1_id <> player2_id", name="ck_matches_distinct_players"),
        CheckConstraint("score1 >= 0 AND score2 >= 0", name="ck_matches_scores"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    player1_id: Mapped[int] = mapped_column(ForeignKey("players.id", ondelete="RESTRICT"))
    player2_id: Mapped[int] = mapped_column(ForeignKey("players.id", ondelete="RESTRICT"))
    score1: Mapped[int] = mapped_column(Integer, nullable=False)
    score2: Mapped[int] = mapped_column(Integer, nullable=False)
    winner_id: Mapped[int] = mapped_column(ForeignKey("players.id", ondelete="RESTRICT"))
    rating_change: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    recorded_by_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    played_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    player1: Mapped[Player] = relationship(foreign_keys=[player1_id], lazy="joined")
    player2: Mapped[Player] = relationship(foreign_keys=[player2_id], lazy="joined")
    winner: Mapped[Player] = relationship(foreign_keys=[winner_id], lazy="joined")
