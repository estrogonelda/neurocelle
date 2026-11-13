import pytest
import requests

from app.api_client import ApiError, BackendClient


class FakeResponse:
    def __init__(self, status=200, payload=None, text=None):
        self.status_code = status
        self._payload = payload
        self.text = text if text is not None else ("" if payload is None else "json")
        self.content = self.text.encode()
        self.reason = "Reason"

    def json(self):
        if self._payload is None:
            raise ValueError("no json")
        return self._payload


class FakeSession:
    def __init__(self, response=None, exc=None):
        self.response, self.exc, self.calls = response, exc, []

    def request(self, method, url, **kw):
        self.calls.append((method, url, kw))
        if self.exc:
            raise self.exc
        return self.response


def test_login_sends_credentials_and_returns_token():
    s = FakeSession(FakeResponse(200, {"access_token": "abc"}))
    c = BackendClient("http://api/", session=s)
    assert c.login("u", "p") == "abc"
    method, url, kw = s.calls[0]
    assert (method, url) == ("POST", "http://api/api/auth/login")
    assert kw["json"] == {"username": "u", "password": "p"}


def test_token_header_and_params():
    s = FakeSession(FakeResponse(200, []))
    BackendClient("http://api", session=s).matches(limit=5, player_id=3)
    assert s.calls[0][2]["params"] == {"limit": 5, "player_id": 3}
    BackendClient("http://api", session=s).create_player("tok", "Ana")
    assert s.calls[1][2]["headers"] == {"Authorization": "Bearer tok"}


def test_204_returns_none():
    s = FakeSession(FakeResponse(204))
    assert BackendClient("http://api", session=s).delete_player("t", 1) is None


def test_error_detail_string():
    s = FakeSession(FakeResponse(409, {"detail": "exists"}))
    with pytest.raises(ApiError) as e:
        BackendClient("http://api", session=s).create_player("t", "x")
    assert (e.value.status, e.value.detail) == (409, "exists")


def test_error_detail_validation_list():
    detail = [{"loc": ["body", "score1"], "msg": "too big"}]
    s = FakeSession(FakeResponse(422, {"detail": detail}))
    with pytest.raises(ApiError, match="score1: too big"):
        BackendClient("http://api", session=s).record_match("t", 1, 2, 300, 0)


def test_error_non_json():
    s = FakeSession(FakeResponse(500, None, text="boom"))
    with pytest.raises(ApiError, match="boom"):
        BackendClient("http://api", session=s).players()


def test_connection_error_becomes_503():
    s = FakeSession(exc=requests.ConnectionError("nope"))
    with pytest.raises(ApiError) as e:
        BackendClient("http://api", session=s).health()
    assert e.value.status == 503


def test_simple_getters():
    s = FakeSession(FakeResponse(200, {"x": 1}))
    c = BackendClient("http://api", session=s)
    c.me("t"), c.leaderboard()
    assert [call[1] for call in s.calls] == ["http://api/api/auth/me", "http://api/api/leaderboard"]
