import {
  ConflictException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";

import { AdminUpdateUserDto } from "./dto/admin-update-user.dto";
import { UpdateMeDto } from "./dto/update-me.dto";
import { User } from "./entities/user.entity";

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  findById(id: number) {
    return this.usersRepository.findOne({ where: { id } });
  }

  findByIdentifier(identifier: string) {
    return this.usersRepository
      .createQueryBuilder("user")
      .where("user.email = :identifier", { identifier })
      .orWhere("user.phone = :identifier", { identifier })
      .getOne();
  }

  findAllForAdmin() {
    return this.usersRepository.find({
      order: { createdAt: "DESC", id: "DESC" },
    });
  }

  async create(input: {
    name: string;
    email?: string | null;
    phone?: string | null;
    passwordHash: string;
  }) {
    await this.ensureUnique(input.email, input.phone);
    const user = this.usersRepository.create({
      name: input.name,
      email: input.email ?? null,
      phone: input.phone ?? null,
      passwordHash: input.passwordHash,
      preferences: {},
    });
    return this.usersRepository.save(user);
  }

  async updateMe(userId: number, dto: UpdateMeDto) {
    const user = await this.requireById(userId);
    await this.ensureUnique(dto.email, dto.phone, user.id);

    if (dto.name !== undefined) user.name = dto.name;
    if (dto.email !== undefined) user.email = dto.email;
    if (dto.phone !== undefined) user.phone = dto.phone;

    return this.usersRepository.save(user);
  }

  async updateForAdmin(userId: number, dto: AdminUpdateUserDto) {
    const user = await this.requireById(userId);
    await this.ensureUnique(dto.email, dto.phone, user.id);

    if (dto.name !== undefined) user.name = dto.name;
    if (dto.email !== undefined) user.email = dto.email || null;
    if (dto.phone !== undefined) user.phone = dto.phone || null;
    if (dto.is_active !== undefined) user.isActive = dto.is_active;
    if (dto.is_verified !== undefined) user.isVerified = dto.is_verified;

    return this.usersRepository.save(user);
  }

  async removeForAdmin(userId: number) {
    const user = await this.requireById(userId);
    await this.usersRepository.remove(user);
    return { id: userId };
  }

  async updateAvatar(userId: number, avatarUrl: string | null) {
    const user = await this.requireById(userId);
    user.avatarUrl = avatarUrl;
    return this.usersRepository.save(user);
  }

  async updatePreferences(
    userId: number,
    preferences: Record<string, unknown>,
  ) {
    const user = await this.requireById(userId);
    user.preferences = {
      ...(user.preferences ?? {}),
      ...preferences,
    };
    return this.usersRepository.save(user);
  }

  async updatePasswordHash(userId: number, passwordHash: string) {
    const user = await this.requireById(userId);
    user.passwordHash = passwordHash;
    return this.usersRepository.save(user);
  }

  async markVerifiedByContact(contact: string) {
    const user = await this.findByIdentifier(contact);
    if (!user) return null;

    user.isVerified = true;
    return this.usersRepository.save(user);
  }

  async requireById(id: number) {
    const user = await this.findById(id);
    if (!user) throw new NotFoundException("المستخدم غير موجود");
    return user;
  }

  private async ensureUnique(
    email?: string | null,
    phone?: string | null,
    ignoreUserId?: number,
  ) {
    if (!email && !phone) return;

    const duplicate = await this.usersRepository
      .createQueryBuilder("user")
      .where(email ? "user.email = :email" : "1 = 0", { email })
      .orWhere(phone ? "user.phone = :phone" : "1 = 0", { phone })
      .getOne();

    if (duplicate && duplicate.id !== ignoreUserId) {
      const phoneTaken = Boolean(phone && duplicate.phone === phone);
      const emailTaken = Boolean(email && duplicate.email === email);

      if (phoneTaken && emailTaken) {
        throw new ConflictException("رقم الهاتف والبريد الإلكتروني مستخدمان مسبقاً");
      }
      if (phoneTaken) {
        throw new ConflictException("رقم الهاتف مستخدم مسبقاً");
      }
      if (emailTaken) {
        throw new ConflictException("البريد الإلكتروني مستخدم مسبقاً");
      }
      throw new ConflictException("هذه البيانات مستخدمة مسبقاً");
    }
  }
}
