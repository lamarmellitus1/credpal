# Stage 1 – deps: install only production dependencies
FROM node:20-alpine AS deps

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev && npm cache clean --force


FROM node:20-alpine AS test

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY app.js app.test.js ./

RUN npm test

FROM node:20-alpine AS release

RUN apk upgrade --no-cache

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules

COPY app.js ./
COPY package.json ./

RUN addgroup -S appgroup && adduser -S appuser -G appgroup \
  && chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "app.js"]
