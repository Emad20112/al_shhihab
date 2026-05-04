import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { Request } from "express";

@Injectable()
export class AdminKeyGuard implements CanActivate {
  constructor(private readonly config: ConfigService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request>();
    const expectedKey = this.config.get<string>("ADMIN_KEY");

    if (!expectedKey) {
      throw new UnauthorizedException("مفتاح الإدارة غير مهيأ");
    }

    const adminKey = this.header(request, "x-admin-key");
    if (adminKey !== expectedKey) {
      throw new UnauthorizedException("مفتاح الإدارة غير صحيح");
    }

    return true;
  }

  private header(request: Request, name: string): string | undefined {
    const value = request.headers[name];
    return Array.isArray(value) ? value[0] : value;
  }
}
