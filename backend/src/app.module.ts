import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { APP_GUARD } from "@nestjs/core";
import { ThrottlerGuard, ThrottlerModule } from "@nestjs/throttler";
import { TypeOrmModule } from "@nestjs/typeorm";

import { AdvertsModule } from "./adverts/adverts.module";
import { AuthModule } from "./auth/auth.module";
import { databaseConfig } from "./database/database.config";
import { ShopModule } from "./shop/shop.module";
import { UsersModule } from "./users/users.module";
import { VerificationModule } from "./verification/verification.module";
import { validateEnv } from "./config/env.validation";

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, validate: validateEnv }),
    ThrottlerModule.forRoot([
      {
        name: "default",
        ttl: 60_000,
        limit: 120,
      },
    ]),
    TypeOrmModule.forRootAsync({ useFactory: databaseConfig }),
    UsersModule,
    AuthModule,
    VerificationModule,
    AdvertsModule,
    ShopModule,
  ],
  providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class AppModule {}
