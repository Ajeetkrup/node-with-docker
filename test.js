const request = require('supertest');
const express = require('express');
const app = express();

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.VERSION || '1.0.0'
  });
});

// Test cases
describe('GET /health', () => {
  it('should return health status and metadata', (done) => {
    request(app)
      .get('/health')
      .expect('Content-Type', /json/)
      .expect(200)
      .expect(res => {
        if (!res.body.status || res.body.status !== 'healthy') throw new Error('Missing or invalid status');
        if (!res.body.timestamp) throw new Error('Missing timestamp');
        if (typeof res.body.uptime !== 'number') throw new Error('Invalid uptime');
        if (!res.body.version) throw new Error('Missing version');
      })
      .end(done);
  });
});
