import pytest

from app.core import elo


def test_expected_score_equal_ratings():
    assert elo.expected_score(1000, 1000) == pytest.approx(0.5)


def test_expected_score_is_symmetric():
    a = elo.expected_score(1200, 1000)
    b = elo.expected_score(1000, 1200)
    assert a + b == pytest.approx(1.0)
    assert a > 0.5 > b


@pytest.mark.parametrize("a,b,a_won", [(1000, 1000, True), (1400, 900, False), (800, 1500, True)])
def test_new_ratings_conserve_points(a, b, a_won):
    na, nb = elo.new_ratings(a, b, a_won)
    assert na + nb == a + b


def test_equal_players_move_half_k():
    assert elo.new_ratings(1000, 1000, True, k=32) == (1016, 984)


def test_upset_moves_more_than_expected_win():
    upset = elo.new_ratings(800, 1200, True)[0] - 800
    expected = elo.new_ratings(1200, 800, True)[0] - 1200
    assert upset > expected > 0


@pytest.mark.parametrize("s1,s2", [(11, 0), (0, 11), (11, 9), (12, 10), (15, 13), (9, 11)])
def test_valid_scores(s1, s2):
    elo.validate_score(s1, s2)


@pytest.mark.parametrize(
    "s1,s2,msg",
    [
        (5, 5, "draw"),
        (10, 8, "at least 11"),
        (11, 10, "lead by at least 2"),
        (15, 10, "after deuce"),
        (-1, 11, "non-negative"),
    ],
)
def test_invalid_scores(s1, s2, msg):
    with pytest.raises(ValueError, match=msg):
        elo.validate_score(s1, s2)
