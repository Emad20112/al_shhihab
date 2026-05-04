// Authentication System Overview
// This module is responsible for managing user authentication and session lifecycle.
// It handles user login, registration, and logout processes, along with maintaining
// secure sessions between the client and server.
//
// The system uses token-based authentication, issuing short-lived access tokens
// and longer-lived refresh tokens to ensure both security and usability.
// It supports session validation, token renewal, and proper session invalidation
// when users log out or when sessions expire.
//
// Additionally, the authentication layer is designed to integrate with external
// identity providers if needed, while maintaining a consistent internal user model.
// All sensitive operations are protected, and the system ensures that only
// authenticated and authorized users can access protected resources.
//
// The implementation follows best practices for security, scalability, and
// maintainability, making it suitable for modern mobile and web applications.
import { Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { JwtModule } from "@nestjs/jwt";
import { PassportModule } from "@nestjs/passport";
import { TypeOrmModule } from "@nestjs/typeorm";

import { AppCredentialsGuard } from "../common/app-credentials.guard";
import { UsersModule } from "../users/users.module";
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";
import { RevokedToken } from "./entities/revoked-token.entity";
import { UserSession } from "./entities/user-session.entity";
import { JwtAuthGuard } from "./jwt-auth.guard";
import { JwtStrategy } from "./jwt.strategy";

@Module({
  imports: [
    ConfigModule,
    UsersModule,
    PassportModule,
    TypeOrmModule.forFeature([RevokedToken, UserSession]),
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        return {
          secret: config.getOrThrow<string>("JWT_SECRET"),
          signOptions: {
            expiresIn: config.get<string>(
              "JWT_ACCESS_EXPIRES_IN",
              "15m",
            ) as "15m",
          },
        };
      },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, JwtAuthGuard, AppCredentialsGuard],
  exports: [AuthService, JwtAuthGuard],
})
export class AuthModule {}
