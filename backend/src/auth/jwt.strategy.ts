import { Injectable, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { InjectRepository } from "@nestjs/typeorm";
import { ExtractJwt, Strategy } from "passport-jwt";
import { PassportStrategy } from "@nestjs/passport";
import { Repository } from "typeorm";

import { RevokedToken } from "./entities/revoked-token.entity";
import { AuthService } from "./auth.service";

interface JwtPayload {
  sub: number;
  email: string | null;
  phone: string | null;
  sid?: string;
  jti: string;
  typ?: "access" | "refresh";
  exp?: number;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    config: ConfigService,
    @InjectRepository(RevokedToken)
    private readonly revokedTokens: Repository<RevokedToken>,
    private readonly authService: AuthService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.getOrThrow<string>("JWT_SECRET"),
    });
  }

  async validate(payload: JwtPayload) {
    if (payload.typ && payload.typ !== "access") {
      throw new UnauthorizedException("نوع التوكن غير صالح");
    }

    const revoked = await this.revokedTokens.findOne({
      where: { jti: payload.jti },
    });
    if (revoked) {
      throw new UnauthorizedException("تم إنهاء هذه الجلسة");
    }

    const activeSession = await this.authService.isSessionActive(payload.sid);
    if (!activeSession) {
      throw new UnauthorizedException("جلسة الدخول منتهية");
    }

    return {
      id: payload.sub,
      email: payload.email,
      phone: payload.phone,
      jti: payload.jti,
      sessionId: payload.sid,
      exp: payload.exp,
    };
  }
}
