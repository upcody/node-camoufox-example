FROM node:22-bookworm-slim AS base

ENV NODE_ENV=production
WORKDIR /usr/src/app

# TODO: try use python image where nodejs is installed
# TODO: maybe is server is simple enough, we can make it pure python

# System dependencies for Python, Camoufox, and Playwright
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 python3-venv \
        libgtk-3-0 libasound2 libx11-xcb1 \
    && rm -rf /var/lib/apt/lists/*

# Python environment with Camoufox assets baked in
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir "camoufox[geoip]" \
    && /opt/venv/bin/camoufox fetch \
    && rm -rf /root/.cache/pip

ENV PATH="/opt/venv/bin:$PATH"

FROM base AS deps

# Install production Node dependencies with pnpm
RUN corepack enable pnpm
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --prod --frozen-lockfile

FROM base AS runtime

COPY --from=deps /usr/src/app/node_modules ./node_modules
# Copy the remaining source files (node_modules stays excluded by .dockerignore).
COPY . .

EXPOSE 3000
CMD ["node", "src/server.js"]
