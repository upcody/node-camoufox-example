FROM node:20-slim

ENV NODE_ENV=production
WORKDIR /usr/src/app

# Install system dependencies needed for Camoufox/Playwright browsers.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    wget \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js dependencies first for better caching.
COPY package*.json ./
RUN npm install --omit=dev

# Pre-download Camoufox's managed browser with GeoIP data so runtime containers start faster.
RUN npx camoufox install --geoip

# Copy the remaining source files.
COPY . .

EXPOSE 3000
CMD ["node", "src/server.js"]
