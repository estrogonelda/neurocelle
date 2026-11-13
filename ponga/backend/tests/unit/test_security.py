import time

import jwt
import pytest

from app.core import security


def test_hash_and_verify_roundtrip():
    h = security.hash_password("s3cret", iterations=1000)
    assert h.startswith("pbkdf2_sha256$1000$")
    assert security.verify_password("s3cret", h)
    assert not security.verify_password("wrong", h)


def test_hashes_are_salted():
    assert security.hash_password("x", iterations=1000) != security.hash_password(
        "x", iterations=1000
    )


def test_empty_password_rejected():
    with pytest.raises(ValueError):
        security.hash_password("")


@pytest.mark.parametrize("garbage", ["", "nope", "a$b$c$d", "pbkdf2_sha256$x$y$z"])
def test_verify_garbage_is_false(garbage):
    assert security.verify_password("pw", garbage) is False


def test_token_roundtrip():
    token = security.create_access_token("alice", "k", 5, extra={"admin": True})
    payload = security.decode_access_token(token, "k")
    assert payload["sub"] == "alice" and payload["admin"] is True


def test_token_wrong_secret():
    token = security.create_access_token("alice", "k", 5)
    with pytest.raises(jwt.InvalidSignatureError):
        security.decode_access_token(token, "other")


def test_token_expired():
    token = security.create_access_token("alice", "k", -1)
    time.sleep(0.01)
    with pytest.raises(jwt.ExpiredSignatureError):
        security.decode_access_token(token, "k")
