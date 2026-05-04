import { IsInt, IsOptional, IsString, Max, Min } from "class-validator";

export class AddCartItemDto {
  @IsOptional()
  @IsString()
  product_id?: string;

  @IsOptional()
  @IsString()
  productId?: string;

  @IsOptional()
  @IsString()
  id?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(99)
  quantity?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(99)
  qty?: number;

  @IsOptional()
  options?: Record<string, unknown>;
}

export class UpdateCartQuantityDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(99)
  quantity?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(99)
  qty?: number;
}
