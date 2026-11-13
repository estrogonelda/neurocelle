"""End-to-end tests: real browser -> frontend container -> backend -> PostgreSQL."""

import re

import requests
from conftest import ADMIN, API_URL, BASE_URL
from playwright.sync_api import expect


def test_home_page_loads(page):
    page.goto("/")
    expect(page).to_have_title(re.compile("Leaderboard"))
    expect(page.get_by_role("heading", name="Leaderboard")).to_be_visible()


def test_health_endpoints():
    assert requests.get(f"{BASE_URL}/healthz", timeout=5).json()["backend"] == "ok"
    assert requests.get(f"{API_URL}/api/health", timeout=5).json() == {
        "status": "ok",
        "database": "ok",
    }


def test_login_with_wrong_password_fails(login, page):
    login(ADMIN[0], "definitely-wrong")
    expect(page.get_by_role("status")).to_have_text("Invalid username or password.")
    expect(page.get_by_test_id("current-user")).to_have_count(0)


def test_anonymous_user_cannot_record_matches(page):
    page.goto("/matches")
    expect(page.get_by_role("button", name="Record match")).to_have_count(0)
    expect(page.get_by_text("to record a match")).to_be_visible()


def test_full_flow_players_match_leaderboard(login, page, unique):
    login()
    expect(page.get_by_test_id("current-user")).to_contain_text(ADMIN[0])

    winner, loser = unique("Win"), unique("Lose")
    for name in (winner, loser):
        page.goto("/players")
        page.get_by_label("New player").fill(name)
        page.get_by_role("button", name="Add player").click()
        expect(page.get_by_role("status")).to_have_text(f"Player {name} added.")

    page.goto("/matches")
    page.get_by_label("Player 1").select_option(label=winner)
    page.get_by_label("Player 2").select_option(label=loser)
    page.get_by_label("Score").nth(0).fill("11")
    page.get_by_label("Score").nth(1).fill("6")
    page.get_by_role("button", name="Record match").click()
    expect(page.get_by_role("status")).to_contain_text(f"Match recorded: {winner} wins")
    expect(page.get_by_test_id("matches-table")).to_contain_text(winner)

    page.goto("/")
    row = page.get_by_test_id("leaderboard").get_by_role("row").filter(has_text=winner)
    expect(row).to_contain_text("1016")

    page.get_by_role("link", name=loser).click()
    expect(page.get_by_test_id("player-rating")).to_have_text("984")


def test_invalid_score_shows_error(login, page, unique):
    login()
    a, b = unique("A"), unique("B")
    for name in (a, b):
        page.goto("/players")
        page.get_by_label("New player").fill(name)
        page.get_by_role("button", name="Add player").click()
    page.goto("/matches")
    page.get_by_label("Player 1").select_option(label=a)
    page.get_by_label("Player 2").select_option(label=b)
    page.get_by_label("Score").nth(0).fill("11")
    page.get_by_label("Score").nth(1).fill("10")
    page.get_by_role("button", name="Record match").click()
    expect(page.get_by_role("status")).to_contain_text("lead by at least 2")


def test_admin_can_delete_player_without_matches(login, page, unique):
    login()
    name = unique("Temp")
    page.goto("/players")
    page.get_by_label("New player").fill(name)
    page.get_by_role("button", name="Add player").click()
    page.get_by_role("button", name=f"Delete {name}").click()
    expect(page.get_by_role("status")).to_have_text("Player removed.")
    expect(page.get_by_test_id("players-table")).not_to_contain_text(name)


def test_logout(login, page):
    login()
    page.get_by_role("button", name="Log out").click()
    expect(page.get_by_role("status")).to_have_text("Logged out.")
    expect(page.get_by_role("link", name="Log in")).to_be_visible()
