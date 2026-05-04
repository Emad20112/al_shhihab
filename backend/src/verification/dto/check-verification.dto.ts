import { ApiProperty } from "@nestjs/swagger";
import { IsIn, IsOptional, IsString, Length } from "class-validator";

export class CheckVerificationDto {
  @ApiProperty({ example: "777000000" })
  @IsString()
  @Length(6, 40)
  phone: string;

  @ApiProperty({ enum: ["sms", "whatsapp"], example: "sms" })
  @IsIn(["sms", "whatsapp"])
  channel: "sms" | "whatsapp";

  @ApiProperty({ example: "123456" })
  @IsString()
  @Length(4, 10)
  code: string;

  @ApiProperty({ example: "123456" })
  @IsOptional()
  @IsString()
  otp?: string;
}
