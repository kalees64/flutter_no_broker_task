import { createApp } from '../app.js';
import { pool } from '../database/pool.js';
import http from 'http';

async function runAuthTests() {
  console.log('🧪 Starting Phase 1 Backend Foundation Tests...\n');

  const app = createApp();
  const server = http.createServer(app);

  await new Promise<void>((resolve) => {
    server.listen(0, () => resolve());
  });

  const address = server.address() as any;
  const baseUrl = `http://localhost:${address.port}/api/v1`;

  let testPassed = 0;
  let testFailed = 0;

  function assert(condition: boolean, testName: string, detail?: any) {
    if (condition) {
      console.log(`  ✅ PASS: ${testName}`);
      testPassed++;
    } else {
      console.error(`  ❌ FAIL: ${testName}`, detail || '');
      testFailed++;
    }
  }

  try {
    // Generate unique test data per run
    const uniqueSuffix = Date.now();
    const testEmail = `test.user.${uniqueSuffix}@nobroker.in`;
    const testPhone = `+9198${(uniqueSuffix % 100000000).toString().padStart(8, '0')}`;
    const testPassword = 'Password123!';

    // Clean up any previous test users to ensure clean slate
    await pool.query("DELETE FROM users WHERE email LIKE 'test.user.%@nobroker.in';");

    // Test 1: Health Endpoint
    console.log('--- Test Group 1: System Health ---');
    const healthRes = await fetch(`http://localhost:${address.port}/health`);
    const healthJson: any = await healthRes.json();
    assert(healthRes.status === 200 && healthJson.success === true, 'GET /health returns 200 OK', healthJson);

    // Test 2: User Registration
    console.log('\n--- Test Group 2: User Registration ---');
    const regRes = await fetch(`${baseUrl}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'Rajesh Sharma',
        email: testEmail,
        password: testPassword,
        phone: testPhone,
        role: 'user',
      }),
    });
    const regJson: any = await regRes.json();
    assert(regRes.status === 201, 'POST /auth/register returns 201 Created', regJson);
    assert(regJson.success === true, 'Registration response has success: true', regJson);
    assert(regJson.data?.user?.email === testEmail, 'User email matches registered email', regJson);
    assert(!regJson.data?.user?.password_hash, 'Security: password_hash is not returned', regJson);

    // Test 3: Duplicate Email Check
    console.log('\n--- Test Group 3: Duplicate Email Conflict ---');
    const dupRes = await fetch(`${baseUrl}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'Rajesh Duplicate',
        email: testEmail,
        password: testPassword,
      }),
    });
    const dupJson: any = await dupRes.json();
    assert(dupRes.status === 409, 'Duplicate register returns 409 Conflict');
    assert(dupJson.success === false, 'Duplicate response has success: false');
    assert(dupJson.code === 'EMAIL_EXISTS', 'Error code is EMAIL_EXISTS');

    // Test 4: Invalid Password Login
    console.log('\n--- Test Group 4: Authentication & Login ---');
    const wrongPassRes = await fetch(`${baseUrl}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        identifier: testEmail,
        password: 'WrongPassword!',
      }),
    });
    const wrongPassJson: any = await wrongPassRes.json();
    assert(wrongPassRes.status === 401, 'Wrong password returns 401 Unauthorized');
    assert(wrongPassJson.code === 'INVALID_CREDENTIALS', 'Error code is INVALID_CREDENTIALS');

    // Test 5: Successful Login
    const loginRes = await fetch(`${baseUrl}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        identifier: testEmail,
        password: testPassword,
      }),
    });
    const loginJson: any = await loginRes.json();
    assert(loginRes.status === 200, 'POST /auth/login returns 200 OK');
    assert(loginJson.success === true, 'Login response has success: true');
    assert(typeof loginJson.data?.accessToken === 'string', 'Login returns valid accessToken');
    assert(typeof loginJson.data?.refreshToken === 'string', 'Login returns valid refreshToken');
    assert(loginJson.data?.user?.email === testEmail, 'Login returns correct user profile');

    const accessToken = loginJson.data?.accessToken;
    let refreshToken = loginJson.data?.refreshToken;

    // Test 6: Protected Route With Token
    console.log('\n--- Test Group 5: Protected Route Guard ---');
    const meRes = await fetch(`${baseUrl}/auth/me`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const meJson: any = await meRes.json();
    assert(meRes.status === 200, 'GET /auth/me with Bearer token returns 200 OK');
    assert(meJson.data?.user?.email === testEmail, 'GET /auth/me returns authenticated user claims');

    // Test 7: Protected Route Without Token
    const unauthRes = await fetch(`${baseUrl}/auth/me`);
    const unauthJson: any = await unauthRes.json();
    assert(unauthRes.status === 401, 'GET /auth/me without header returns 401 Unauthorized');
    assert(unauthJson.code === 'UNAUTHORIZED', 'Error code is UNAUTHORIZED');

    // Test 8: Refresh Token Strategy
    console.log('\n--- Test Group 6: Refresh Token Strategy ---');
    const refreshRes = await fetch(`${baseUrl}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });
    const refreshJson: any = await refreshRes.json();
    assert(refreshRes.status === 200, 'POST /auth/refresh returns 200 OK');
    assert(typeof refreshJson.data?.accessToken === 'string', 'New accessToken returned');
    assert(typeof refreshJson.data?.refreshToken === 'string', 'Rotated refreshToken returned');

    const rotatedRefreshToken = refreshJson.data?.refreshToken;

    // Test 9: Logout Flow
    console.log('\n--- Test Group 7: Logout Flow & Token Invalidation ---');
    const logoutRes = await fetch(`${baseUrl}/auth/logout`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({ refreshToken: rotatedRefreshToken }),
    });
    const logoutJson: any = await logoutRes.json();
    assert(logoutRes.status === 200, 'POST /auth/logout returns 200 OK');
    assert(logoutJson.success === true, 'Logout response has success: true');

    // Test 10: Attempt Refresh with Invalidated Token
    const revokedRefreshRes = await fetch(`${baseUrl}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken: rotatedRefreshToken }),
    });
    const revokedRefreshJson: any = await revokedRefreshRes.json();
    assert(revokedRefreshRes.status === 401, 'Revoked token refresh returns 401');
    assert(revokedRefreshJson.code === 'INVALID_TOKEN', 'Revoked token has code INVALID_TOKEN');

    console.log(`\n📊 Test Summary: ${testPassed} Passed, ${testFailed} Failed.`);

    if (testFailed > 0) {
      process.exit(1);
    }
  } catch (error) {
    console.error('Test execution failed with unexpected error:', error);
    process.exit(1);
  } finally {
    server.close();
    await pool.end();
  }
}

runAuthTests();
