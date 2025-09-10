#!/usr/bin/env bash

set -e

# Build the new Postgres+RDKit image
echo "Building Postgres+RDKit Docker image..."
docker build -f Dockerfile  --build-arg postgres_image_version="13-bullseye" --build-arg postgres_version=13 --build-arg rdkit_git_ref=Release_2021_03_5 --tag postgres:13-rdkit_2021_03_5 .

# Require data dir as an argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /path/to/postgres_data_directory"
  exit 1
fi

POSTGRES_DATA_DIR=$1

echo "Using Postgres data directory: $POSTGRES_DATA_DIR"

# Stop and any existing Postgres container (assuming listening to 5432)
containers=$(docker ps -a | grep ':5432->5432' | awk '{print $1}')
if [ ! -z "$containers" ]; then
  echo "Found existing Postgres containers: $containers"
  echo "Stop existing Postgres containers? (y/n)"
  read answer
  if [ "$answer" != "y" ]; then
    echo "Aborting."
    exit 1
  fi
  
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