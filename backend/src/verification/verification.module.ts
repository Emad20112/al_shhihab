import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";

import { AppCredentialsGuard } from "../common/app-credentials.guard";
import { AuthModule } from "../auth/auth.module";
import { UsersModule } from "../users/users.module";
import { VerificationCode } from "./entities/verification-code.entity";
import { VerificationController } from "./verification.controller";
import { VerificationService } from "./verification.service";

@Module({
  imports: [
    TypeOrmModule.forFeature([VerificationCode]),
    UsersModule,
    AuthModule,
  ],
  controllers: [VerificationController],
  providers: [VerificationService, AppCredentialsGuard],
})
export class VerificationModule {}
