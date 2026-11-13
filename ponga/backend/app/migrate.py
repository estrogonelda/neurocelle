"""Create/upgrade the schema with the owner role. Run before the API starts.

python -m app.migrate
"""

from __future__ import annotations

import sys
import time

from sqlalchemy.exc import OperationalError

from app.core.config import get_settings
from app.db import Database


def main(retries: int = 30, delay: float = 2.0) -> int:
    settings = get_settings()
    db = Database(settings.migration_database_url)
    for attempt in range(1, retries + 1):
        try:
            db.create_schema()
            print("ponga: schema is up to date")
            return 0
        except OperationalError as exc:
            print(f"ponga: database not ready ({attempt}/{retries}): {exc.orig}", file=sys.stderr)
            time.sleep(delay)
        finally:
            db.engine.dispose()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
