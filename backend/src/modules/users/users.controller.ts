import { Request, Response, NextFunction } from 'express';
import { usersService } from './users.service.js';
import { sendSuccess } from '../../common/utils/response.js';

export class UsersController {
  async listUsers(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await usersService.listUsers(req.query as any);
      return sendSuccess(res, result, 200);
    } catch (error) {
      next(error);
    }
  }

  async getUserById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = Number(req.params.id);
      const result = await usersService.getUserById(id);
      return sendSuccess(res, result, 200);
    } catch (error) {
      next(error);
    }
  }

  async createUser(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await usersService.createUser(req.body);
      return sendSuccess(res, result, 201);
    } catch (error) {
      next(error);
    }
  }

  async updateUser(req: Request, res: Response, next: NextFunction) {
    try {
      const id = Number(req.params.id);
      const result = await usersService.updateUser(id, req.body);
      return sendSuccess(res, result, 200);
    } catch (error) {
      next(error);
    }
  }

  async deleteUser(req: Request, res: Response, next: NextFunction) {
    try {
      const id = Number(req.params.id);
      const result = await usersService.deleteUser(id);
      return sendSuccess(res, result, 200);
    } catch (error) {
      next(error);
    }
  }
}

export const usersController = new UsersController();
