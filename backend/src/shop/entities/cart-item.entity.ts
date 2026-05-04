import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";

import { User } from "../../users/entities/user.entity";
import { ShopProduct } from "./shop-product.entity";

@Entity("cart_items")
@Index(["userId", "productId"], { unique: true })
export class CartItem {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: "user_id" })
  userId: number;

  @ManyToOne(() => User, { onDelete: "CASCADE" })
  user: User;

  @Column({ name: "product_id" })
  productId: number;

  @ManyToOne(() => ShopProduct, { eager: true, onDelete: "CASCADE" })
  product: ShopProduct;

  @Column({ default: 1 })
  quantity: number;

  @Column({ type: "simple-json", nullable: true })
  options: Record<string, unknown> | null;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt: Date;
}
