import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  UseGuards,
} from "@nestjs/common";
import { ApiHeader, ApiTags } from "@nestjs/swagger";

import { ok } from "../common/api-response";
import { AdminKeyGuard } from "../common/admin-key.guard";
import { AdminUpdateUserDto } from "./dto/admin-update-user.dto";
import { serializeUser } from "./users.serializer";
import { UsersService } from "./users.service";

@ApiTags("لوحة التحكم - المستخدمون")
@ApiHeader({ name: "X-Admin-Key", required: true })
@UseGuards(AdminKeyGuard)
@Controller("admin/users")
export class AdminUsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  async index() {
    const users = await this.usersService.findAllForAdmin();
    return ok(users.map(serializeUser), "تم جلب المستخدمين للإدارة");
  }

  @Patch(":id")
  async update(
    @Param("id", ParseIntPipe) id: number,
    @Body() dto: AdminUpdateUserDto,
  ) {
    const user = await this.usersService.updateForAdmin(id, dto);
    return ok(serializeUser(user), "تم تحديث المستخدم");
  }

  @Delete(":id")
  async remove(@Param("id", ParseIntPipe) id: number) {
    return ok(await this.usersService.removeForAdmin(id), "تم حذف المستخدم");
  }
}
