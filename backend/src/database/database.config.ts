import { TypeOrmModuleOptions } from "@nestjs/typeorm";

import { Advert } from "../adverts/entities/advert.entity";
import { User } from "../users/entities/user.entity";
import { VerificationCode } from "../verification/entities/verification-code.entity";
import { RevokedToken } from "../auth/entities/revoked-token.entity";
import { UserSession } from "../auth/entities/user-session.entity";
import { CartItem } from "../shop/entities/cart-item.entity";
import { ShopCategory } from "../shop/entities/shop-category.entity";
import { ShopProduct } from "../shop/entities/shop-product.entity";
import { TagCategory } from "../shop/entities/tag-category.entity";

export function databaseConfig(): TypeOrmModuleOptions {
  return {
    type: "mysql",
    host: process.env.DB_HOST ?? "127.0.0.1",
    port: Number(process.env.DB_PORT ?? 3306),
    username: process.env.DB_USERNAME ?? "al_shihab",
    password: process.env.DB_PASSWORD ?? "al_shihab_password",
    database: process.env.DB_DATABASE ?? "al_shihab_local",
    entities: [
      User,
      VerificationCode,
      RevokedToken,
      UserSession,
      Advert,
      ShopProduct,
      ShopCategory,
      TagCategory,
      CartItem,
    ],
    synchronize: (process.env.DB_SYNCHRONIZE ?? "false") === "true",
    logging: process.env.NODE_ENV === "development",
  };
}
