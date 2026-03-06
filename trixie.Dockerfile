FROM postgres:17-trixie

RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
      postgresql-17-rdkit \
      postgresql-17-pgvector \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
