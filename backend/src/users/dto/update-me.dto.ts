import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsEmail, IsOptional, IsString, Length } from "class-validator";

export class UpdateMeDto {
  @ApiPropertyOptional({ example: "Emad Ali" })
  @IsOptional()
  @IsString()
  @Length(2, 120)
  name?: string;

  @ApiPropertyOptional({ example: "emad@example.com" })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ example: "777000000" })
  @IsOptional()
  @IsString()
  @Length(6, 40)
  phone?: string;
}
