#!/usr/bin/env bash
# Populate the running ponga database with demo data and verify it
# (counts, Elo invariants, and the privileges of each database role).
#   scripts/populate_and_test_db.sh            # populate + verify
#   scripts/populate_and_test_db.sh --reset    # wipe, then populate + verify
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose exec -T backend python -m scripts.populate_db "$@"
