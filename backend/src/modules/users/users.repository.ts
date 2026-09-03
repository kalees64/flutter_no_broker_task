import { db } from "../../database/pool.js";
import { ListUsersQuery } from "./users.validator.js";

export interface UserDetailsRecord {
  id: number;
  name: string;
  email: string;
  phone: string | null;
  password_hash: string;
  role: string;
  flat_number: string | null;
  society_name: string | null;
  kyc_status: string;
  avatar_url: string | null;
  created_at: Date;
  updated_at: Date;
  is_active: boolean;
}

export interface PaginatedResult<T> {
  items: T[];
  page: number;
  totalPages: number;
  totalItems: number;
  counts?: {
    all: number;
    tenants: number;
    owners: number;
    vendors: number;
    pending: number;
  };
}

export class UsersRepository {
  async findMany(
    query: ListUsersQuery,
  ): Promise<PaginatedResult<UserDetailsRecord>> {
    const { page, limit, search, role, kycStatus, sortBy, sortOrder } = query;
    const offset = (page - 1) * limit;

    const conditions: string[] = [];
    const params: any[] = [];
    let paramIndex = 1;

    // 1. Full-text search on name, email, phone, flat_number, society_name
    if (search && search.trim().length > 0) {
      const searchPattern = `%${search.trim()}%`;
      conditions.push(`(
        name ILIKE $${paramIndex} OR 
        email ILIKE $${paramIndex} OR 
        phone ILIKE $${paramIndex} OR 
        flat_number ILIKE $${paramIndex} OR 
        society_name ILIKE $${paramIndex}
      )`);
      params.push(searchPattern);
      paramIndex++;
    }

    // 2. Role filter
    if (role && role !== "all") {
      conditions.push(`role = $${paramIndex}`);
      params.push(role);
      paramIndex++;
    }

    // 3. KYC status filter
    if (kycStatus && kycStatus !== "all") {
      conditions.push(`kyc_status = $${paramIndex}`);
      params.push(kycStatus);
      paramIndex++;
    }

    const whereClause =
      conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : "";

    // Whitelist sort fields to prevent SQL injection
    const allowedSortFields: Record<string, string> = {
      created_at: "created_at",
      name: "name",
      role: "role",
      kyc_status: "kyc_status",
      flat_number: "flat_number",
    };
    const sortField = allowedSortFields[sortBy] || "created_at";
    const orderDirection = sortOrder.toUpperCase() === "ASC" ? "ASC" : "DESC";

    // Count total query
    const countSql = `SELECT COUNT(*) as total FROM users ${whereClause};`;
    const countResult = await db.query<{ total: string }>(countSql, params);
    const totalItems = parseInt(countResult.rows[0]?.total || "0", 10);
    const totalPages = Math.ceil(totalItems / limit) || 1;

    // Fetch items query
    const itemsSql = `
      SELECT * FROM users
      ${whereClause}
      ORDER BY ${sortField} ${orderDirection}
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1};
    `;
    const itemParams = [...params, limit, offset];
    const itemsResult = await db.query<UserDetailsRecord>(itemsSql, itemParams);

    // Compute global counts for tabs
    const statsSql = `
      SELECT 
        COUNT(*) as total_all,
        COUNT(*) FILTER (WHERE role = 'tenant') as total_tenants,
        COUNT(*) FILTER (WHERE role = 'owner') as total_owners,
        COUNT(*) FILTER (WHERE role = 'vendor') as total_vendors,
        COUNT(*) FILTER (WHERE kyc_status = 'pending') as total_pending
      FROM users;
    `;
    const statsResult = await db.query<any>(statsSql);
    const statsRow = statsResult.rows[0] || {};

    return {
      items: itemsResult.rows,
      page,
      totalPages,
      totalItems,
      counts: {
        all: parseInt(statsRow.total_all || "0", 10),
        tenants: parseInt(statsRow.total_tenants || "0", 10),
        owners: parseInt(statsRow.total_owners || "0", 10),
        vendors: parseInt(statsRow.total_vendors || "0", 10),
        pending: parseInt(statsRow.total_pending || "0", 10),
      },
    };
  }

  async findById(id: number): Promise<UserDetailsRecord | null> {
    const query = `SELECT * FROM users WHERE id = $1 LIMIT 1;`;
    const result = await db.query<UserDetailsRecord>(query, [id]);
    return result.rows[0] || null;
  }

  async findByEmail(email: string): Promise<UserDetailsRecord | null> {
    const query = `SELECT * FROM users WHERE LOWER(email) = LOWER($1) LIMIT 1;`;
    const result = await db.query<UserDetailsRecord>(query, [email]);
    return result.rows[0] || null;
  }

  async findByPhone(phone: string): Promise<UserDetailsRecord | null> {
    const query = `SELECT * FROM users WHERE phone = $1 LIMIT 1;`;
    const result = await db.query<UserDetailsRecord>(query, [phone]);
    return result.rows[0] || null;
  }

  async create(data: {
    name: string;
    email: string;
    passwordHash: string;
    phone?: string | null;
    role?: string;
    flatNumber?: string | null;
    societyName?: string | null;
    kycStatus?: string;
    avatarUrl?: string | null;
  }): Promise<UserDetailsRecord> {
    const query = `
      INSERT INTO users (
        name, email, password_hash, phone, role, 
        flat_number, society_name, kyc_status, avatar_url
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *;
    `;
    const values = [
      data.name,
      data.email.toLowerCase(),
      data.passwordHash,
      data.phone || null,
      data.role || "user",
      data.flatNumber || null,
      data.societyName || null,
      data.kycStatus || "verified",
      data.avatarUrl || null,
    ];

    const result = await db.query<UserDetailsRecord>(query, values);
    return result.rows[0];
  }

  async update(
    id: number,
    data: {
      name?: string;
      phone?: string;
      role?: string;
      flatNumber?: string;
      societyName?: string;
      kycStatus?: string;
      avatarUrl?: string;
      isActive?: boolean;
    },
  ): Promise<UserDetailsRecord | null> {
    const updates: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    if (data.name !== undefined) {
      updates.push(`name = $${paramIndex++}`);
      values.push(data.name);
    }
    if (data.phone !== undefined) {
      updates.push(`phone = $${paramIndex++}`);
      values.push(data.phone);
    }
    if (data.role !== undefined) {
      updates.push(`role = $${paramIndex++}`);
      values.push(data.role);
    }
    if (data.flatNumber !== undefined) {
      updates.push(`flat_number = $${paramIndex++}`);
      values.push(data.flatNumber);
    }
    if (data.societyName !== undefined) {
      updates.push(`society_name = $${paramIndex++}`);
      values.push(data.societyName);
    }
    if (data.kycStatus !== undefined) {
      updates.push(`kyc_status = $${paramIndex++}`);
      values.push(data.kycStatus);
    }
    if (data.avatarUrl !== undefined) {
      updates.push(`avatar_url = $${paramIndex++}`);
      values.push(data.avatarUrl);
    }
    if (data.isActive !== undefined) {
      updates.push(`is_active = $${paramIndex++}`);
      values.push(data.isActive);
    }

    if (updates.length === 0) {
      return this.findById(id);
    }

    updates.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(id);

    const query = `
      UPDATE users
      SET ${updates.join(", ")}
      WHERE id = $${paramIndex}
      RETURNING *;
    `;

    const result = await db.query<UserDetailsRecord>(query, values);
    return result.rows[0] || null;
  }

  async delete(id: number): Promise<boolean> {
    const query = `DELETE FROM users WHERE id = $1 RETURNING id;`;
    const result = await db.query(query, [id]);
    return (result.rowCount ?? 0) > 0;
  }
}

export const usersRepository = new UsersRepository();
