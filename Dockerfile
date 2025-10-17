FROM rust:1.90.0-slim  AS builder

RUN apt-get update && apt-get install -y bash curl openssl default-libmysqlclient-dev

WORKDIR /build

COPY . .

RUN --mount=type=cache,target=/build/target \
    --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo build --release;
    cp /build/target/release/rome_naf /build/rome_naf \
    cp /build/Rocket.toml /build

# ---- STAGE 2: Runtime ----
FROM debian:bookworm-slim AS runtime

RUN apt-get update && \
    apt-get install -y default-libmysqlclient-dev ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m appuser
WORKDIR /main
COPY --from=builder /build/rome_naf ./main
COPY --from=builder /build/Rocket.toml ./Rocket.toml

RUN chmod +x ./main && chown appuser:appuser ./main
USER appuser

ENV ROCKET_ADDRESS=0.0.0.0
ENV ROCKET_PORT=8000

EXPOSE 8000

ENTRYPOINT ["./main"]
