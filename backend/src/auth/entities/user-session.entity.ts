import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";

import { User } from "../../users/entities/user.entity";

@Entity("user_sessions")
export class UserSession {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Index()
  @Column({ name: "user_id" })
  userId: number;

  @ManyToOne(() => User, { onDelete: "CASCADE" })
  @JoinColumn({ name: "user_id" })
  user: User;

  @Column({ name: "refresh_token_hash", length: 255 })
  refreshTokenHash: string;

  @Column({ name: "expires_at", type: "datetime" })
  expiresAt: Date;

  @Column({ name: "revoked_at", type: "datetime", nullable: true })
  revokedAt: Date | null;

  @Column({ name: "last_used_at", type: "datetime", nullable: true })
  lastUsedAt: Date | null;

  @Column({ name: "user_agent", type: "varchar", length: 500, nullable: true })
  userAgent: string | null;

  @Column({ name: "ip_address", type: "varchar", length: 80, nullable: true })
  ipAddress: string | null;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt: Date;
}
