import { createParamDecorator, ExecutionContext } from "@nestjs/common";
import { Request } from "express";

export interface AuthenticatedUser {
  id: number;
  email: string | null;
  phone: string | null;
  jti: string;
  sessionId?: string;
  exp?: number;
}

export const CurrentUser = createParamDecorator(
  (_data: unknown, context: ExecutionContext): AuthenticatedUser => {
    const request = context.switchToHttp().getRequest<Request>();
    return request.user as AuthenticatedUser;
  },
);
