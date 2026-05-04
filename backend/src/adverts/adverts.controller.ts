import { Controller, Get, Param, ParseIntPipe } from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";

import { ok } from "../common/api-response";
import { serializeAdvert } from "./adverts.serializer";
import { AdvertsService } from "./adverts.service";

@ApiTags("الإعلانات")
@Controller("advert/madverts")
export class AdvertsController {
  constructor(private readonly advertsService: AdvertsService) {}

  @Get()
  async index() {
    const adverts = await this.advertsService.findActive();
    return ok(adverts.map(serializeAdvert), "تم جلب الإعلانات");
  }

  @Get(":id")
  async show(@Param("id", ParseIntPipe) id: number) {
    const advert = await this.advertsService.findOne(id);
    return ok(serializeAdvert(advert), "تم جلب الإعلان");
  }
}
