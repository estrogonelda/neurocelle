"""Playwright fixtures for the end-to-end suite (runs against the live stack)."""

from __future__ import annotations

import os
import time
import uuid
from pathlib import Path

import pytest
import requests
from playwright.sync_api import Page, sync_playwright

BASE_URL = os.getenv("BASE_URL", "http://localhost:8080").rstrip("/")
API_URL = os.getenv("API_URL", "http://localhost:8000").rstrip("/")
ADMIN = (os.getenv("ADMIN_USERNAME", "admin"), os.getenv("ADMIN_PASSWORD", "admin123"))
ARTIFACTS = Path(os.getenv("E2E_ARTIFACTS", "artifacts"))


def _wait_for(url: str, timeout: float = 60) -> None:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            if requests.get(url, timeout=2).status_code == 200:
                return
        except requests.RequestException:
            pass
        time.sleep(1)
    raise RuntimeError(f"{url} did not become ready in {timeout}s")


@pytest.fixture(scope="session", autouse=True)
def stack_ready():
    _wait_for(f"{BASE_URL}/healthz")


@pytest.fixture(scope="session")
def browser():
    with sync_playwright() as pw:
        b = pw.chromium.launch()
        yield b
        b.close()


@pytest.fixture
def page(browser, request) -> Page:
    context = browser.new_context(base_url=BASE_URL)
    pg = context.new_page()
    pg.set_default_timeout(10_000)
    yield pg
    rep = getattr(request.node, "rep_call", None)
    if rep is not None and rep.failed:
        ARTIFACTS.mkdir(parents=True, exist_ok=True)
        pg.screenshot(path=str(ARTIFACTS / f"{request.node.name}.png"), full_page=True)
    context.close()


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    setattr(item, f"rep_{rep.when}", rep)


@pytest.fixture
def unique():
    return lambda prefix: f"{prefix}-{uuid.uuid4().hex[:6]}"


@pytest.fixture
def login(page):
    def _login(username: str = ADMIN[0], password: str = ADMIN[1]) -> Page:
        page.goto("/login")
        page.get_by_label("Username").fill(username)
        page.get_by_label("Password").fill(password)
        page.get_by_role("button", name="Log in").click()
        return page

    return _login
