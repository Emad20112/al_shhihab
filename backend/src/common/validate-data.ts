import { BadRequestException } from "@nestjs/common";
import { plainToInstance } from "class-transformer";
import { validate } from "class-validator";

type ClassConstructor<T> = new (...args: unknown[]) => T;

export async function validateData<T extends object>(
  dtoClass: ClassConstructor<T>,
  data: unknown,
): Promise<T> {
  const instance = plainToInstance(dtoClass, data);
  const errors = await validate(instance, {
    whitelist: true,
    forbidNonWhitelisted: true,
  });

  if (errors.length > 0) {
    throw new BadRequestException({
      message: "بيانات الطلب غير صحيحة",
      errors,
    });
  }

  return instance;
}
