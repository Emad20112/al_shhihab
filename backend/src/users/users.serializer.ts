import { User } from "./entities/user.entity";

export function serializeUser(user: User) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    avatar_url: user.avatarUrl,
    is_active: user.isActive,
    is_verified: user.isVerified,
    preferences: user.preferences ?? {},
    created_at: user.createdAt,
    updated_at: user.updatedAt,
  };
}
