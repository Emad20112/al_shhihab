import { ApiProperty } from "@nestjs/swagger";
import { IsString, Length } from "class-validator";

export class ResetPasswordDto {
  @ApiProperty({ example: "StrongPass123" })
  @IsString()
  @Length(8, 100)
  password: string;

  @ApiProperty({ example: "StrongPass123" })
  @IsString()
  password_confirmation: string;
}
