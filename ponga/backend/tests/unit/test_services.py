import pytest

from app import services
from app.core.elo import DEFAULT_RATING


def test_ensure_admin_is_idempotent(session):
    a = services.ensure_admin(session, "root", "pw1234")
    b = services.ensure_admin(session, "root", "other")
    assert a.id == b.id and a.is_admin
    assert services.authenticate(session, "root", "pw1234")
    assert services.authenticate(session, "root", "other") is None


def test_duplicate_user_conflict(session):
    services.create_user(session, "bob", "pw1234")
    with pytest.raises(services.Conflict):
        services.create_user(session, "bob", "pw1234")


def test_create_player_defaults(session):
    p = services.create_player(session, "Ana")
    assert (p.rating, p.wins, p.losses) == (DEFAULT_RATING, 0, 0)
    with pytest.raises(services.Conflict):
        services.create_player(session, "Ana")


def test_record_match_updates_players(session):
    a = services.create_player(session, "A")
    b = services.create_player(session, "B")
    m = services.record_match(session, a.id, b.id, 11, 7)
    session.refresh(a)
    session.refresh(b)
    assert m.winner_id == a.id
    assert m.rating_change == 16
    assert (a.rating, a.wins, a.losses) == (1016, 1, 0)
    assert (b.rating, b.wins, b.losses) == (984, 0, 1)


def test_record_match_player2_wins(session):
    a = services.create_player(session, "A")
    b = services.create_player(session, "B")
    m = services.record_match(session, a.id, b.id, 9, 11)
    assert m.winner_id == b.id


@pytest.mark.parametrize("s1,s2", [(11, 10), (3, 3), (20, 1)])
def test_record_match_rejects_bad_scores(session, s1, s2):
    a = services.create_player(session, "A")
    b = services.create_player(session, "B")
    with pytest.raises(services.Invalid):
        services.record_match(session, a.id, b.id, s1, s2)


def test_record_match_same_player(session):
    a = services.create_player(session, "A")
    with pytest.raises(services.Invalid):
        services.record_match(session, a.id, a.id, 11, 0)


def test_record_match_unknown_player(session):
    a = services.create_player(session, "A")
    with pytest.raises(services.NotFound):
        services.record_match(session, a.id, 999, 11, 0)


def test_leaderboard_order_and_stats(session):
    a = services.create_player(session, "A")
    b = services.create_player(session, "B")
    c = services.create_player(session, "C")
    services.record_match(session, b.id, a.id, 11, 3)
    services.record_match(session, b.id, c.id, 11, 5)
    board = services.leaderboard(session)
    assert [r["name"] for r in board][0] == "B"
    assert board[0]["rank"] == 1 and board[0]["win_rate"] == 1.0 and board[0]["games"] == 2
    zero = services.create_player(session, "Z")
    assert next(r for r in services.leaderboard(session) if r["id"] == zero.id)["win_rate"] == 0


def test_delete_player_with_matches_conflicts(session):
    a = services.create_player(session, "A")
    b = services.create_player(session, "B")
    c = services.create_player(session, "C")
    services.record_match(session, a.id, b.id, 11, 0)
    with pytest.raises(services.Conflict):
        services.delete_player(session, a.id)
    services.delete_player(session, c.id)
    with pytest.raises(services.NotFound):
        services.get_player(session, c.id)


def test_list_matches_filter(session):
    a, b, c = (services.create_player(session, n) for n in "ABC")
    services.record_match(session, a.id, b.id, 11, 0)
    services.record_match(session, b.id, c.id, 11, 0)
    assert len(services.list_matches(session)) == 2
    assert len(services.list_matches(session, player_id=a.id)) == 1
    assert len(services.list_matches(session, limit=1)) == 1
