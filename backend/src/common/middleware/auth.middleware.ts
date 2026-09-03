import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '../../config/env.js';
import { AppError } from '../errors/app-error.js';
import { ErrorCodes } from '../errors/error-codes.js';

export interface AuthUserPayload {
  userId: number;
  email: string;
  role: string;
}

// Extend Express Request interface to carry authenticated user
declare global {
  namespace Express {
    interface Request {
      user?: AuthUserPayload;
    }
  }
}

export const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader) {
    return next(new AppError('Authorization header is missing', 401, ErrorCodes.UNAUTHORIZED));
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return next(new AppError('Format is Authorization: Bearer <token>', 401, ErrorCodes.INVALID_TOKEN));
  }

  const token = parts[1];

  try {
    const decoded = jwt.verify(token, env.JWT_ACCESS_SECRET) as AuthUserPayload;
    req.user = decoded;
    next();
  } catch (error: any) {
    if (error.name === 'TokenExpiredError') {
      return next(new AppError('Access token has expired', 401, ErrorCodes.TOKEN_EXPIRED));
    }
    return next(new AppError('Invalid access token', 401, ErrorCodes.INVALID_TOKEN));
  }
};
