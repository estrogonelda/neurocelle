# ponga 🏓

A table-tennis league web app: register players, record matches, and follow an
Elo-rated leaderboard. Written entirely in Python, with PostgreSQL as the
database, each tier in its own container, orchestrated with Docker Compose.

```
 browser ──► frontend (Flask + gunicorn, :8080)
                 │  HTTP/JSON  (network "web")
                 ▼
             backend (FastAPI + SQLAlchemy, :8000)
                 │  SQL as role ponga_app  (network "data")
                 ▼
             db (PostgreSQL 16)
```

The frontend has no route to the database: it sits only on the `web` network,
and the database sits only on `data`.

## Quick start

```bash
cp .env.example .env              # change the passwords and secrets
docker compose up -d --build --wait
scripts/populate_and_test_db.sh   # demo users, players and 40 matches, then checks
open http://localhost:8080        # log in as admin / $ADMIN_PASSWORD (default admin123)
```

The API docs are at http://localhost:8000/docs.

Shortcuts in the `Makefile`: `up`, `down`, `clean`, `populate`,
`reset-db`, `lint`, `unit`, `integration`, `e2e`, `test`.

## Users

**Database roles.** `db/init/01-create-roles.sh` creates these on the first start of an empty volume:

| Role             | Used by                                 | Privileges                                    |
|------------------|-----------------------------------------|-----------------------------------------------|
| `postgres`       | the container itself                    | superuser (bootstrap only)                    |
| `ponga_owner`    | `python -m app.migrate` at backend start | owns database `ponga` and schema `ponga`; DDL |
| `ponga_app`      | backend at runtime                      | SELECT/INSERT/UPDATE/DELETE only, no DDL      |
| `ponga_readonly` | reporting and debugging                 | SELECT only                                   |

Default privileges give `ponga_app` and `ponga_readonly` access to every table
`ponga_owner` creates.

**Application accounts.** The backend creates the admin account
(`ADMIN_USERNAME`/`ADMIN_PASSWORD`) on startup if it is missing. The populate
script adds the demo accounts `referee/referee123`, `alice/alice123` and
`bob/bob12345`. Passwords are stored as salted PBKDF2-SHA256 hashes, and the API
uses JWT bearer tokens.

- Anyone can view the leaderboard, players and matches.
- Logged-in users can add players and record matches.
- Admins can also create users (`POST /api/users`) and delete players that have no matches.

## Populating and testing the database

`scripts/populate_and_test_db.sh [--reset] [--verify-only]` runs
`backend/scripts/populate_db.py` inside the backend container. It is
idempotent. After loading the data it checks that:

- the expected users, players and matches exist, and an admin account exists;
- Elo points are conserved (the sum of ratings is 1000 × the number of players);
- total wins and total losses each equal the number of matches;
- every match winner is one of its two players, and the leaderboard is sorted;
- the backend connects as `ponga_app` in schema `ponga`;
- `ponga_app` cannot run `CREATE` or `DROP`, and `ponga_readonly` can `SELECT` but cannot `INSERT` or `DELETE`.

It exits with a non-zero status if any check fails.

## Tests

| Suite        | Where                                     | Runs against                                         |
|--------------|-------------------------------------------|------------------------------------------------------|
| Unit         | `backend/tests/unit`, `frontend/tests/unit` | in-memory SQLite and a fake backend client; no services needed |
| Integration  | `backend/tests/integration`                | the real PostgreSQL container, with its roles and grants |
| End-to-end   | `e2e/tests` (Playwright, Chromium)         | the full stack, through a real browser               |

```bash
scripts/run_tests.sh lint|unit|integration|e2e|all
```

Integration tests skip themselves unless `TEST_DATABASE_URL` and
`TEST_MIGRATION_DATABASE_URL` are set; `run_tests.sh integration` sets them.
The e2e runner is a Compose service under the `e2e` profile
(`docker compose --profile e2e run --rm e2e`). It saves screenshots of failing
tests to `e2e/artifacts/`.

## CI/CD

`.github/workflows/ponga-ci.yml` (at the repository root) runs these jobs:

1. **lint**: `ruff check`, `ruff format --check`, `docker compose config`.
2. **unit**: a matrix over backend and frontend, with coverage and JUnit reports uploaded.
3. **integration**: starts the `db` service with Compose and runs the integration tests.
4. **e2e**: builds and starts the whole stack, runs the populate-and-verify script, then runs Playwright. On failure it dumps the logs and uploads screenshots.
5. **deliver** (CD): on pushes to the default branch or to `v*` tags, builds the
   backend and frontend images and pushes them to
   `ghcr.io/<owner>/ponga-{backend,frontend}`, tagged with the sha, the git tag and `latest`.

## Project layout

```
ponga/
├── docker-compose.yml   .env.example   Makefile
├── db/init/01-create-roles.sh          # roles, database, schema, grants
├── backend/                            # FastAPI service
│   ├── app/{main,models,schemas,services,db,migrate}.py
│   ├── app/core/{config,security,elo}.py
│   ├── app/api/{routes,deps}.py
│   ├── scripts/populate_db.py
│   └── tests/{unit,integration}/
├── frontend/                           # Flask service (Jinja templates)
│   ├── app/{web,api_client}.py  app/templates/  app/static/
│   └── tests/unit/
├── e2e/                                # Playwright suite + its Dockerfile
└── scripts/{populate_and_test_db,run_tests}.sh
```

## Building behind a TLS-intercepting proxy

The Dockerfiles accept an optional BuildKit secret named `ca_bundle`. It is used
only during `pip install` and is never stored in an image:

```bash
docker build --secret id=ca_bundle,src=/path/to/ca.pem -t ponga-backend backend
```
