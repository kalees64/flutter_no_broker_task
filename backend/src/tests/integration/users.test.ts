import request from 'supertest';
import { createApp } from '../../app.js';
import { pool } from '../../database/pool.js';
import jwt from 'jsonwebtoken';
import { env } from '../../config/env.js';

describe('Integration Tests: Users CRUD & Search/Pagination (Supertest)', () => {
  const app = createApp();
  let authToken = '';
  let createdUserId: number;

  beforeAll(async () => {
    // Generate valid admin token for testing protected user endpoints
    authToken = jwt.sign(
      { userId: 1, email: 'admin@nobroker.in', role: 'admin' },
      env.JWT_ACCESS_SECRET,
      { expiresIn: '1h' }
    );
  });

  afterAll(async () => {
    await pool.query("DELETE FROM users WHERE email LIKE 'crud.test.%@nobroker.in';");
    await pool.end();
  });

  it('GET /api/v1/users - rejects request without token with 401 UNAUTHORIZED', async () => {
    const res = await request(app).get('/api/v1/users');
    expect(res.status).toBe(401);
    expect(res.body.code).toBe('UNAUTHORIZED');
  });

  it('GET /api/v1/users - returns paginated users with correct structure', async () => {
    const res = await request(app)
      .get('/api/v1/users?page=1&limit=5')
      .set('Authorization', `Bearer ${authToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.items).toBeDefined();
    expect(Array.isArray(res.body.data.items)).toBe(true);
    expect(res.body.data.items.length).toBeLessThanOrEqual(5);
    expect(res.body.data.page).toBe(1);
    expect(typeof res.body.data.totalPages).toBe('number');
    expect(typeof res.body.data.totalItems).toBe('number');
  });

  it('GET /api/v1/users - filters users by search keyword', async () => {
    const res = await request(app)
      .get('/api/v1/users?search=Amit')
      .set('Authorization', `Bearer ${authToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.items.length).toBeGreaterThanOrEqual(1);
    const hasAmit = res.body.data.items.some((u: any) => u.name.includes('Amit'));
    expect(hasAmit).toBe(true);
  });

  it('GET /api/v1/users - filters users by role', async () => {
    const res = await request(app)
      .get('/api/v1/users?role=tenant')
      .set('Authorization', `Bearer ${authToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    res.body.data.items.forEach((item: any) => {
      expect(item.role).toBe('tenant');
    });
  });

  it('GET /api/v1/users - filters users by kycStatus', async () => {
    const res = await request(app)
      .get('/api/v1/users?kycStatus=pending')
      .set('Authorization', `Bearer ${authToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    res.body.data.items.forEach((item: any) => {
      expect(item.kyc_status).toBe('pending');
    });
  });

  it('POST /api/v1/users - creates a new user profile', async () => {
    const uniqueEmail = `crud.test.${Date.now()}@nobroker.in`;
    const res = await request(app)
      .post('/api/v1/users')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        name: 'Karan Mehra',
        email: uniqueEmail,
        password: 'Password123!',
        phone: `+9177${(Date.now() % 100000000).toString().padStart(8, '0')}`,
        role: 'owner',
        flatNumber: 'Villa 99',
        societyName: 'Silver Valley',
        kycStatus: 'verified',
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.name).toBe('Karan Mehra');
    expect(res.body.data.flat_number).toBe('Villa 99');
    expect(res.body.data.id).toBeDefined();

    createdUserId = res.body.data.id;
  });

  it('GET /api/v1/users/:id - reads newly created user by ID', async () => {
    const res = await request(app)
      .get(`/api/v1/users/${createdUserId}`)
      .set('Authorization', `Bearer ${authToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.id).toBe(createdUserId);
    expect(res.body.data.name).toBe('Karan Mehra');
  });

  it('PATCH /api/v1/users/:id - updates user attributes', async () => {
    const res = await request(app)
      .patch(`/api/v1/users/${createdUserId}`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        name: 'Karan S. Mehra',
        kycStatus: 'verified',
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.name).toBe('Karan S. Mehra');
  });

  it('DELETE /api/v1/users/:id - deletes the user by ID', async () => {
    const res = await request(app)
      .delete(`/api/v1/users/${createdUserId}`)
      .set('Authorization', `Bearer ${authToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);

    // Verify deletion returns 404
    const verifyRes = await request(app)
      .get(`/api/v1/users/${createdUserId}`)
      .set('Authorization', `Bearer ${authToken}`);

    expect(verifyRes.status).toBe(404);
  });
});
