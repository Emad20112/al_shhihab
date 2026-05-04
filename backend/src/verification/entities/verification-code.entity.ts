import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
} from "typeorm";

export type VerificationChannel = "sms" | "whatsapp" | "email";

@Entity("verification_codes")
export class VerificationCode {
  @PrimaryGeneratedColumn()
  id: number;

  @Index()
  @Column({ length: 160 })
  contact: string;

  @Column({ length: 20 })
  channel: VerificationChannel;

  @Column({ name: "code_hash", length: 255 })
  codeHash: string;

  @Column({ default: 0 })
  attempts: number;

  @Column({ name: "expires_at", type: "datetime" })
  expiresAt: Date;

  @Column({ name: "used_at", type: "datetime", nullable: true })
  usedAt: Date | null;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;
}
