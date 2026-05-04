import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";

@Entity("shop_categories")
export class ShopCategory {
  @PrimaryGeneratedColumn()
  id: number;

  @Index({ unique: true })
  @Column({ name: "public_id", length: 80 })
  publicId: string;

  @Column({ length: 120 })
  name: string;

  @Column({ name: "name_ar", length: 120 })
  nameAr: string;

  @Column({ length: 60 })
  icon: string;

  @Column({ length: 20 })
  color: string;

  @Column({ name: "image_url", length: 700 })
  imageUrl: string;

  @Column({ default: true })
  active: boolean;

  @Column({ default: 100 })
  priority: number;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt: Date;
}
