'use strict';

const request = require('supertest');

// Mock pg and redis before requiring the app
jest.mock('pg', () => {
  const mPool = {
    query: jest.fn().mockResolvedValue({ rows: [{ '?column?': 1 }] }),
    end: jest.fn().mockResolvedValue(undefined),
  };
  return { Pool: jest.fn(() => mPool) };
});

jest.mock('redis', () => ({
  createClient: jest.fn(() => ({
    on: jest.fn(),
    connect: jest.fn().mockResolvedValue(undefined),
    ping: jest.fn().mockResolvedValue('PONG'),
    get: jest.fn().mockResolvedValue(null),
    setEx: jest.fn().mockResolvedValue('OK'),
    quit: jest.fn().mockResolvedValue(undefined),
  })),
}));

const { app } = require('./app');

describe('GET /health', () => {
  it('returns 200 with status ok', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
    expect(res.body.timestamp).toBeDefined();
  });
});

describe('GET /status', () => {
  it('returns 200 when all services are healthy', async () => {
    const res = await request(app).get('/status');
    expect(res.statusCode).toBe(200);
    expect(res.body.checks.postgres).toBe('ok');
    expect(res.body.checks.redis).toBe('ok');
  });
});

describe('POST /process', () => {
  it('returns 400 when data is missing', async () => {
    const res = await request(app).post('/process').send({});
    expect(res.statusCode).toBe(400);
    expect(res.body.error).toBeDefined();
  });

  it('processes data and returns result', async () => {
    const res = await request(app).post('/process').send({ data: 'hello' });
    expect(res.statusCode).toBe(200);
    expect(res.body.result.processed).toBe('hello');
    expect(['computed', 'cache']).toContain(res.body.source);
  });
});
