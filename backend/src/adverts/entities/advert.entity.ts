import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";

export type AdvertPlacement = "home_hero" | "home_strip" | "category";

@Entity("adverts")
export class Advert {
  @PrimaryGeneratedColumn()
  id: number;

  @Index({ unique: true })
  @Column({ length: 80 })
  slug: string;

  @Column({ length: 160 })
  title: string;

  @Column({ name: "title_ar", length: 160 })
  titleAr: string;

  @Column({ length: 500 })
  subtitle: string;

  @Column({ name: "subtitle_ar", length: 500 })
  subtitleAr: string;

  @Column({ name: "image_url", length: 700 })
  imageUrl: string;

  @Column({ name: "cta_label", length: 80 })
  ctaLabel: string;

  @Column({ name: "cta_label_ar", length: 80 })
  ctaLabelAr: string;

  @Column({ length: 40 })
  placement: AdvertPlacement;

  @Column({ name: "campaign_type", length: 60 })
  campaignType: string;

  @Column({ name: "discount_percent", type: "int", nullable: true })
  discountPercent: number | null;

  @Column({ name: "product_id", type: "varchar", length: 80, nullable: true })
  productId: string | null;

  @Column({ name: "category_id", type: "varchar", length: 80, nullable: true })
  categoryId: string | null;

  @Column({ default: true })
  active: boolean;

  @Column({ default: 100 })
  priority: number;

  @Column({ name: "starts_at", type: "datetime" })
  startsAt: Date;

  @Column({ name: "ends_at", type: "datetime" })
  endsAt: Date;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt: Date;
}
