import express, { Express, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { env } from './config/env.js';
import { authRoutes } from './modules/auth/auth.routes.js';
import { usersRoutes } from './modules/users/users.routes.js';
import swaggerUi from 'swagger-ui-express';
import { swaggerDocument } from './docs/swagger.js';
import { errorHandler } from './common/middleware/error.middleware.js';
import { sendSuccess, sendError } from './common/utils/response.js';
import { ErrorCodes } from './common/errors/error-codes.js';

export const createApp = (): Express => {
  const app = express();

  // 1. Basic Security Hygiene
  app.use(helmet({ contentSecurityPolicy: false })); // Allow Swagger UI assets
  app.use(
    cors({
      origin: env.CORS_ORIGIN === '*' ? true : env.CORS_ORIGIN,
      credentials: true,
    })
  );

  // 2. Request Parsing
  app.use(express.json({ limit: '1mb' }));
  app.use(express.urlencoded({ extended: true, limit: '1mb' }));

  // 3. Rate Limiting
  const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 200, // Limit each IP to 200 requests per windowMs
    standardHeaders: true,
    legacyHeaders: false,
    message: {
      success: false,
      message: 'Too many requests from this IP, please try again later',
      code: 'TOO_MANY_REQUESTS',
    },
  });

  app.use('/api', apiLimiter);

  // 4. Interactive Swagger Documentation
  app.use('/api/v1/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

  // 5. Health Check
  app.get('/health', (req: Request, res: Response) => {
    return sendSuccess(res, { status: 'healthy', timestamp: new Date().toISOString() });
  });

  app.get('/api/v1/health', (req: Request, res: Response) => {
    return sendSuccess(res, { status: 'healthy', timestamp: new Date().toISOString() });
  });

  // 6. Mount API Modules
  app.use('/api/v1/auth', authRoutes);
  app.use('/api/v1/users', usersRoutes);

  // 6. 404 Route Not Found Handler
  app.use((req: Request, res: Response) => {
    return sendError(
      res,
      `Cannot ${req.method} ${req.originalUrl}`,
      ErrorCodes.ROUTE_NOT_FOUND,
      404
    );
  });

  // 7. Centralized Global Error Handler
  app.use(errorHandler);

  return app;
};
