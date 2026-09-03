import bcrypt from 'bcrypt';
import { AppError } from '../../common/errors/app-error.js';
import { ErrorCodes } from '../../common/errors/error-codes.js';
import {
  UsersRepository,
  usersRepository,
  UserDetailsRecord,
} from './users.repository.js';
import {
  ListUsersQuery,
  CreateUserDto,
  UpdateUserDto,
} from './users.validator.js';

export class UsersService {
  constructor(private repo: UsersRepository = usersRepository) {}

  private sanitizeUser(user: UserDetailsRecord) {
    const { password_hash, ...safeUser } = user;
    return safeUser;
  }

  async listUsers(query: ListUsersQuery) {
    const result = await this.repo.findMany(query);
    return {
      items: result.items.map((u) => this.sanitizeUser(u)),
      page: result.page,
      totalPages: result.totalPages,
      totalItems: result.totalItems,
      counts: (result as any).counts,
    };
  }

  async getUserById(id: number) {
    const user = await this.repo.findById(id);
    if (!user) {
      throw new AppError('User not found', 404, ErrorCodes.USER_NOT_FOUND);
    }
    return this.sanitizeUser(user);
  }

  async createUser(dto: CreateUserDto) {
    const existingEmail = await this.repo.findByEmail(dto.email);
    if (existingEmail) {
      throw new AppError('Email already registered', 409, ErrorCodes.EMAIL_EXISTS);
    }

    if (dto.phone) {
      const existingPhone = await this.repo.findByPhone(dto.phone);
      if (existingPhone) {
        throw new AppError('Phone number already registered', 409, ErrorCodes.PHONE_EXISTS);
      }
    }

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(dto.password, saltRounds);

    const newUser = await this.repo.create({
      name: dto.name,
      email: dto.email,
      passwordHash,
      phone: dto.phone,
      role: dto.role,
      flatNumber: dto.flatNumber,
      societyName: dto.societyName,
      kycStatus: dto.kycStatus,
      avatarUrl: dto.avatarUrl,
    });

    return this.sanitizeUser(newUser);
  }

  async updateUser(id: number, dto: UpdateUserDto) {
    const user = await this.repo.findById(id);
    if (!user) {
      throw new AppError('User not found', 404, ErrorCodes.USER_NOT_FOUND);
    }

    if (dto.phone && dto.phone !== user.phone) {
      const existingPhone = await this.repo.findByPhone(dto.phone);
      if (existingPhone) {
        throw new AppError('Phone number already registered', 409, ErrorCodes.PHONE_EXISTS);
      }
    }

    const updatedUser = await this.repo.update(id, dto);
    if (!updatedUser) {
      throw new AppError('Failed to update user', 500, ErrorCodes.INTERNAL_SERVER_ERROR);
    }

    return this.sanitizeUser(updatedUser);
  }

  async deleteUser(id: number) {
    const user = await this.repo.findById(id);
    if (!user) {
      throw new AppError('User not found', 404, ErrorCodes.USER_NOT_FOUND);
    }

    await this.repo.delete(id);
    return {
      message: 'User deleted successfully',
      id,
    };
  }
}

export const usersService = new UsersService();
