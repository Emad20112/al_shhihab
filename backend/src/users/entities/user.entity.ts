import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";

@Entity("users")
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 120 })
  name: string;

  @Index({ unique: true })
  @Column({ type: "varchar", length: 160, nullable: true })
  email: string | null;

  @Index({ unique: true })
  @Column({ type: "varchar", length: 40, nullable: true })
  phone: string | null;

  @Column({ name: "password_hash", length: 255 })
  passwordHash: string;

  @Column({ name: "avatar_url", type: "varchar", length: 500, nullable: true })
  avatarUrl: string | null;

  @Column({ name: "is_active", default: true })
  isActive: boolean;

  @Column({ name: "is_verified", default: false })
  isVerified: boolean;

  @Column({ type: "simple-json", nullable: true })
  preferences: Record<string, unknown> | null;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt: Date;
}
