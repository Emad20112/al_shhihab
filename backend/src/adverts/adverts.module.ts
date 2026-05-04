import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";

import { AdminKeyGuard } from "../common/admin-key.guard";
import { AppCredentialsGuard } from "../common/app-credentials.guard";
import { AdminAdvertsController } from "./admin-adverts.controller";
import { AdvertsController } from "./adverts.controller";
import { AdvertsService } from "./adverts.service";
import { Advert } from "./entities/advert.entity";

@Module({
  imports: [TypeOrmModule.forFeature([Advert])],
  controllers: [AdvertsController, AdminAdvertsController],
  providers: [AdvertsService, AppCredentialsGuard, AdminKeyGuard],
})
export class AdvertsModule {}
