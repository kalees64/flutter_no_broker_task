import request from 'supertest';
import { createApp } from '../../app.js';
import { pool } from '../../database/pool.js';

describe('Integration Tests: Auth APIs (Supertest)', () => {
  const app = createApp();
  const testSuffix = Date.now();
  const testEmail = `supertest.auth.${testSuffix}@nobroker.in`;
  const testPhone = `+9188${(testSuffix % 100000000).toString().padStart(8, '0')}`;
  const testPassword = 'Password123!';
  let accessToken = '';
  let refreshToken = '';

  afterAll(async () => {
    await pool.query("DELETE FROM users WHERE email LIKE 'supertest.auth.%@nobroker.in';");
    await pool.end();
  });

  it('POST /api/v1/auth/register - successfully registers a user', async () => {
    const res = await request(app)
      .post('/api/v1/auth/register')
      .send({
        name: 'Supertest User',
        email: testEmail,
        password: testPassword,
        phone: testPhone,
        role: 'tenant',
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.email).toBe(testEmail);
    expect(res.body.data.user.password_hash).toBeUndefined();
  });

  it('POST /api/v1/auth/register - rejects duplicate email with 409 EMAIL_EXISTS', async () => {
    const res = await request(app)
      .post('/api/v1/auth/register')
      .send({
        name: 'Duplicate Supertest',
        email: testEmail,
        password: testPassword,
      });

    expect(res.status).toBe(409);
    expect(res.body.success).toBe(false);
    expect(res.body.code).toBe('EMAIL_EXISTS');
  });

  it('POST /api/v1/auth/login - rejects wrong password with 401 INVALID_CREDENTIALS', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({
        identifier: testEmail,
        password: 'IncorrectPassword!',
      });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.code).toBe('INVALID_CREDENTIALS');
  });

  it('POST /api/v1/auth/login - returns access and refresh tokens with 200 OK', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({
        identifier: testEmail,
        password: testPassword,
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.accessToken).toBeDefined();
    expect(res.body.data.refreshToken).toBeDefined();

    accessToken = res.body.data.accessToken;
    refreshToken = res.body.data.refreshToken;
  });

  it('GET /api/v1/auth/me - rejects request without token with 401 UNAUTHORIZED', async () => {
    const res = await request(app).get('/api/v1/auth/me');
    expect(res.status).toBe(401);
    expect(res.body.code).toBe('UNAUTHORIZED');
  });

  it('GET /api/v1/auth/me - accepts valid Bearer token and returns claims', async () => {
    const res = await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${accessToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.email).toBe(testEmail);
  });

  it('POST /api/v1/auth/refresh - rotates refresh token', async () => {
    const res = await request(app)
      .post('/api/v1/auth/refresh')
      .send({ refreshToken });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.accessToken).toBeDefined();
    expect(res.body.data.refreshToken).toBeDefined();

    refreshToken = res.body.data.refreshToken;
  });

  it('POST /api/v1/auth/logout - invalidates session', async () => {
    const res = await request(app)
      .post('/api/v1/auth/logout')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ refreshToken });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });
});
