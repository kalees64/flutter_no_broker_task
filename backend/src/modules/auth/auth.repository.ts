import { db } from '../../database/pool.js';

export interface UserRecord {
  id: number;
  name: string;
  email: string;
  phone: string | null;
  password_hash: string;
  role: string;
  avatar_url: string | null;
  created_at: Date;
  updated_at: Date;
  is_active: boolean;
}

export interface RefreshTokenRecord {
  id: number;
  user_id: number;
  token: string;
  expires_at: Date;
  created_at: Date;
}

export class AuthRepository {
  async createUser(data: {
    name: string;
    email: string;
    phone?: string | null;
    passwordHash: string;
    role?: string;
    avatarUrl?: string | null;
    flatNumber?: string | null;
    societyName?: string | null;
  }): Promise<UserRecord> {
    const query = `
      INSERT INTO users (name, email, phone, password_hash, role, avatar_url, flat_number, society_name)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *;
    `;
    const values = [
      data.name,
      data.email.toLowerCase(),
      data.phone || null,
      data.passwordHash,
      data.role || 'user',
      data.avatarUrl || null,
      data.flatNumber || null,
      data.societyName || null,
    ];

    const result = await db.query<UserRecord>(query, values);
    return result.rows[0];
  }

  async findUserByEmail(email: string): Promise<UserRecord | null> {
    const query = `SELECT * FROM users WHERE LOWER(email) = LOWER($1) LIMIT 1;`;
    const result = await db.query<UserRecord>(query, [email]);
    return result.rows[0] || null;
  }

  async findUserByPhone(phone: string): Promise<UserRecord | null> {
    const query = `SELECT * FROM users WHERE phone = $1 LIMIT 1;`;
    const result = await db.query<UserRecord>(query, [phone]);
    return result.rows[0] || null;
  }

  async findUserByIdentifier(identifier: string): Promise<UserRecord | null> {
    const query = `
      SELECT * FROM users 
      WHERE LOWER(email) = LOWER($1) OR phone = $1 
      LIMIT 1;
    `;
    const result = await db.query<UserRecord>(query, [identifier]);
    return result.rows[0] || null;
  }

  async findUserById(id: number): Promise<UserRecord | null> {
    const query = `SELECT * FROM users WHERE id = $1 LIMIT 1;`;
    const result = await db.query<UserRecord>(query, [id]);
    return result.rows[0] || null;
  }

  async saveRefreshToken(userId: number, token: string, expiresAt: Date): Promise<RefreshTokenRecord> {
    const query = `
      INSERT INTO refresh_tokens (user_id, token, expires_at)
      VALUES ($1, $2, $3)
      RETURNING *;
    `;
    const result = await db.query<RefreshTokenRecord>(query, [userId, token, expiresAt]);
    return result.rows[0];
  }

  async findRefreshToken(token: string): Promise<RefreshTokenRecord | null> {
    const query = `SELECT * FROM refresh_tokens WHERE token = $1 LIMIT 1;`;
    const result = await db.query<RefreshTokenRecord>(query, [token]);
    return result.rows[0] || null;
  }

  async deleteRefreshToken(token: string): Promise<boolean> {
    const query = `DELETE FROM refresh_tokens WHERE token = $1;`;
    const result = await db.query(query, [token]);
    return (result.rowCount ?? 0) > 0;
  }

  async deleteAllRefreshTokensForUser(userId: number): Promise<void> {
    const query = `DELETE FROM refresh_tokens WHERE user_id = $1;`;
    await db.query(query, [userId]);
  }
}

export const authRepository = new AuthRepository();
