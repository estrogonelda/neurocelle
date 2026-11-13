"""FastAPI application factory."""

from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.api.routes import router
from app.core.config import Settings, get_settings
from app.db import Database
from app.services import ensure_admin


def create_app(settings: Settings | None = None, database: Database | None = None) -> FastAPI:
    settings = settings or get_settings()
    database = database or Database(settings.database_url)

    @asynccontextmanager
    async def lifespan(app: FastAPI):
        with database.SessionLocal() as db:
            ensure_admin(db, settings.admin_username, settings.admin_password)
        yield
        database.engine.dispose()

    app = FastAPI(title="ponga API", version="1.0.0", lifespan=lifespan)
    app.state.settings = settings
    app.state.database = database
    app.include_router(router, prefix="/api")
    return app


def __getattr__(name: str):
    # Lazily build the module-level ASGI app for `uvicorn app.main:app`, so that
    # merely importing app.main (e.g. in tests) does not connect anywhere.
    if name == "app":
        globals()["app"] = create_app()
        return globals()["app"]
    raise AttributeError(name)
