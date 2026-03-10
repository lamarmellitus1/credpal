'use strict';

const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');

const app = express();
app.use(express.json());

// ── Logging middleware ────────────────────────────────────────────────────────
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    console.log(
      JSON.stringify({
        timestamp: new Date().toISOString(),
        method: req.method,
        path: req.path,
        status: res.statusCode,
        duration_ms: Date.now() - start,
        ip: req.ip,
      })
    );
  });
  next();
});

// ── DB / Cache clients ────────────────────────────────────────────────────────
const pgPool = new Pool({
  host: process.env.POSTGRES_HOST || 'db',
  port: Number(process.env.POSTGRES_PORT) || 5432,
  database: process.env.POSTGRES_DB || 'appdb',
  user: process.env.POSTGRES_USER || 'appuser',
  password: process.env.POSTGRES_PASSWORD,
  max: 10,
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 2_000,
});

const redisClient = redis.createClient({
  url: `redis://:${process.env.REDIS_PASSWORD || 'mellitus'}@${process.env.REDIS_HOST || 'cache'}:${process.env.REDIS_PORT || 6379}`,
});

redisClient.on('error', (err) => console.error('Redis error:', err));
redisClient.connect().catch((err) => console.error('Redis connect failed:', err));

// ── Routes ────────────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/status', async (_req, res) => {
  const checks = { postgres: 'ok', redis: 'ok' };

  try {
    await pgPool.query('SELECT 1');
  } catch {
    checks.postgres = 'unavailable';
  }

  try {
    await redisClient.ping();
  } catch {
    checks.redis = 'unavailable';
  }

  const allOk = Object.values(checks).every((v) => v === 'ok');
  res
    .status(allOk ? 200 : 503)
    .json({ status: allOk ? 'healthy' : 'degraded', checks, uptime: process.uptime() });
});

app.post('/process', async (req, res) => {
  const { data } = req.body;
  if (!data) {
    return res.status(400).json({ error: 'Missing "data" field in request body' });
  }

  // Cache result in Redis (TTL: 60 s)
  const cacheKey = `process:${Buffer.from(String(data)).toString('base64')}`;
  const cached = await redisClient.get(cacheKey).catch(() => null);
  if (cached) {
    return res.json({ result: JSON.parse(cached), source: 'cache' });
  }

  const result = { processed: data, timestamp: new Date().toISOString(), pid: process.pid };

  await redisClient.setEx(cacheKey, 60, JSON.stringify(result)).catch(() => null);

  res.json({ result, source: 'computed' });
});

// ── Start ─────────────────────────────────────────────────────────────────────
const PORT = Number(process.env.PORT) || 3000;
const server = app.listen(PORT, () => {
  console.log(JSON.stringify({ event: 'server_started', port: PORT, env: process.env.NODE_ENV }));
});

// Graceful shutdown
const shutdown = (signal) => {
  console.log(JSON.stringify({ event: 'shutdown', signal }));
  server.close(async () => {
    await pgPool.end().catch(() => null);
    await redisClient.quit().catch(() => null);
    process.exit(0);
  });
};
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

module.exports = { app };
