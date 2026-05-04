import { Body, Controller, Post, UseGuards } from "@nestjs/common";
import { ApiBody, ApiHeader, ApiTags } from "@nestjs/swagger";
import { Throttle } from "@nestjs/throttler";

import { ok, unwrapData } from "../common/api-response";
import { AppCredentialsGuard } from "../common/app-credentials.guard";
import { validateData } from "../common/validate-data";
import { CheckVerificationDto } from "./dto/check-verification.dto";
import { SendVerificationDto } from "./dto/send-verification.dto";
import { VerificationService } from "./verification.service";

@ApiTags("auth")
@ApiHeader({ name: "X-Channel-Id", required: true, example: "android" })
@ApiHeader({ name: "X-API-APP-KEY", required: true })
@ApiHeader({ name: "X-API-APP-SECRET", required: true })
@UseGuards(AppCredentialsGuard)
@Controller("auth/verify")
export class VerificationController {
  constructor(private readonly verificationService: VerificationService) {}

  @Post("send")
  @Throttle({ default: { limit: 3, ttl: 60_000 } })
  @ApiBody({
    schema: {
      example: { data: { phone: "777000000", channel: "sms" } },
    },
  })
  async send(@Body() body: unknown) {
    const dto = await validateData(SendVerificationDto, unwrapData(body));
    const result = await this.verificationService.send(dto);
    return ok(result, "تم إرسال رمز التحقق");
  }

  @Post("check")
  @Throttle({ default: { limit: 8, ttl: 60_000 } })
  @ApiBody({
    schema: {
      example: {
        data: { phone: "777000000", channel: "sms", code: "123456" },
      },
    },
  })
  async check(@Body() body: unknown) {
    const dto = await validateData(CheckVerificationDto, unwrapData(body));
    const result = await this.verificationService.check(dto);
    return ok(result, "تم التحقق بنجاح");
  }
}
