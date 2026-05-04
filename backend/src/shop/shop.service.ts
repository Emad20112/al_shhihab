import {
  BadRequestException,
  Injectable,
  NotFoundException,
  OnModuleInit,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";

import { AddCartItemDto, UpdateCartQuantityDto } from "./dto/cart.dto";
import { CartItem } from "./entities/cart-item.entity";
import { ShopCategory } from "./entities/shop-category.entity";
import { ShopProduct } from "./entities/shop-product.entity";
import { TagCategory } from "./entities/tag-category.entity";

@Injectable()
export class ShopService implements OnModuleInit {
  constructor(
    @InjectRepository(ShopProduct)
    private readonly products: Repository<ShopProduct>,
    @InjectRepository(ShopCategory)
    private readonly categories: Repository<ShopCategory>,
    @InjectRepository(TagCategory)
    private readonly tagCategories: Repository<TagCategory>,
    @InjectRepository(CartItem)
    private readonly cartItems: Repository<CartItem>,
  ) {}

  async onModuleInit() {
    await this.seedStore();
  }

  async findProducts(query: {
    category_id?: string;
    category?: string;
    search?: string;
    featured?: string;
  }) {
    const builder = this.products
      .createQueryBuilder("product")
      .where("product.active = :active", { active: true });

    const categoryId = query.category_id ?? query.category;
    if (categoryId) {
      builder.andWhere("product.categoryId = :categoryId", { categoryId });
    }
    if (query.search) {
      builder.andWhere(
        "(product.name LIKE :search OR product.nameAr LIKE :search OR product.description LIKE :search OR product.descriptionAr LIKE :search)",
        { search: `%${query.search}%` },
      );
    }
    if (query.featured === "true" || query.featured === "1") {
      builder.andWhere("product.isFeatured = :featured", { featured: true });
    }

    return builder
      .orderBy("product.priority", "ASC")
      .addOrderBy("product.id", "ASC")
      .getMany();
  }

  async findProduct(identifier: string) {
    const product = await this.products.findOne({
      where: [{ publicId: identifier }, { id: Number(identifier) || 0 }],
    });
    if (!product || !product.active) {
      throw new NotFoundException("المنتج غير موجود");
    }
    return product;
  }

  async findCategories() {
    return this.categories.find({
      where: { active: true },
      order: { priority: "ASC", id: "ASC" },
    });
  }

  async findCategory(identifier: string) {
    const category = await this.categories.findOne({
      where: [{ publicId: identifier }, { id: Number(identifier) || 0 }],
    });
    if (!category || !category.active) {
      throw new NotFoundException("التصنيف غير موجود");
    }
    return category;
  }

  async findTagCategories() {
    return this.tagCategories.find({
      where: { active: true },
      order: { priority: "ASC", id: "ASC" },
    });
  }

  async findTagCategory(identifier: string) {
    const category = await this.tagCategories.findOne({
      where: [{ publicId: identifier }, { id: Number(identifier) || 0 }],
    });
    if (!category || !category.active) {
      throw new NotFoundException("تصنيف الوسم غير موجود");
    }
    return category;
  }

  getAddressOptions() {
    return {
      countries: [{ id: "sa", name: "Saudi Arabia", name_ar: "السعودية" }],
      cities: [
        { id: "riyadh", name: "Riyadh", name_ar: "الرياض" },
        { id: "jeddah", name: "Jeddah", name_ar: "جدة" },
        { id: "dammam", name: "Dammam", name_ar: "الدمام" },
      ],
      address_types: [
        { id: "home", name: "Home", name_ar: "المنزل" },
        { id: "work", name: "Work", name_ar: "العمل" },
      ],
      delivery_notes: [
        { id: "door", name: "Leave at door", name_ar: "اتركها عند الباب" },
        { id: "call", name: "Call on arrival", name_ar: "اتصل عند الوصول" },
      ],
    };
  }

  async getCart(userId: number) {
    return this.cartItems.find({
      where: { userId },
      order: { createdAt: "DESC", id: "DESC" },
    });
  }

  async addToCart(userId: number, dto: AddCartItemDto) {
    const productIdentifier = dto.product_id ?? dto.productId ?? dto.id;
    if (!productIdentifier) {
      throw new BadRequestException("معرف المنتج مطلوب");
    }

    const product = await this.findProduct(productIdentifier);
    if (product.stockCount <= 0) {
      throw new BadRequestException("المنتج غير متوفر");
    }

    const quantity = dto.quantity ?? dto.qty ?? 1;
    const existing = await this.cartItems.findOne({
      where: { userId, productId: product.id },
    });

    if (existing) {
      existing.quantity = Math.min(
        existing.quantity + quantity,
        product.stockCount,
      );
      existing.options = dto.options ?? existing.options ?? {};
      return this.cartItems.save(existing);
    }

    const item = this.cartItems.create({
      userId,
      productId: product.id,
      product,
      quantity: Math.min(quantity, product.stockCount),
      options: dto.options ?? {},
    });
    return this.cartItems.save(item);
  }

  async updateCartItemQuantity(
    userId: number,
    rowId: number,
    dto: UpdateCartQuantityDto,
  ) {
    const item = await this.requireCartItem(userId, rowId);
    const quantity = dto.quantity ?? dto.qty;
    if (!quantity) throw new BadRequestException("الكمية مطلوبة");

    item.quantity = Math.min(quantity, item.product.stockCount);
    return this.cartItems.save(item);
  }

  async deleteCartItem(userId: number, rowId: number) {
    const item = await this.requireCartItem(userId, rowId);
    await this.cartItems.remove(item);
    return { rowId };
  }

  async destroyCart(userId: number) {
    const items = await this.cartItems.find({ where: { userId } });
    if (items.length > 0) await this.cartItems.remove(items);
    return { deleted: items.length };
  }

  private async requireCartItem(userId: number, rowId: number) {
    const item = await this.cartItems.findOne({ where: { id: rowId, userId } });
    if (!item) throw new NotFoundException("عنصر السلة غير موجود");
    return item;
  }

  private async seedStore() {
    if ((await this.categories.count()) === 0) {
      await this.categories.save(
        this.categorySeeds().map((item) => this.categories.create(item)),
      );
    }

    if ((await this.tagCategories.count()) === 0) {
      await this.tagCategories.save(
        this.tagCategorySeeds().map((item) => this.tagCategories.create(item)),
      );
    }

    if ((await this.products.count()) === 0) {
      await this.products.save(
        this.productSeeds().map((item) => this.products.create(item)),
      );
    }
  }

  private categorySeeds(): Partial<ShopCategory>[] {
    return [
      {
        publicId: "men",
        name: "Men Clothing",
        nameAr: "ملابس رجالية",
        icon: "man",
        color: "#2F80ED",
        imageUrl:
          "https://images.unsplash.com/photo-1516257984-b1b4d707412e?w=400",
        priority: 1,
      },
      {
        publicId: "women",
        name: "Women Clothing",
        nameAr: "ملابس نسائية",
        icon: "woman",
        color: "#E84A7A",
        imageUrl:
          "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=400",
        priority: 2,
      },
      {
        publicId: "sneakers",
        name: "Sneakers",
        nameAr: "أحذية رياضية",
        icon: "directions_run",
        color: "#00A676",
        imageUrl:
          "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400",
        priority: 3,
      },
      {
        publicId: "formal_shoes",
        name: "Formal Shoes",
        nameAr: "أحذية رسمية",
        icon: "work",
        color: "#8B5E3C",
        imageUrl:
          "https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=400",
        priority: 4,
      },
      {
        publicId: "bags",
        name: "Bags",
        nameAr: "الحقائب",
        icon: "shopping_bag",
        color: "#00B4D8",
        imageUrl:
          "https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=400",
        priority: 5,
      },
    ];
  }

  private tagCategorySeeds(): Partial<TagCategory>[] {
    return [
      {
        publicId: "new",
        name: "New",
        nameAr: "جديد",
        slug: "new",
        priority: 1,
      },
      {
        publicId: "sale",
        name: "Sale",
        nameAr: "تخفيضات",
        slug: "sale",
        priority: 2,
      },
      {
        publicId: "premium",
        name: "Premium",
        nameAr: "فاخر",
        slug: "premium",
        priority: 3,
      },
    ];
  }

  private productSeeds(): Partial<ShopProduct>[] {
    return [
      {
        publicId: "p001",
        name: "Premium Cotton Overshirt",
        nameAr: "قميص قطني فاخر",
        price: "149.00",
        originalPrice: "199.00",
        description:
          "Soft mid-weight cotton overshirt with a relaxed cut and everyday styling.",
        descriptionAr:
          "قميص قطني متوسط السماكة بقصة مريحة، مناسب للإطلالات اليومية والعمل.",
        rating: "4.80",
        reviewCount: 1240,
        imageUrl:
          "https://images.unsplash.com/photo-1516257984-b1b4d707412e?w=800",
        categoryId: "men",
        unit: "Piece",
        unitAr: "قطعة",
        isFeatured: true,
        isNew: true,
        stockCount: 18,
        specs: { Material: "Cotton", Fit: "Relaxed", Season: "All season" },
        colors: ["#111827", "#D1D5DB", "#A16207"],
        priority: 1,
      },
      {
        publicId: "p002",
        name: "Flowy Midi Dress",
        nameAr: "فستان ميدي ناعم",
        price: "189.00",
        originalPrice: "249.00",
        description:
          "Lightweight midi dress with an elegant drape for everyday occasions.",
        descriptionAr: "فستان ميدي خفيف بانسيابية أنيقة للمناسبات اليومية.",
        rating: "4.70",
        reviewCount: 980,
        imageUrl:
          "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800",
        categoryId: "women",
        unit: "Piece",
        unitAr: "قطعة",
        isFeatured: true,
        stockCount: 12,
        specs: { Material: "Polyester Blend", Fit: "Regular", Length: "Midi" },
        colors: ["#E84A7A", "#111827", "#F8FAFC"],
        priority: 2,
      },
      {
        publicId: "p003",
        name: "Urban Running Sneakers",
        nameAr: "حذاء رياضي حضري",
        price: "219.00",
        originalPrice: "299.00",
        description:
          "Comfortable sneakers for city walks, training, and casual style.",
        descriptionAr: "حذاء رياضي مريح للمشي والتدريب والإطلالات اليومية.",
        rating: "4.90",
        reviewCount: 2100,
        imageUrl:
          "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800",
        categoryId: "sneakers",
        unit: "Pair",
        unitAr: "زوج",
        isFeatured: true,
        isNew: true,
        stockCount: 24,
        specs: { Upper: "Mesh", Sole: "Rubber", Use: "Running" },
        colors: ["#FFFFFF", "#111827", "#EF4444"],
        priority: 3,
      },
      {
        publicId: "p004",
        name: "Classic Leather Loafers",
        nameAr: "حذاء رسمي جلدي كلاسيكي",
        price: "279.00",
        description:
          "Polished leather loafers for work, meetings, and formal outfits.",
        descriptionAr: "حذاء جلدي أنيق للعمل والاجتماعات والإطلالات الرسمية.",
        rating: "4.60",
        reviewCount: 760,
        imageUrl:
          "https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=800",
        categoryId: "formal_shoes",
        unit: "Pair",
        unitAr: "زوج",
        isFeatured: true,
        stockCount: 10,
        specs: { Material: "Leather", Sole: "Rubber", Style: "Formal" },
        colors: ["#3F2A1D", "#111827"],
        priority: 4,
      },
      {
        publicId: "p005",
        name: "Minimal Crossbody Bag",
        nameAr: "حقيبة كروس بودي بسيطة",
        price: "135.00",
        description:
          "Compact crossbody bag with adjustable strap and secure zipper.",
        descriptionAr: "حقيبة كروس بودي صغيرة بحزام قابل للتعديل وسحاب آمن.",
        rating: "4.70",
        reviewCount: 530,
        imageUrl:
          "https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=800",
        categoryId: "bags",
        unit: "Piece",
        unitAr: "قطعة",
        stockCount: 16,
        specs: { Material: "Vegan Leather", Strap: "Adjustable" },
        colors: ["#000000", "#C08457", "#F8FAFC"],
        priority: 5,
      },
    ];
  }
}
