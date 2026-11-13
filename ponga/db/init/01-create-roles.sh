#!/bin/bash
# Runs once, on first start of an empty data volume (docker-entrypoint-initdb.d).
# Creates the database roles used by ponga:
#   ponga_owner    - owns the schema; used only for migrations / DDL
#   ponga_app      - used by the backend at runtime (DML only, no DDL)
#   ponga_readonly - SELECT-only, for reporting / debugging
set -euo pipefail

: "${PONGA_DB:?PONGA_DB is required}"
: "${PONGA_OWNER_PASSWORD:?PONGA_OWNER_PASSWORD is required}"
: "${PONGA_APP_PASSWORD:?PONGA_APP_PASSWORD is required}"
: "${PONGA_READONLY_PASSWORD:?PONGA_READONLY_PASSWORD is required}"

psql -v ON_ERROR_STOP=1 \
     --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
     -v db="$PONGA_DB" \
     -v owner_pw="$PONGA_OWNER_PASSWORD" \
     -v app_pw="$PONGA_APP_PASSWORD" \
     -v ro_pw="$PONGA_READONLY_PASSWORD" <<'SQL'
CREATE ROLE ponga_owner    LOGIN PASSWORD :'owner_pw';
CREATE ROLE ponga_app      LOGIN PASSWORD :'app_pw';
CREATE ROLE ponga_readonly LOGIN PASSWORD :'ro_pw';

CREATE DATABASE :"db" OWNER ponga_owner;
REVOKE ALL ON DATABASE :"db" FROM PUBLIC;
GRANT CONNECT ON DATABASE :"db" TO ponga_app, ponga_readonly;

\connect :"db"

CREATE SCHEMA ponga AUTHORIZATION ponga_owner;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA ponga TO ponga_app, ponga_readonly;

ALTER ROLE ponga_owner    IN DATABASE :"db" SET search_path = ponga;
ALTER ROLE ponga_app      IN DATABASE :"db" SET search_path = ponga;
ALTER ROLE ponga_readonly IN DATABASE :"db" SET search_path = ponga;

-- Every object ponga_owner creates later gets the right grants automatically.
ALTER DEFAULT PRIVILEGES FOR ROLE ponga_owner IN SCHEMA ponga
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ponga_app;
ALTER DEFAULT PRIVILEGES FOR ROLE ponga_owner IN SCHEMA ponga
    GRANT USAGE, SELECT ON SEQUENCES TO ponga_app;
ALTER DEFAULT PRIVILEGES FOR ROLE ponga_owner IN SCHEMA ponga
    GRANT SELECT ON TABLES TO ponga_readonly;
SQL

echo "ponga: roles, database '$PONGA_DB' and schema 'ponga' created."
