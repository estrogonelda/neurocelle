"""Password hashing (PBKDF2, stdlib) and JWT access tokens."""

from __future__ import annotations

import base64
import hashlib
import hmac
import os
from datetime import UTC, datetime, timedelta

import jwt

_ALGO = "sha256"
_ITERATIONS = 240_000
_JWT_ALGO = "HS256"


def hash_password(password: str, *, iterations: int = _ITERATIONS) -> str:
    if not password:
        raise ValueError("password must not be empty")
    salt = os.urandom(16)
    digest = hashlib.pbkdf2_hmac(_ALGO, password.encode(), salt, iterations)
    salt_b64 = base64.b64encode(salt).decode()
    digest_b64 = base64.b64encode(digest).decode()
    return f"pbkdf2_{_ALGO}${iterations}${salt_b64}${digest_b64}"


def verify_password(password: str, encoded: str) -> bool:
    try:
        scheme, iterations, salt_b64, digest_b64 = encoded.split("$")
        algo = scheme.removeprefix("pbkdf2_")
        salt = base64.b64decode(salt_b64)
        expected = base64.b64decode(digest_b64)
        actual = hashlib.pbkdf2_hmac(algo, password.encode(), salt, int(iterations))
    except (ValueError, TypeError):
        return False
    return hmac.compare_digest(actual, expected)


def create_access_token(
    subject: str, secret: str, ttl_minutes: int, *, extra: dict | None = None
) -> str:
    now = datetime.now(UTC)
    payload = {"sub": subject, "iat": now, "exp": now + timedelta(minutes=ttl_minutes)}
    if extra:
        payload.update(extra)
    return jwt.encode(payload, secret, algorithm=_JWT_ALGO)


def decode_access_token(token: str, secret: str) -> dict:
    """Return the token payload; raises jwt.PyJWTError when invalid/expired."""
    return jwt.decode(token, secret, algorithms=[_JWT_ALGO])
