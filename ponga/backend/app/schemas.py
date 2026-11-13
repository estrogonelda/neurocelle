"""Pydantic request/response models."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator


class _ORM(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class LoginIn(BaseModel):
    username: str
    password: str


class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=50, pattern=r"^[A-Za-z0-9_.-]+$")
    password: str = Field(min_length=6, max_length=128)
    is_admin: bool = False


class UserOut(_ORM):
    id: int
    username: str
    is_admin: bool


class PlayerCreate(BaseModel):
    name: str = Field(min_length=1, max_length=80)

    @field_validator("name")
    @classmethod
    def _strip(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("name must not be blank")
        return v


class PlayerOut(_ORM):
    id: int
    name: str
    rating: int
    wins: int
    losses: int


class LeaderboardEntry(PlayerOut):
    rank: int
    games: int
    win_rate: float


class MatchCreate(BaseModel):
    player1_id: int
    player2_id: int
    score1: int = Field(ge=0, le=99)
    score2: int = Field(ge=0, le=99)


class MatchOut(_ORM):
    id: int
    player1: PlayerOut
    player2: PlayerOut
    score1: int
    score2: int
    winner: PlayerOut
    rating_change: int
    played_at: datetime


class Health(BaseModel):
    status: str
    database: str
