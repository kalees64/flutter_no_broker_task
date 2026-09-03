import { z } from 'zod';

export const listUsersQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  search: z.string().trim().optional(),
  role: z.enum(['all', 'tenant', 'owner', 'vendor', 'admin', 'user']).optional(),
  kycStatus: z.enum(['all', 'verified', 'pending', 'rejected']).optional(),
  sortBy: z.enum(['created_at', 'name', 'role', 'kyc_status', 'flat_number']).default('created_at'),
  sortOrder: z.enum(['asc', 'desc', 'ASC', 'DESC']).default('desc'),
});

export const createUserSchema = z.object({
  name: z.string().trim().min(2, 'Name must be at least 2 characters').max(100),
  email: z.string().trim().email('Invalid email address').max(150),
  password: z.string().min(8, 'Password must be at least 8 characters').max(128),
  phone: z
    .string()
    .trim()
    .regex(/^[0-9+ -]{7,20}$/, 'Invalid phone number format')
    .optional(),
  role: z.enum(['user', 'tenant', 'owner', 'vendor', 'admin']).default('user'),
  flatNumber: z.string().trim().max(50).optional(),
  societyName: z.string().trim().max(150).optional(),
  kycStatus: z.enum(['verified', 'pending', 'rejected']).default('verified'),
  avatarUrl: z.string().url('Invalid avatar URL').optional(),
});

export const updateUserSchema = z.object({
  name: z.string().trim().min(2).max(100).optional(),
  phone: z
    .string()
    .trim()
    .regex(/^[0-9+ -]{7,20}$/, 'Invalid phone number format')
    .optional(),
  role: z.enum(['user', 'tenant', 'owner', 'vendor', 'admin']).optional(),
  flatNumber: z.string().trim().max(50).optional(),
  societyName: z.string().trim().max(150).optional(),
  kycStatus: z.enum(['verified', 'pending', 'rejected']).optional(),
  avatarUrl: z.string().url().optional(),
  isActive: z.boolean().optional(),
});

export const userIdParamSchema = z.object({
  id: z.coerce.number().int().positive('User ID must be a positive integer'),
});

export type ListUsersQuery = z.infer<typeof listUsersQuerySchema>;
export type CreateUserDto = z.infer<typeof createUserSchema>;
export type UpdateUserDto = z.infer<typeof updateUserSchema>;
export type UserIdParam = z.infer<typeof userIdParamSchema>;
