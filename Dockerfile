FROM rust:1.90.0-slim  AS builder

RUN apt-get update && apt-get install -y bash curl musl-dev musl openssl default-libmysqlclient-dev

WORKDIR /build

COPY Cargo.toml ./
COPY Cargo.lock ./

RUN mkdir src && echo "fn main() {}" > src/main.rs

RUN cargo build --release

RUN rm -rf src

COPY . .

RUN cargo build --release

# ---- STAGE 2: Runtime ----
FROM debian:bookworm-slim AS runtime

RUN apt-get update && \
    apt-get install -y default-libmysqlclient-dev ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m appuser
WORKDIR /main
COPY --from=builder /build/target/release/rome_naf ./main
RUN chmod +x ./main && chown appuser:appuser ./main
USER appuser

EXPOSE 80

ENTRYPOINT ["./main"]
