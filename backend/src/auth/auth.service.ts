import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { InjectRepository } from "@nestjs/typeorm";
import * as bcrypt from "bcryptjs";
import { randomUUID } from "crypto";
import { Repository } from "typeorm";

import { UsersService } from "../users/users.service";
import { serializeUser } from "../users/users.serializer";
import { LoginDto } from "./dto/login.dto";
import { ResetPasswordDto } from "./dto/reset-password.dto";
import { RegisterDto } from "./dto/register.dto";
import { RevokedToken } from "./entities/revoked-token.entity";
import { UserSession } from "./entities/user-session.entity";

interface JwtContext {
  userAgent?: string;
  ipAddress?: string;
}

interface RefreshPayload {
  sub: number;
  sid: string;
  jti: string;
  typ: "refresh";
}

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
    @InjectRepository(RevokedToken)
    private readonly revokedTokens: Repository<RevokedToken>,
    @InjectRepository(UserSession)
    private readonly sessions: Repository<UserSession>,
  ) {}

  async register(dto: RegisterDto) {
    if (dto.password_confirmation &&
        dto.password_confirmation !== dto.password) {
      throw new BadRequestException("كلمتا المرور غير متطابقتين");
    }

    const passwordHash = await bcrypt.hash(dto.password, 12);
    const user = await this.usersService.create({
      name: dto.name,
      email: dto.email ?? null,
      phone: dto.phone,
      passwordHash,
    });

    return {
      registered: true,
      requires_verification: true,
      user: serializeUser(user),
    };
  }

  async login(dto: LoginDto, context: JwtContext = {}) {
    const identifier = dto.phone;

    const user = await this.usersService.findByIdentifier(identifier);
    if (!user) {
      throw new UnauthorizedException("بيانات الدخول غير صحيحة");
    }
    if (!user.isActive) {
      throw new UnauthorizedException("الحساب غير نشط");
    }
    if (!user.isVerified) {
      throw new UnauthorizedException("الحساب غير موثق");
    }

    const valid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!valid) {
      throw new UnauthorizedException("بيانات الدخول غير صحيحة");
    }

    return this.issueSession(user, context);
  }

  async resetPassword(userId: number, dto: ResetPasswordDto) {
    if (dto.password_confirmation !== dto.password) {
      throw new BadRequestException("كلمتا المرور غير متطابقتين");
    }

    const passwordHash = await bcrypt.hash(dto.password, 12);
    await this.usersService.updatePasswordHash(userId, passwordHash);
  }

  async logout(jti: string, exp?: number, sessionId?: string) {
    const expiresAt = exp
      ? new Date(exp * 1000)
      : new Date(Date.now() + 15 * 60 * 1000);

    await this.revokedTokens.upsert({ jti, expiresAt }, ["jti"]);

    if (sessionId) {
      await this.sessions.update(
        { id: sessionId },
        { revokedAt: new Date() },
      );
    }
  }

  async issueSession(user: {
    id: number;
    email: string | null;
    phone: string | null;
  }, context: JwtContext = {}) {
    const refreshExpiresAt = new Date(
      Date.now() + this.refreshTtlSeconds() * 1000,
    );
    const session = await this.sessions.save(
      this.sessions.create({
        userId: user.id,
        refreshTokenHash: "pending",
        expiresAt: refreshExpiresAt,
        revokedAt: null,
        lastUsedAt: null,
        userAgent: context.userAgent ?? null,
        ipAddress: context.ipAddress ?? null,
      }),
    );

    const refreshToken = await this.signRefreshToken(user.id, session.id);
    session.refreshTokenHash = await bcrypt.hash(refreshToken, 12);
    await this.sessions.save(session);

    const accessToken = await this.signAccessToken(user, session.id);
    const fullUser = await this.usersService.requireById(user.id);

    return {
      token: accessToken,
      access_token: accessToken,
      accessToken,
      refresh_token: refreshToken,
      refreshToken,
      token_type: "Bearer",
      expires_in: this.accessTtlSeconds(),
      refresh_expires_at: refreshExpiresAt,
      user: serializeUser(fullUser),
    };
  }

  async refresh(refreshToken: string, context: JwtContext = {}) {
    let payload: RefreshPayload;
    try {
      payload = await this.jwtService.verifyAsync<RefreshPayload>(
        refreshToken,
        { secret: this.refreshSecret() },
      );
    } catch {
      throw new UnauthorizedException("جلسة الدخول منتهية");
    }

    if (payload.typ !== "refresh") {
      throw new UnauthorizedException("نوع التوكن غير صالح");
    }

    const session = await this.sessions.findOne({
      where: { id: payload.sid, userId: payload.sub },
    });
    if (!session || session.revokedAt || session.expiresAt.getTime() <= Date.now()) {
      throw new UnauthorizedException("جلسة الدخول منتهية");
    }

    const valid = await bcrypt.compare(refreshToken, session.refreshTokenHash);
    if (!valid) {
      await this.sessions.update({ id: session.id }, { revokedAt: new Date() });
      throw new UnauthorizedException("تم إبطال الجلسة");
    }

    const user = await this.usersService.requireById(payload.sub);
    if (!user.isActive) {
      await this.sessions.update({ id: session.id }, { revokedAt: new Date() });
      throw new UnauthorizedException("الحساب غير نشط");
    }

    const nextRefreshToken = await this.signRefreshToken(user.id, session.id);
    session.refreshTokenHash = await bcrypt.hash(nextRefreshToken, 12);
    session.lastUsedAt = new Date();
    session.userAgent = context.userAgent ?? session.userAgent;
    session.ipAddress = context.ipAddress ?? session.ipAddress;
    await this.sessions.save(session);

    const accessToken = await this.signAccessToken(user, session.id);

    return {
      token: accessToken,
      access_token: accessToken,
      accessToken,
      refresh_token: nextRefreshToken,
      refreshToken: nextRefreshToken,
      token_type: "Bearer",
      expires_in: this.accessTtlSeconds(),
      refresh_expires_at: session.expiresAt,
      user: serializeUser(user),
    };
  }

  async isSessionActive(sessionId?: string) {
    if (!sessionId) return false;
    const session = await this.sessions.findOne({ where: { id: sessionId } });
    return Boolean(
      session &&
        !session.revokedAt &&
        session.expiresAt.getTime() > Date.now(),
    );
  }

  private async signAccessToken(user: {
    id: number;
    email: string | null;
    phone: string | null;
  }, sessionId: string) {
    const jti = randomUUID();
    return this.jwtService.signAsync(
      {
        sub: user.id,
        email: user.email,
        phone: user.phone,
        sid: sessionId,
        jti,
        typ: "access",
      },
      {
        secret: this.config.getOrThrow<string>("JWT_SECRET"),
        expiresIn: this.config.get<string>(
          "JWT_ACCESS_EXPIRES_IN",
          "15m",
        ) as "15m",
      },
    );
  }

  private signRefreshToken(userId: number, sessionId: string) {
    return this.jwtService.signAsync(
      {
        sub: userId,
        sid: sessionId,
        jti: randomUUID(),
        typ: "refresh",
      },
      {
        secret: this.refreshSecret(),
        expiresIn: this.config.get<string>(
          "JWT_REFRESH_EXPIRES_IN",
          "30d",
        ) as "30d",
      },
    );
  }

  private accessTtlSeconds() {
    return Number(this.config.get<string>("JWT_ACCESS_TTL_SECONDS", "900"));
  }

  private refreshTtlSeconds() {
    return Number(
      this.config.get<string>("JWT_REFRESH_TTL_SECONDS", "2592000"),
    );
  }

  private refreshSecret() {
    return this.config.getOrThrow<string>("JWT_REFRESH_SECRET");
  }
}
