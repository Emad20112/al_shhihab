import { Body, Controller, Post, Req, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiBody, ApiHeader, ApiTags } from "@nestjs/swagger";
import { Throttle } from "@nestjs/throttler";
import { Request } from "express";

import { ok, unwrapData } from "../common/api-response";
import { AppCredentialsGuard } from "../common/app-credentials.guard";
import { validateData } from "../common/validate-data";
import { CurrentUser, AuthenticatedUser } from "./current-user.decorator";
import { LoginDto } from "./dto/login.dto";
import { ResetPasswordDto } from "./dto/reset-password.dto";
import { RegisterDto } from "./dto/register.dto";
import { RefreshTokenDto } from "./dto/refresh-token.dto";
import { AuthService } from "./auth.service";
import { JwtAuthGuard } from "./jwt-auth.guard";

@ApiTags("auth")
@ApiHeader({ name: "X-Channel-Id", required: true, example: "android" })
@ApiHeader({ name: "X-API-APP-KEY", required: true })
@ApiHeader({ name: "X-API-APP-SECRET", required: true })
@UseGuards(AppCredentialsGuard)
@Controller("auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post("register")
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @ApiBody({
    schema: {
      example: {
        data: {
          name: "Emad",
          phone: "777000000",
          password: "secret123",
          password_confirmation: "secret123",
        },
      },
    },
  })
  async register(@Body() body: unknown) {
    const dto = await validateData(RegisterDto, unwrapData(body));
    const result = await this.authService.register(dto);
    return ok(result, "تم إنشاء الحساب بنجاح، يرجى تفعيل الحساب", 201);
  }

  @Post("login")
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @ApiBody({
    schema: {
      example: { data: { phone: "777000000", password: "secret123" } },
    },
  })
  async login(@Body() body: unknown, @Req() request: Request) {
    const dto = await validateData(LoginDto, unwrapData(body));
    const session = await this.authService.login(dto, this.requestContext(request));
    return ok(session, "تم تسجيل الدخول بنجاح");
  }

  @Post("refresh")
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @ApiBody({
    schema: {
      example: { data: { refresh_token: "refresh.jwt.token" } },
    },
  })
  async refresh(@Body() body: unknown, @Req() request: Request) {
    const dto = await validateData(RefreshTokenDto, unwrapData(body));
    const session = await this.authService.refresh(
      dto.refresh_token,
      this.requestContext(request),
    );
    return ok(session, "تم تجديد الجلسة بنجاح");
  }

  @Post("logout")
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @ApiBearerAuth()
  @UseGuards(AppCredentialsGuard, JwtAuthGuard)
  async logout(@CurrentUser() user: AuthenticatedUser) {
    await this.authService.logout(user.jti, user.exp, user.sessionId);
    return ok({}, "تم تسجيل الخروج بنجاح");
  }

  @Post("password/reset")
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @ApiBearerAuth()
  @UseGuards(AppCredentialsGuard, JwtAuthGuard)
  @ApiBody({
    schema: {
      example: {
        data: {
          password: "StrongPass123",
          password_confirmation: "StrongPass123",
        },
      },
    },
  })
  async resetPassword(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: unknown,
  ) {
    const dto = await validateData(ResetPasswordDto, unwrapData(body));
    await this.authService.resetPassword(user.id, dto);
    return ok({}, "تم تغيير كلمة المرور بنجاح");
  }

  private requestContext(request: Request) {
    return {
      userAgent: request.get("user-agent"),
      ipAddress: request.ip,
    };
  }
}
