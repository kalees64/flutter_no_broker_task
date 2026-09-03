import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { env } from '../../config/env.js';
import { AppError } from '../../common/errors/app-error.js';
import { ErrorCodes } from '../../common/errors/error-codes.js';
import { AuthRepository, authRepository, UserRecord } from './auth.repository.js';
import { RegisterDto, LoginDto } from './auth.validator.js';

export class AuthService {
  constructor(private repo: AuthRepository = authRepository) {}

  private sanitizeUser(user: UserRecord) {
    const { password_hash, ...safeUser } = user;
    return safeUser;
  }

  private generateTokens(user: { id: number; email: string; role: string }) {
    const accessPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = jwt.sign(accessPayload, env.JWT_ACCESS_SECRET, {
      expiresIn: env.JWT_ACCESS_EXPIRES_IN as any,
    });

    const refreshPayload = {
      userId: user.id,
    };

    const refreshToken = jwt.sign(refreshPayload, env.JWT_REFRESH_SECRET, {
      expiresIn: env.JWT_REFRESH_EXPIRES_IN as any,
    });

    return { accessToken, refreshToken };
  }

  async register(dto: RegisterDto) {
    // 1. Check duplicate email
    const existingEmail = await this.repo.findUserByEmail(dto.email);
    if (existingEmail) {
      throw new AppError('Email already registered', 409, ErrorCodes.EMAIL_EXISTS);
    }

    // 2. Check duplicate phone if provided
    if (dto.phone) {
      const existingPhone = await this.repo.findUserByPhone(dto.phone);
      if (existingPhone) {
        throw new AppError('Phone number already registered', 409, ErrorCodes.PHONE_EXISTS);
      }
    }

    // 3. Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(dto.password, saltRounds);

    // 4. Create user
    const newUser = await this.repo.createUser({
      name: dto.name,
      email: dto.email,
      phone: dto.phone,
      passwordHash,
      role: dto.role,
      avatarUrl: dto.avatar_url,
      flatNumber: dto.flatNumber,
      societyName: dto.societyName,
    });

    return {
      user: this.sanitizeUser(newUser),
    };
  }

  async login(dto: LoginDto) {
    // 1. Find user by email or phone
    const user = await this.repo.findUserByIdentifier(dto.identifier);
    if (!user) {
      throw new AppError('Invalid email or password', 401, ErrorCodes.INVALID_CREDENTIALS);
    }

    // 2. Check active status
    if (!user.is_active) {
      throw new AppError('User account is deactivated', 403, ErrorCodes.USER_INACTIVE);
    }

    // 3. Verify password
    const isPasswordValid = await bcrypt.compare(dto.password, user.password_hash);
    if (!isPasswordValid) {
      throw new AppError('Invalid email or password', 401, ErrorCodes.INVALID_CREDENTIALS);
    }

    // 4. Generate tokens
    const { accessToken, refreshToken } = this.generateTokens(user);

    // 5. Store refresh token in DB (7 days expiry)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    await this.repo.saveRefreshToken(user.id, refreshToken, expiresAt);

    return {
      accessToken,
      refreshToken,
      user: this.sanitizeUser(user),
    };
  }

  async refreshToken(token: string) {
    // 1. Verify token signature
    let decoded: any;
    try {
      decoded = jwt.verify(token, env.JWT_REFRESH_SECRET);
    } catch (err: any) {
      if (err.name === 'TokenExpiredError') {
        throw new AppError('Refresh token has expired. Please log in again.', 401, ErrorCodes.TOKEN_EXPIRED);
      }
      throw new AppError('Invalid refresh token', 401, ErrorCodes.INVALID_TOKEN);
    }

    // 2. Verify token existence in database
    const storedToken = await this.repo.findRefreshToken(token);
    if (!storedToken) {
      throw new AppError('Refresh token revoked or invalid', 401, ErrorCodes.INVALID_TOKEN);
    }

    if (new Date() > new Date(storedToken.expires_at)) {
      await this.repo.deleteRefreshToken(token);
      throw new AppError('Refresh token has expired', 401, ErrorCodes.TOKEN_EXPIRED);
    }

    // 3. Verify user still exists and is active
    const user = await this.repo.findUserById(decoded.userId);
    if (!user || !user.is_active) {
      throw new AppError('User not found or inactive', 401, ErrorCodes.UNAUTHORIZED);
    }

    // 4. Issue new access token
    const { accessToken, refreshToken: newRefreshToken } = this.generateTokens(user);

    // 5. Rotate refresh token: remove old one, save new one
    await this.repo.deleteRefreshToken(token);

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);
    await this.repo.saveRefreshToken(user.id, newRefreshToken, expiresAt);

    return {
      accessToken,
      refreshToken: newRefreshToken,
    };
  }

  async logout(token: string) {
    await this.repo.deleteRefreshToken(token);
    return {
      message: 'Successfully logged out',
    };
  }
}

export const authService = new AuthService();
