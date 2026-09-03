import { Router } from 'express';
import { authController } from './auth.controller.js';
import { validate } from '../../common/middleware/validate.middleware.js';
import { authenticateToken } from '../../common/middleware/auth.middleware.js';
import {
  registerSchema,
  loginSchema,
  refreshTokenSchema,
  logoutSchema,
} from './auth.validator.js';
import { sendSuccess } from '../../common/utils/response.js';

const router = Router();

// Public Routes
router.post(
  '/register',
  validate({ body: registerSchema }),
  authController.register
);

router.post(
  '/login',
  validate({ body: loginSchema }),
  authController.login
);

router.post(
  '/refresh',
  validate({ body: refreshTokenSchema }),
  authController.refresh
);

// Protected Routes
router.post(
  '/logout',
  authenticateToken,
  validate({ body: logoutSchema }),
  authController.logout
);

// Profile inspection (verification of active token)
router.get('/me', authenticateToken, (req, res) => {
  return sendSuccess(res, { user: req.user });
});

export const authRoutes = router;
