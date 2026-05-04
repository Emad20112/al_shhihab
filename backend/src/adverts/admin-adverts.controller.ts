import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  UseGuards,
} from "@nestjs/common";
import { ApiHeader, ApiTags } from "@nestjs/swagger";

import { ok } from "../common/api-response";
import { AdminKeyGuard } from "../common/admin-key.guard";
import { serializeAdvert } from "./adverts.serializer";
import { AdvertsService } from "./adverts.service";
import { CreateAdvertDto, UpdateAdvertDto } from "./dto/upsert-advert.dto";

@ApiTags("لوحة التحكم - الإعلانات")
@ApiHeader({ name: "X-Admin-Key", required: true })
@UseGuards(AdminKeyGuard)
@Controller("admin/adverts")
export class AdminAdvertsController {
  constructor(private readonly advertsService: AdvertsService) {}

  @Get()
  async index() {
    const adverts = await this.advertsService.findAll();
    return ok(adverts.map(serializeAdvert), "تم جلب الإعلانات للإدارة");
  }

  @Post()
  async create(@Body() dto: CreateAdvertDto) {
    const advert = await this.advertsService.create(dto);
    return ok(serializeAdvert(advert), "تم إنشاء الإعلان", 201);
  }

  @Patch(":id")
  async update(
    @Param("id", ParseIntPipe) id: number,
    @Body() dto: UpdateAdvertDto,
  ) {
    const advert = await this.advertsService.update(id, dto);
    return ok(serializeAdvert(advert), "تم تحديث الإعلان");
  }

  @Delete(":id")
  async remove(@Param("id", ParseIntPipe) id: number) {
    return ok(await this.advertsService.remove(id), "تم حذف الإعلان");
  }
}
