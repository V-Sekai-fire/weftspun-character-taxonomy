# SPDX-License-Identifier: MIT
# Copyright (c) 2026 K. S. Ernest (iFire) Lee
#
# character_taxonomy, containerized. Its SQLite database keeps its pages
# in FoundationDB through datasource-store's weftfdb extension, which the
# runtime stage builds against the FoundationDB client. The entrypoint
# writes the cluster file and TLS files from Fly secrets, migrates (which
# includes the RFD66606-0065 seed migration), then execs the release in the
# foreground.
ARG BASE_TAG=1.20.3-erlang-29.0.5-debian-bookworm-20260803-slim
ARG FDB_VERSION=7.3.76
ARG STORE_REF=bf5d552f5dee0fc871b474c5362ad782a49e89c7

FROM docker.io/hexpm/elixir:${BASE_TAG} AS build

ENV MIX_ENV=prod
WORKDIR /build

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential git ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY lib lib
COPY priv priv
COPY config config
RUN mix deps.compile && mix compile
RUN mix release character_taxonomy --path /build/_release

FROM docker.io/library/debian:bookworm-slim AS runtime

ARG FDB_VERSION
ARG STORE_REF
ARG TARGETARCH=amd64

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    libstdc++6 openssl libncurses6 locales ca-certificates curl \
    cmake build-essential git libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

RUN curl -fsSL --retry 3 -o /tmp/fdb.deb \
      "https://github.com/apple/foundationdb/releases/download/${FDB_VERSION}/foundationdb-clients_${FDB_VERSION}-1_amd64.deb" \
    && dpkg -i /tmp/fdb.deb && rm /tmp/fdb.deb \
    && git clone -q https://github.com/V-Sekai-fire/datasource-store /store \
    && git -C /store checkout -q "${STORE_REF}" \
    && cmake -S /store -B /store/build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build /store/build --target weftfdb

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
ENV TAXONOMY_WEFTFDB_EXTENSION=/store/build/weftfdb
ENV WEFT_FDB_CLUSTER_FILE=/etc/foundationdb/fdb.cluster
ENV PORT=8080
ENV MCP_PORT=4001

WORKDIR /app
COPY --from=build /build/_release ./
COPY deploy/docker-entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080 4001
ENTRYPOINT ["/app/entrypoint.sh"]
