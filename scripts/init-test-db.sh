#!/bin/bash
# Cria o banco de teste na primeira inicialização do volume.
# Se o volume já existir, este script não roda: use docker compose down -v.
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE ${POSTGRES_DB}_test;
    GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB}_test TO $POSTGRES_USER;
EOSQL
