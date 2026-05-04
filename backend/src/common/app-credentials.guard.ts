import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { Request } from "express";

@Injectable()
export class AppCredentialsGuard implements CanActivate {
  constructor(private readonly config: ConfigService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request>();
    const expectedKey = this.config.get<string>("APP_KEY");
    const expectedSecret = this.config.get<string>("APP_SECRET");

    if (!expectedKey && !expectedSecret) return true;

    const appKey = this.header(request, "x-api-app-key");
    const appSecret = this.header(request, "x-api-app-secret");

    if (appKey !== expectedKey || appSecret !== expectedSecret) {
      throw new UnauthorizedException("بيانات التطبيق غير صحيحة");
    }

    return true;
  }

  private header(request: Request, name: string): string | undefined {
    const value = request.headers[name];
    return Array.isArray(value) ? value[0] : value;
  }
}
