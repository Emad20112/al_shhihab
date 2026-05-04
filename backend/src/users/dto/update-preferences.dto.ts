import { ApiProperty } from "@nestjs/swagger";
import { IsObject } from "class-validator";

export class UpdatePreferencesDto {
  @ApiProperty({
    example: {
      language: "ar",
      notifications: true,
      orderType: "delivery",
    },
  })
  @IsObject()
  preferences: Record<string, unknown>;
}
