import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
} from "typeorm";

@Entity("revoked_tokens")
export class RevokedToken {
  @PrimaryGeneratedColumn()
  id: number;

  @Index({ unique: true })
  @Column({ length: 80 })
  jti: string;

  @Column({ name: "expires_at", type: "datetime" })
  expiresAt: Date;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;
}
