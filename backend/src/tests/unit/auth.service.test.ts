import { jest, describe, it, expect } from '@jest/globals';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { env } from '../../config/env.js';
import { AuthService } from '../../modules/auth/auth.service.js';

describe('Unit Tests: AuthService & Security Utilities', () => {
  it('should hash a password and verify it successfully with bcrypt', async () => {
    const rawPassword = 'SecurePassword123!';
    const saltRounds = 10;
    const hash = await bcrypt.hash(rawPassword, saltRounds);

    expect(hash).not.toBe(rawPassword);
    expect(hash.startsWith('$2')).toBe(true);

    const isMatch = await bcrypt.compare(rawPassword, hash);
    expect(isMatch).toBe(true);

    const isWrongMatch = await bcrypt.compare('WrongPassword', hash);
    expect(isWrongMatch).toBe(false);
  });

  it('should sign and verify JWT access tokens with correct claims', () => {
    const payload = { userId: 42, email: 'test@nobroker.in', role: 'tenant' };
    const token = jwt.sign(payload, env.JWT_ACCESS_SECRET, { expiresIn: '15m' });

    expect(typeof token).toBe('string');

    const decoded = jwt.verify(token, env.JWT_ACCESS_SECRET) as any;
    expect(decoded.userId).toBe(42);
    expect(decoded.email).toBe('test@nobroker.in');
    expect(decoded.role).toBe('tenant');
  });

  it('should reject invalid signatures on JWT tokens', () => {
    const payload = { userId: 42, email: 'test@nobroker.in', role: 'tenant' };
    const token = jwt.sign(payload, 'wrong_secret_key_1234567890', { expiresIn: '15m' });

    expect(() => {
      jwt.verify(token, env.JWT_ACCESS_SECRET);
    }).toThrow();
  });

  it('should throw EMAIL_EXISTS when registering with an existing email', async () => {
    const mockRepo: any = {
      findUserByEmail: jest.fn(async () => ({ id: 1, email: 'exists@nobroker.in' } as any)),
    };

    const service = new AuthService(mockRepo);

    await expect(
      service.register({
        name: 'Existing User',
        email: 'exists@nobroker.in',
        password: 'Password123!',
        role: 'user',
      })
    ).rejects.toMatchObject({
      code: 'EMAIL_EXISTS',
      statusCode: 409,
    });
  });

  it('should throw INVALID_CREDENTIALS when user does not exist on login', async () => {
    const mockRepo: any = {
      findUserByIdentifier: jest.fn(async () => null),
    };

    const service = new AuthService(mockRepo);

    await expect(
      service.login({
        identifier: 'nonexistent@nobroker.in',
        password: 'Password123!',
      })
    ).rejects.toMatchObject({
      code: 'INVALID_CREDENTIALS',
      statusCode: 401,
    });
  });
});
