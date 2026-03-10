# ─────────────────────────────────────────────────────────────────────────────
# Stage 1 – deps: install only production dependencies
# ─────────────────────────────────────────────────────────────────────────────
FROM node:20-alpine AS deps

WORKDIR /app

# Copy manifests first to leverage layer caching
COPY package*.json ./

# Install production deps only
RUN npm ci --omit=dev && npm cache clean --force

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2 – test: install all deps and run tests
# ─────────────────────────────────────────────────────────────────────────────
FROM node:20-alpine AS test

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY app.js app.test.js ./

RUN npm test

# ─────────────────────────────────────────────────────────────────────────────
# Stage 3 – release: lean production image
# ─────────────────────────────────────────────────────────────────────────────
FROM node:20-alpine AS release

# Security: upgrade OS packages
RUN apk upgrade --no-cache

WORKDIR /app

# Copy production node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy application source
COPY app.js ./
COPY package.json ./

# Create a non-root user/group and own the workdir
RUN addgroup -S appgroup && adduser -S appuser -G appgroup \
  && chown -R appuser:appgroup /app

USER appuser

# Expose application port
EXPOSE 3000

# Health check so Docker / ECS knows when the container is ready
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

# Use exec form to ensure SIGTERM is received by the Node process
CMD ["node", "app.js"]
