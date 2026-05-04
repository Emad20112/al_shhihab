import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";

import { AdminKeyGuard } from "../common/admin-key.guard";
import { AppCredentialsGuard } from "../common/app-credentials.guard";
import { AdminUsersController } from "./admin-users.controller";
import { User } from "./entities/user.entity";
import { UsersController } from "./users.controller";
import { UsersService } from "./users.service";

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController, AdminUsersController],
  providers: [UsersService, AppCredentialsGuard, AdminKeyGuard],
  exports: [UsersService],
})
export class UsersModule {}
