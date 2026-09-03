import { Response } from 'express';
import { ErrorCode } from '../errors/error-codes.js';

export interface SuccessResponse<T> {
  success: true;
  data: T;
}

export interface ErrorResponse {
  success: false;
  message: string;
  code: ErrorCode | string;
  errors?: any[];
}

export const sendSuccess = <T>(res: Response, data: T, statusCode: number = 200): Response => {
  const payload: SuccessResponse<T> = {
    success: true,
    data,
  };
  return res.status(statusCode).json(payload);
};

export const sendError = (
  res: Response,
  message: string,
  code: ErrorCode | string,
  statusCode: number = 400,
  errors?: any[]
): Response => {
  const payload: ErrorResponse = {
    success: false,
    message,
    code,
    ...(errors && errors.length > 0 ? { errors } : {}),
  };
  return res.status(statusCode).json(payload);
};
