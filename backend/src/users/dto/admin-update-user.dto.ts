import {
  IsBoolean,
  IsEmail,
  IsOptional,
  IsString,
  Length,
} from "class-validator";

export class AdminUpdateUserDto {
  @IsOptional()
  @IsString()
  @Length(2, 120)
  name?: string;

  @IsOptional()
  @IsEmail()
  email?: string | null;

  @IsOptional()
  @IsString()
  @Length(6, 40)
  phone?: string | null;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean;

  @IsOptional()
  @IsBoolean()
  is_verified?: boolean;
}
