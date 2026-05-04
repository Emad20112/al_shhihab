import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UseGuards,
} from "@nestjs/common";
import { ApiBearerAuth, ApiHeader, ApiTags } from "@nestjs/swagger";

import { AuthenticatedUser, CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { ok, unwrapData } from "../common/api-response";
import { AppCredentialsGuard } from "../common/app-credentials.guard";
import { validateData } from "../common/validate-data";
import { AddCartItemDto, UpdateCartQuantityDto } from "./dto/cart.dto";
import {
  serializeCart,
  serializeCartItem,
  serializeCategory,
  serializeProduct,
  serializeTagCategory,
} from "./shop.serializer";
import { ShopService } from "./shop.service";

@ApiTags("المتجر")
@Controller()
export class ShopController {
  constructor(private readonly shopService: ShopService) {}

  @Get("blog/categories")
  async blogCategories() {
    const categories = await this.shopService.findCategories();
    return ok(categories.map(serializeCategory), "تم جلب التصنيفات");
  }

  @Get("blog/categories/:id")
  async blogCategory(@Param("id") id: string) {
    const category = await this.shopService.findCategory(id);
    return ok(serializeCategory(category), "تم جلب التصنيف");
  }

  @Get("tags/categories")
  async tagCategories() {
    const categories = await this.shopService.findTagCategories();
    return ok(categories.map(serializeTagCategory), "تم جلب تصنيفات الوسوم");
  }

  @Get("tags/categories/:id")
  async tagCategory(@Param("id") id: string) {
    const category = await this.shopService.findTagCategory(id);
    return ok(serializeTagCategory(category), "تم جلب تصنيف الوسم");
  }

  @Get("location/address/options")
  async addressOptions() {
    return ok(this.shopService.getAddressOptions(), "تم جلب خيارات العنوان");
  }

  @Get("shop/products")
  async products(
    @Query("category_id") categoryId?: string,
    @Query("category") category?: string,
    @Query("search") search?: string,
    @Query("featured") featured?: string,
  ) {
    const products = await this.shopService.findProducts({
      category_id: categoryId,
      category,
      search,
      featured,
    });
    return ok(products.map(serializeProduct), "تم جلب المنتجات");
  }

  @Get("shop/products/:id")
  async product(@Param("id") id: string) {
    const product = await this.shopService.findProduct(id);
    return ok(serializeProduct(product), "تم جلب المنتج");
  }
}

@ApiBearerAuth()
@ApiTags("سلة التسوق")
@ApiHeader({ name: "X-Channel-Id", required: true, example: "android" })
@ApiHeader({ name: "X-API-APP-KEY", required: true })
@ApiHeader({ name: "X-API-APP-SECRET", required: true })
@UseGuards(AppCredentialsGuard, JwtAuthGuard)
@Controller("shop/carts")
export class CartsController {
  constructor(private readonly shopService: ShopService) {}

  @Get()
  async index(@CurrentUser() user: AuthenticatedUser) {
    const items = await this.shopService.getCart(user.id);
    return ok(serializeCart(items), "تم جلب عربة التسوق");
  }

  @Post("add")
  async add(@CurrentUser() user: AuthenticatedUser, @Body() body: unknown) {
    const dto = await validateData(AddCartItemDto, unwrapData(body));
    const item = await this.shopService.addToCart(user.id, dto);
    const items = await this.shopService.getCart(user.id);
    return ok(
      { item: serializeCartItem(item), cart: serializeCart(items) },
      "تمت إضافة المنتج للسلة",
      201,
    );
  }

  @Delete("delete/:rowId")
  async delete(
    @CurrentUser() user: AuthenticatedUser,
    @Param("rowId", ParseIntPipe) rowId: number,
  ) {
    await this.shopService.deleteCartItem(user.id, rowId);
    const items = await this.shopService.getCart(user.id);
    return ok(serializeCart(items), "تم حذف عنصر السلة");
  }

  @Delete("destroy")
  async destroy(@CurrentUser() user: AuthenticatedUser) {
    await this.shopService.destroyCart(user.id);
    return ok(serializeCart([]), "تم تفريغ السلة");
  }

  @Post("updateqty/:rowId")
  async updateQuantity(
    @CurrentUser() user: AuthenticatedUser,
    @Param("rowId", ParseIntPipe) rowId: number,
    @Body() body: unknown,
  ) {
    const dto = await validateData(UpdateCartQuantityDto, unwrapData(body));
    const item = await this.shopService.updateCartItemQuantity(
      user.id,
      rowId,
      dto,
    );
    const items = await this.shopService.getCart(user.id);
    return ok(
      { item: serializeCartItem(item), cart: serializeCart(items) },
      "تم تحديث كمية المنتج",
    );
  }
}
