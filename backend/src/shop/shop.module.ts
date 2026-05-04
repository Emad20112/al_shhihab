import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";

import { AuthModule } from "../auth/auth.module";
import { AppCredentialsGuard } from "../common/app-credentials.guard";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { CartItem } from "./entities/cart-item.entity";
import { ShopCategory } from "./entities/shop-category.entity";
import { ShopProduct } from "./entities/shop-product.entity";
import { TagCategory } from "./entities/tag-category.entity";
import { CartsController, ShopController } from "./shop.controller";
import { ShopService } from "./shop.service";

@Module({
  imports: [
    AuthModule,
    TypeOrmModule.forFeature([
      ShopProduct,
      ShopCategory,
      TagCategory,
      CartItem,
    ]),
  ],
  controllers: [ShopController, CartsController],
  providers: [ShopService, AppCredentialsGuard, JwtAuthGuard],
  exports: [ShopService],
})
export class ShopModule {}
