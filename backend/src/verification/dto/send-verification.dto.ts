import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsIn, IsOptional, IsString, Length } from "class-validator";

export class SendVerificationDto {
  @ApiProperty({ example: "777000000" })
  @IsString()
  @Length(6, 40)
  phone: string;

  @ApiProperty({ enum: ["sms", "whatsapp"], example: "sms" })
  @IsIn(["sms", "whatsapp"])
  channel: "sms" | "whatsapp";

  @ApiPropertyOptional({ enum: ["sms", "whatsapp"], example: "sms" })
  @IsOptional()
  @IsString()
  type?: string;

  @ApiPropertyOptional({ enum: ["sms", "whatsapp"], example: "sms" })
  @IsOptional()
  @IsString()
  via?: string;
}
