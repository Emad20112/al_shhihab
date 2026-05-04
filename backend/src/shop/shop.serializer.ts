import { CartItem } from "./entities/cart-item.entity";
import { ShopCategory } from "./entities/shop-category.entity";
import { ShopProduct } from "./entities/shop-product.entity";
import { TagCategory } from "./entities/tag-category.entity";

export function serializeProduct(product: ShopProduct) {
  const price = Number(product.price);
  const originalPrice = product.originalPrice
    ? Number(product.originalPrice)
    : null;
  const discountPercent =
    originalPrice && originalPrice > price
      ? Math.round(((originalPrice - price) / originalPrice) * 100)
      : null;

  return {
    id: product.publicId,
    row_id: product.id,
    name: product.name,
    name_ar: product.nameAr,
    price,
    original_price: originalPrice,
    discount_percent: discountPercent,
    description: product.description,
    description_ar: product.descriptionAr,
    rating: Number(product.rating),
    review_count: product.reviewCount,
    image_url: product.imageUrl,
    category: product.categoryId,
    category_id: product.categoryId,
    unit: product.unit,
    unit_ar: product.unitAr,
    is_featured: product.isFeatured,
    is_new: product.isNew,
    stock_count: product.stockCount,
    in_stock: product.stockCount > 0,
    specs: product.specs ?? {},
    colors: product.colors ?? [],
    active: product.active,
    priority: product.priority,
    created_at: product.createdAt,
    updated_at: product.updatedAt,
  };
}

export function serializeCategory(category: ShopCategory) {
  return {
    id: category.publicId,
    row_id: category.id,
    name: category.name,
    name_ar: category.nameAr,
    icon: category.icon,
    color: category.color,
    image_url: category.imageUrl,
    active: category.active,
    priority: category.priority,
    created_at: category.createdAt,
    updated_at: category.updatedAt,
  };
}

export function serializeTagCategory(category: TagCategory) {
  return {
    id: category.publicId,
    row_id: category.id,
    name: category.name,
    name_ar: category.nameAr,
    slug: category.slug,
    active: category.active,
    priority: category.priority,
    created_at: category.createdAt,
    updated_at: category.updatedAt,
  };
}

export function serializeCartItem(item: CartItem) {
  const product = serializeProduct(item.product);
  const unitPrice = product.price;

  return {
    rowId: item.id,
    row_id: item.id,
    id: item.id,
    product_id: product.id,
    quantity: item.quantity,
    qty: item.quantity,
    price: unitPrice,
    subtotal: Number((unitPrice * item.quantity).toFixed(2)),
    options: item.options ?? {},
    product,
    created_at: item.createdAt,
    updated_at: item.updatedAt,
  };
}

export function serializeCart(items: CartItem[]) {
  const rows = items.map(serializeCartItem);
  const total = rows.reduce((sum, item) => sum + item.subtotal, 0);
  const quantity = rows.reduce((sum, item) => sum + item.quantity, 0);

  return {
    items: rows,
    rows,
    count: rows.length,
    quantity,
    total: Number(total.toFixed(2)),
    subtotal: Number(total.toFixed(2)),
  };
}
