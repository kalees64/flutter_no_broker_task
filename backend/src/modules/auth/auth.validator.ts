import { z } from 'zod';

export const registerSchema = z.object({
  name: z.string().trim().min(2, 'Name must be at least 2 characters').max(100),
  email: z.string().trim().email('Invalid email address').max(150),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .max(128, 'Password is too long'),
  phone: z
    .string()
    .trim()
    .regex(/^[0-9+ -]{7,20}$/, 'Invalid phone number format')
    .optional()
    .nullable()
    .or(z.literal('')),
  role: z.enum(['user', 'tenant', 'owner', 'vendor', 'admin']).optional().default('user'),
  avatar_url: z.string().url('Invalid avatar URL').optional(),
  flatNumber: z.string().trim().max(50).optional(),
  societyName: z.string().trim().max(150).optional(),
});

export const loginSchema = z.object({
  identifier: z.string().trim().min(1, 'Email or mobile number is required'),
  password: z.string().min(1, 'Password is required'),
});

export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});

export const logoutSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});

export type RegisterDto = z.infer<typeof registerSchema>;
export type LoginDto = z.infer<typeof loginSchema>;
export type RefreshTokenDto = z.infer<typeof refreshTokenSchema>;
export type LogoutDto = z.infer<typeof logoutSchema>;
