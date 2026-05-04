import { PartialType } from "@nestjs/mapped-types";
import {
  IsBoolean,
  IsDateString,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUrl,
  Length,
  Max,
  MaxLength,
  Min,
} from "class-validator";

import { AdvertPlacement } from "../entities/advert.entity";

const placements: AdvertPlacement[] = ["home_hero", "home_strip", "category"];

export class CreateAdvertDto {
  @IsString()
  @Length(3, 80)
  slug: string;

  @IsString()
  @Length(2, 160)
  title: string;

  @IsString()
  @Length(2, 160)
  title_ar: string;

  @IsString()
  @Length(2, 500)
  subtitle: string;

  @IsString()
  @Length(2, 500)
  subtitle_ar: string;

  @IsUrl({ require_tld: false })
  @MaxLength(700)
  image_url: string;

  @IsString()
  @Length(2, 80)
  cta_label: string;

  @IsString()
  @Length(2, 80)
  cta_label_ar: string;

  @IsIn(placements)
  placement: AdvertPlacement;

  @IsString()
  @Length(2, 60)
  campaign_type: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  discount_percent?: number | null;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  product_id?: string | null;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  category_id?: string | null;

  @IsBoolean()
  active: boolean;

  @IsInt()
  @Min(1)
  @Max(9999)
  priority: number;

  @IsDateString()
  starts_at: string;

  @IsDateString()
  ends_at: string;
}

export class UpdateAdvertDto extends PartialType(CreateAdvertDto) {}
