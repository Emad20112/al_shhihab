import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsEmail, IsOptional, IsString, Length } from "class-validator";

export class RegisterDto {
  @ApiProperty({ example: "Emad Ali" })
  @IsString()
  @Length(2, 120)
  name: string;

  @ApiProperty({ example: "777000000" })
  @IsString()
  @Length(6, 40)
  phone: string;

  @ApiPropertyOptional({ example: "emad@example.com" })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiProperty({ example: "secret123" })
  @IsString()
  @Length(6, 100)
  password: string;

  @ApiPropertyOptional({ example: "secret123" })
  @IsOptional()
  @IsString()
  password_confirmation?: string;
}
