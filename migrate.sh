#!/usr/bin/env bash

set -e

# Build the new Postgres+RDKit image
echo "Building Postgres+RDKit Docker image..."
docker build -f Dockerfile  --build-arg postgres_image_version="13-bullseye" --build-arg postgres_version=13 --build-arg rdkit_git_ref=Release_2021_03_5 --tag postgres:13-rdkit_2021_03_5 .

# If a data dir is specified, use it; otherwise, use the default
if [ -z "$1" ]; then
  POSTGRES_DATA_DIR="$HOME/kaleidoscope/db/postgres_data"
else
  POSTGRES_DATA_DIR="$1"
fi

echo "Using Postgres data directory: $POSTGRES_DATA_DIR"

# Stop and any existing Postgres container (assuming listening to 5432)
containers=$(docker ps -a | grep ':5432->5432' | awk '{print $1}')
if [ ! -z "$containers" ]; then
  echo "Stopping and removing existing Postgres containers..."
  for container in $containers; do
    docker stop $container
  done
fi

# Start the Postgres container
echo "Starting Postgres container..."
docker run \
  -p 5432:5432 \
  --name postgres-rdkit \
  -v "$POSTGRES_DATA_DIR":/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=postgres \
  -d postgres:13-rdkit_2021_03_5