#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <bind_directory>"
  echo "Example: $0 /Users/jeff/Documents/Projects/kaleidoscope/db"
  exit 1
fi

BIND_DIR="$1"

if [ ! -d "$BIND_DIR" ]; then
  echo "Error: Directory '$BIND_DIR' does not exist"
  exit 1
fi

POSTGRES_DATA="$BIND_DIR/postgres_data"
POSTGRES_DATA_OLD="$BIND_DIR/postgres_data_old"

if [ ! -d "$POSTGRES_DATA" ]; then
  echo "Error: postgres_data directory does not exist at '$POSTGRES_DATA'"
  exit 1
fi

PG_VERSION_FILE="$POSTGRES_DATA/PG_VERSION"
if [ ! -f "$PG_VERSION_FILE" ]; then
  echo "Error: PG_VERSION file not found at '$PG_VERSION_FILE'"
  exit 1
fi

PG_VERSION=$(cat "$PG_VERSION_FILE")
if [ "$PG_VERSION" != "13" ]; then
  echo "Error: Expected PostgreSQL version 13, but found version $PG_VERSION"
  exit 1
fi

if [ -d "$POSTGRES_DATA_OLD" ]; then
  echo "Error: postgres_data_old already exists at '$POSTGRES_DATA_OLD'"
  echo "Please remove or rename it before running this script"
  exit 1
fi

echo "Moving $POSTGRES_DATA to $POSTGRES_DATA_OLD..."
mv "$POSTGRES_DATA" "$POSTGRES_DATA_OLD"

echo "Running PostgreSQL upgrade from 13 to 17..."
docker run --rm \
  --mount "type=bind,src=$BIND_DIR,dst=/var/lib/postgresql" \
  --env 'PGDATAOLD=/var/lib/postgresql/postgres_data_old' \
  --env 'PGDATANEW=/var/lib/postgresql/postgres_data' \
  tianon/postgres-upgrade:13-to-17 \
  -c '--socketdir=/var/run/postgresql'

echo "Upgrade completed successfully!"
