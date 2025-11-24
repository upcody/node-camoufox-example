FROM node:22-bookworm-slim

ENV NODE_ENV=production
WORKDIR /usr/src/app

# latest dependencies
RUN apt-get update

# TODO: figure out if all dependencies needed
## intall dependencies for Python & Playwright
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip \
    wget ca-certificates \
    libuuid1 libatomic1 libx11-6 libxcomposite1 libxdamage1 libxrandr2 \
    libxcursor1 libxi6 libxtst6 libglib2.0-0 libnss3 libnspr4 \
    libdbus-1-3 libxkbcommon0 libxshmfence1 libdrm2 libgbm1 \
    libasound2 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxss1 \
    libgtk-3-0 libasound2 libx11-xcb1 \
    && rm -rf /var/lib/apt/lists/*

# pip
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip

# Camoufox
RUN pip3 install "camoufox[geoip]"
RUN camoufox fetch

# Corepack
RUN corepack enable pnpm

# install
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --prod --frozen-lockfile

# Copy the remaining source files.
COPY . .

EXPOSE 3000
CMD ["node", "src/server.js"]
