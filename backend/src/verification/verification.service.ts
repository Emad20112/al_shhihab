import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { InjectRepository } from "@nestjs/typeorm";
import * as bcrypt from "bcryptjs";
import { IsNull, Repository } from "typeorm";

import { AuthService } from "../auth/auth.service";
import { UsersService } from "../users/users.service";
import { CheckVerificationDto } from "./dto/check-verification.dto";
import { SendVerificationDto } from "./dto/send-verification.dto";
import { VerificationCode } from "./entities/verification-code.entity";

@Injectable()
export class VerificationService {
  constructor(
    @InjectRepository(VerificationCode)
    private readonly codesRepository: Repository<VerificationCode>,
    private readonly usersService: UsersService,
    private readonly authService: AuthService,
    private readonly config: ConfigService,
  ) {}

  async send(dto: SendVerificationDto) {
    const contact = this.resolveContact(dto);
    const code = this.createCode();
    const codeHash = await bcrypt.hash(code, 10);
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await this.codesRepository.save(
      this.codesRepository.create({
        contact,
        channel: dto.channel,
        codeHash,
        expiresAt,
        usedAt: null,
      }),
    );

    return {
      contact,
      channel: dto.channel,
      expires_at: expiresAt,
      dev_code:
        this.config.get<string>("NODE_ENV", "development") === "development"
          ? code
          : undefined,
    };
  }

  async check(dto: CheckVerificationDto) {
    const contact = this.resolveContact(dto);
    const code = dto.code ?? dto.otp;
    if (!code) throw new BadRequestException("رمز التحقق مطلوب");

    const record = await this.codesRepository.findOne({
      where: {
        contact,
        channel: dto.channel,
        usedAt: IsNull(),
      },
      order: { createdAt: "DESC" },
    });

    if (!record || record.expiresAt.getTime() < Date.now()) {
      throw new UnauthorizedException("رمز التحقق غير صالح أو منتهي");
    }
    if (record.attempts >= 5) {
      throw new HttpException(
        "تم تجاوز عدد المحاولات",
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    const valid = await bcrypt.compare(code, record.codeHash);
    if (!valid) {
      record.attempts += 1;
      await this.codesRepository.save(record);
      throw new UnauthorizedException("رمز التحقق غير صحيح");
    }

    record.usedAt = new Date();
    await this.codesRepository.save(record);

    const user = await this.usersService.markVerifiedByContact(contact);
    if (!user) {
      return {
        verified: true,
        contact,
        user: null,
      };
    }

    return {
      verified: true,
      contact,
      ...(await this.authService.issueSession(user)),
    };
  }

  private resolveContact(dto: {
    phone?: string;
  }) {
    const contact = dto.phone;
    if (!contact) {
      throw new BadRequestException("رقم الهاتف مطلوب");
    }
    return contact;
  }

  private createCode() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }
}
