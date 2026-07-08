#!/bin/bash
set -e

until pg_isready -h "${PGHOST:-postgres}" -p "${PGPORT:-5432}" -U "${PGUSER:-zeroring}" 2>/dev/null; do
    echo "[entrypoint] waiting for PostgreSQL..."
    sleep 2
done

export ZERORING_DB="host=${PGHOST:-postgres} port=${PGPORT:-5432} dbname=${PGDATABASE:-zeroring} user=${PGUSER:-zeroring} password=${PGPASSWORD:-zeroring}"

/usr/local/bin/server &
SERVER_PID=$!

nginx -g "daemon off;" &
NGINX_PID=$!

cleanup() {
    kill "$SERVER_PID" "$NGINX_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

wait "$SERVER_PID" "$NGINX_PID"
