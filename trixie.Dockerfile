FROM postgres:17-trixie

RUN apt-get update \
    && apt-get install -yq --no-install-recommends postgresql-17-rdkit \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
