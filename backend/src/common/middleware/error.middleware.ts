import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { AppError } from '../errors/app-error.js';
import { ErrorCodes } from '../errors/error-codes.js';
import { sendError } from '../utils/response.js';
import { env } from '../../config/env.js';

export const errorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // If headers already sent, delegate to default Express handler
  if (res.headersSent) {
    return next(err);
  }

  // 1. Handled Operational App Errors
  if (err instanceof AppError) {
    return sendError(res, err.message, err.code, err.statusCode);
  }

  // 2. Zod Validation Errors
  if (err instanceof ZodError) {
    const formattedErrors = err.issues.map((issue) => ({
      field: issue.path.join('.'),
      message: issue.message,
    }));
    return sendError(
      res,
      err.issues[0]?.message || 'Validation failed',
      ErrorCodes.VALIDATION_ERROR,
      400,
      formattedErrors
    );
  }

  // 3. JSON Syntax Error in request body
  if (err instanceof SyntaxError && 'body' in err) {
    return sendError(res, 'Malformed JSON payload', ErrorCodes.VALIDATION_ERROR, 400);
  }

  // 4. PostgreSQL Specific Errors
  if (err.code === '23505') {
    // Unique violation
    let message = 'A unique constraint was violated';
    let code: string = ErrorCodes.VALIDATION_ERROR;

    if (err.detail?.includes('email')) {
      message = 'Email already registered';
      code = ErrorCodes.EMAIL_EXISTS;
    } else if (err.detail?.includes('phone')) {
      message = 'Phone number already registered';
      code = ErrorCodes.PHONE_EXISTS;
    }

    return sendError(res, message, code, 409);
  }

  // 5. JWT Errors
  if (err.name === 'TokenExpiredError') {
    return sendError(res, 'Token has expired', ErrorCodes.TOKEN_EXPIRED, 401);
  }
  if (err.name === 'JsonWebTokenError') {
    return sendError(res, 'Invalid authentication token', ErrorCodes.INVALID_TOKEN, 401);
  }

  // 6. Unknown / Unhandled System Errors
  console.error('Unhandled Server Error:', err);

  const message =
    env.NODE_ENV === 'production'
      ? 'An unexpected error occurred'
      : err.message || 'Internal server error';

  return sendError(res, message, ErrorCodes.INTERNAL_SERVER_ERROR, 500);
};
