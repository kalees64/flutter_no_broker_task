import { Router } from 'express';
import { usersController } from './users.controller.js';
import { authenticateToken } from '../../common/middleware/auth.middleware.js';
import { validate } from '../../common/middleware/validate.middleware.js';
import {
  listUsersQuerySchema,
  createUserSchema,
  updateUserSchema,
  userIdParamSchema,
} from './users.validator.js';

const router = Router();

// All user management routes are protected by JWT
router.use(authenticateToken);

router.get(
  '/',
  validate({ query: listUsersQuerySchema }),
  usersController.listUsers
);

router.get(
  '/:id',
  validate({ params: userIdParamSchema }),
  usersController.getUserById
);

router.post(
  '/',
  validate({ body: createUserSchema }),
  usersController.createUser
);

router.patch(
  '/:id',
  validate({ params: userIdParamSchema, body: updateUserSchema }),
  usersController.updateUser
);

router.delete(
  '/:id',
  validate({ params: userIdParamSchema }),
  usersController.deleteUser
);

export const usersRoutes = router;
