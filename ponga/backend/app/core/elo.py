"""Elo rating maths, kept free of any I/O so it is trivially unit-testable."""

from __future__ import annotations

DEFAULT_RATING = 1000


def expected_score(rating_a: float, rating_b: float) -> float:
    """Probability that A beats B."""
    return 1.0 / (1.0 + 10 ** ((rating_b - rating_a) / 400.0))


def new_ratings(rating_a: int, rating_b: int, a_won: bool, k: int = 32) -> tuple[int, int]:
    """Return the updated (rating_a, rating_b) after one game.

    Rounding is done on the delta so the total number of points is conserved.
    """
    exp_a = expected_score(rating_a, rating_b)
    score_a = 1.0 if a_won else 0.0
    delta = round(k * (score_a - exp_a))
    return rating_a + delta, rating_b - delta


def validate_score(score1: int, score2: int, points_to_win: int = 11) -> None:
    """Validate a table-tennis game score (to 11, win by 2).

    Raises ValueError with a human readable message when invalid.
    """
    if score1 < 0 or score2 < 0:
        raise ValueError("scores must be non-negative")
    if score1 == score2:
        raise ValueError("a game cannot end in a draw")
    hi, lo = max(score1, score2), min(score1, score2)
    if hi < points_to_win:
        raise ValueError(f"the winner needs at least {points_to_win} points")
    if hi - lo < 2:
        raise ValueError("the winner must lead by at least 2 points")
    if hi > points_to_win and hi - lo != 2:
        raise ValueError("after deuce the game ends as soon as one player leads by 2")
