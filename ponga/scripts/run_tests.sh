#!/usr/bin/env bash
# Run every test suite locally, mirroring .github/workflows/ponga-ci.yml.
#   scripts/run_tests.sh [lint|unit|integration|e2e|all]
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$PWD
VENV=${VENV:-$ROOT/.venv}
STAGE=${1:-all}

set -a; [ -f .env ] && . ./.env; set +a
APP_PW=${PONGA_APP_PASSWORD:-ponga_app_pw}
OWNER_PW=${PONGA_OWNER_PASSWORD:-ponga_owner_pw}
RO_PW=${PONGA_READONLY_PASSWORD:-ponga_readonly_pw}
DB=${PONGA_DB:-ponga}
PORT=${DB_PORT:-5432}

venv() {
  if [ ! -x "$VENV/bin/python" ]; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install -q -r backend/requirements-dev.txt -r frontend/requirements-dev.txt
  fi
}

lint() {
  venv
  "$VENV/bin/ruff" check backend frontend e2e
  "$VENV/bin/ruff" format --check backend frontend e2e
}

unit() {
  venv
  (cd backend && "$VENV/bin/python" -m pytest tests/unit --cov=app --cov=scripts --cov-report=term-missing)
  (cd frontend && "$VENV/bin/python" -m pytest tests/unit --cov=app --cov-report=term-missing)
}

integration() {
  venv
  docker compose up -d --wait db
  (cd backend && \
    TEST_DATABASE_URL="postgresql+psycopg://ponga_app:$APP_PW@localhost:$PORT/$DB" \
    TEST_MIGRATION_DATABASE_URL="postgresql+psycopg://ponga_owner:$OWNER_PW@localhost:$PORT/$DB" \
    TEST_READONLY_DATABASE_URL="postgresql+psycopg://ponga_readonly:$RO_PW@localhost:$PORT/$DB" \
    "$VENV/bin/python" -m pytest tests/integration -v)
}

e2e() {
  docker compose up -d --build --wait
  scripts/populate_and_test_db.sh --reset
  docker compose --profile e2e run --rm --build e2e
}

case "$STAGE" in
  lint) lint ;;
  unit) unit ;;
  integration) integration ;;
  e2e) e2e ;;
  all) lint; unit; integration; e2e ;;
  *) echo "usage: $0 [lint|unit|integration|e2e|all]" >&2; exit 2 ;;
esac
echo "✔ $STAGE passed"
