import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";

@Entity("shop_products")
export class ShopProduct {
  @PrimaryGeneratedColumn()
  id: number;

  @Index({ unique: true })
  @Column({ name: "public_id", length: 80 })
  publicId: string;

  @Column({ length: 180 })
  name: string;

  @Column({ name: "name_ar", length: 180 })
  nameAr: string;

  @Column({ type: "decimal", precision: 10, scale: 2 })
  price: string;

  @Column({
    name: "original_price",
    type: "decimal",
    precision: 10,
    scale: 2,
    nullable: true,
  })
  originalPrice: string | null;

  @Column({ length: 1000 })
  description: string;

  @Column({ name: "description_ar", length: 1000 })
  descriptionAr: string;

  @Column({ type: "decimal", precision: 3, scale: 2, default: 0 })
  rating: string;

  @Column({ name: "review_count", default: 0 })
  reviewCount: number;

  @Column({ name: "image_url", length: 700 })
  imageUrl: string;

  @Index()
  @Column({ name: "category_id", length: 80 })
  categoryId: string;

  @Column({ length: 40, default: "Piece" })
  unit: string;

  @Column({ name: "unit_ar", length: 40, default: "قطعة" })
  unitAr: string;

  @Column({ name: "is_featured", default: false })
  isFeatured: boolean;

  @Column({ name: "is_new", default: false })
  isNew: boolean;

  @Column({ name: "stock_count", default: 10 })
  stockCount: number;

  @Column({ type: "simple-json", nullable: true })
  specs: Record<string, string> | null;

  @Column({ type: "simple-json", nullable: true })
  colors: string[] | null;

  @Column({ default: true })
  active: boolean;

  @Column({ default: 100 })
  priority: number;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt: Date;
}
