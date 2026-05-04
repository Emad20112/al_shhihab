import {
  Body,
  Controller,
  Delete,
  FileTypeValidator,
  Get,
  MaxFileSizeValidator,
  ParseFilePipe,
  Post,
  Put,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import {
  ApiBearerAuth,
  ApiBody,
  ApiConsumes,
  ApiHeader,
  ApiTags,
} from "@nestjs/swagger";
import { randomUUID } from "node:crypto";

import { AuthenticatedUser, CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { ok, unwrapData } from "../common/api-response";
import { AppCredentialsGuard } from "../common/app-credentials.guard";
import { validateData } from "../common/validate-data";
import { UpdateMeDto } from "./dto/update-me.dto";
import { UpdatePreferencesDto } from "./dto/update-preferences.dto";
import { serializeUser } from "./users.serializer";
import { UsersService } from "./users.service";

interface UploadedAvatar {
  originalname: string;
  mimetype: string;
  size: number;
}

@ApiBearerAuth()
@ApiTags("me")
@ApiHeader({ name: "X-Channel-Id", required: true, example: "android" })
@ApiHeader({ name: "X-API-APP-KEY", required: true })
@ApiHeader({ name: "X-API-APP-SECRET", required: true })
@UseGuards(AppCredentialsGuard, JwtAuthGuard)
@Controller()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get("me")
  async me(@CurrentUser() authUser: AuthenticatedUser) {
    const user = await this.usersService.requireById(authUser.id);
    return ok(serializeUser(user), "تم جلب بيانات المستخدم");
  }

  @Put("me")
  @ApiBody({
    schema: {
      example: { data: { name: "Emad Ali", phone: "777000000" } },
    },
  })
  async updateMe(
    @CurrentUser() authUser: AuthenticatedUser,
    @Body() body: unknown,
  ) {
    const dto = await validateData(UpdateMeDto, unwrapData(body));
    const user = await this.usersService.updateMe(authUser.id, dto);
    return ok(serializeUser(user), "تم تحديث بيانات المستخدم");
  }

  @Get("user/profile")
  async profile(@CurrentUser() authUser: AuthenticatedUser) {
    const user = await this.usersService.requireById(authUser.id);
    return ok(serializeUser(user), "تم جلب بروفايل المستخدم");
  }

  @Get("me/preferences")
  async preferences(@CurrentUser() authUser: AuthenticatedUser) {
    const user = await this.usersService.requireById(authUser.id);
    return ok(user.preferences ?? {}, "تم جلب تفضيلات المستخدم");
  }

  @Put("me/preferences")
  @ApiBody({
    schema: {
      example: {
        data: { preferences: { language: "ar", notifications: true } },
      },
    },
  })
  async updatePreferences(
    @CurrentUser() authUser: AuthenticatedUser,
    @Body() body: unknown,
  ) {
    const data = unwrapData<UpdatePreferencesDto | Record<string, unknown>>(
      body,
    );
    const preferences =
      "preferences" in data
        ? (data.preferences as Record<string, unknown>)
        : (data as Record<string, unknown>);
    const user = await this.usersService.updatePreferences(
      authUser.id,
      preferences,
    );
    return ok(user.preferences ?? {}, "تم تحديث تفضيلات المستخدم");
  }

  @Post("me/avatar")
  @ApiConsumes("multipart/form-data")
  @ApiBody({
    schema: {
      type: "object",
      properties: {
        avatar: {
          type: "string",
          format: "binary",
        },
      },
    },
  })
  @UseInterceptors(
    FileInterceptor("avatar", {
      limits: { fileSize: 2 * 1024 * 1024 },
    }),
  )
  async changeAvatar(
    @CurrentUser() authUser: AuthenticatedUser,
    @UploadedFile(
      new ParseFilePipe({
        fileIsRequired: false,
        validators: [
          new MaxFileSizeValidator({ maxSize: 2 * 1024 * 1024 }),
          new FileTypeValidator({ fileType: /^image\/(jpeg|png|webp)$/ }),
        ],
      }),
    )
    file?: UploadedAvatar,
  ) {
    const avatarUrl = file
      ? `/uploads/avatars/${authUser.id}-${randomUUID()}${avatarExtension(file)}`
      : `/uploads/avatars/${authUser.id}-local-avatar.png`;
    const user = await this.usersService.updateAvatar(authUser.id, avatarUrl);
    return ok(serializeUser(user), "تم تحديث صورة المستخدم");
  }

  @Delete("me/avatar")
  async deleteAvatar(@CurrentUser() authUser: AuthenticatedUser) {
    const user = await this.usersService.updateAvatar(authUser.id, null);
    return ok(serializeUser(user), "تم حذف صورة المستخدم");
  }
}

function avatarExtension(file: UploadedAvatar) {
  switch (file.mimetype) {
    case "image/jpeg":
      return ".jpg";
    case "image/png":
      return ".png";
    case "image/webp":
      return ".webp";
    default:
      return "";
  }
}
