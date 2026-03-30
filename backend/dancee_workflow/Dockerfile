# Build stage
FROM oven/bun:latest AS build

WORKDIR /app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY tsconfig.json ./
COPY src ./src

RUN bun run build

# Runtime stage
FROM debian:bookworm-slim

# Install Node.js, supervisord, curl, and xz-utils
RUN apt-get update && apt-get install -y \
    curl \
    supervisor \
    ca-certificates \
    xz-utils \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Restate server binary
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then RESTATE_ARCH="x86_64-unknown-linux-musl"; \
    elif [ "$ARCH" = "arm64" ]; then RESTATE_ARCH="aarch64-unknown-linux-musl"; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi && \
    curl -L -o /tmp/restate-server.tar.xz \
    "https://github.com/restatedev/restate/releases/latest/download/restate-server-${RESTATE_ARCH}.tar.xz" && \
    tar -xJf /tmp/restate-server.tar.xz -C /tmp && \
    mv /tmp/restate-server-*/restate-server /usr/local/bin/restate-server && \
    chmod +x /usr/local/bin/restate-server && \
    rm -rf /tmp/restate-server*

# Set up application
WORKDIR /app

COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package.json ./

# Copy supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080 9070 9080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
