import { ApiProperty } from "@nestjs/swagger";
import { IsString, Length } from "class-validator";

export class LoginDto {
  @ApiProperty({ example: "777000000" })
  @IsString()
  @Length(6, 40)
  phone: string;

  @ApiProperty({ example: "secret123" })
  @IsString()
  @Length(6, 100)
  password: string;
}
