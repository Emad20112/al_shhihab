import 'package:flutter/material.dart';

/// Mock data for a fashion store: clothing, shoes, bags, and accessories.

class ProductModel {
  final String id;
  final String name;
  final String nameAr;
  final double price;
  final double? originalPrice;
  final String description;
  final String descriptionAr;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String category;
  final bool isFeatured;
  final bool isNew;
  final int stockCount;
  final Map<String, String> specs;
  final List<String> colors;

  final String unit;
  final String unitAr;
  final double? coveragePerUnit;

  const ProductModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.descriptionAr,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.category,
    required this.unit,
    required this.unitAr,
    this.coveragePerUnit,
    this.isFeatured = false,
    this.isNew = false,
    this.stockCount = 10,
    this.specs = const {},
    this.colors = const [],
  });

  int? get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return ((originalPrice! - price) / originalPrice! * 100).round();
  }

  bool get inStock => stockCount > 0;
}

class CategoryModel {
  final String id;
  final String name;
  final String nameAr;
  final IconData icon;
  final Color color;
  final String imageUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.color,
    required this.imageUrl,
  });
}

enum AdPlacement { homeHero, homeStrip, category }

class AdvertisementModel {
  final String id;
  final String title;
  final String titleAr;
  final String subtitle;
  final String subtitleAr;
  final String imageUrl;
  final String ctaLabel;
  final String ctaLabelAr;
  final AdPlacement placement;
  final String campaignType;
  final int? discountPercent;
  final String? productId;
  final String? categoryId;
  final int priority;
  final DateTime startsAt;
  final DateTime endsAt;

  const AdvertisementModel({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.subtitle,
    required this.subtitleAr,
    required this.imageUrl,
    required this.ctaLabel,
    required this.ctaLabelAr,
    required this.placement,
    required this.campaignType,
    required this.priority,
    required this.startsAt,
    required this.endsAt,
    this.discountPercent,
    this.productId,
    this.categoryId,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startsAt) && now.isBefore(endsAt);
  }
}

final List<CategoryModel> dummyCategories = [
  CategoryModel(
    id: 'men',
    name: 'Men Clothing',
    nameAr: 'ملابس رجالية',
    icon: Icons.man_rounded,
    color: const Color(0xFF2F80ED),
    imageUrl: 'https://images.unsplash.com/photo-1516257984-b1b4d707412e?w=400',
  ),
  CategoryModel(
    id: 'women',
    name: 'Women Clothing',
    nameAr: 'ملابس نسائية',
    icon: Icons.woman_rounded,
    color: const Color(0xFFE84A7A),
    imageUrl:
        'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=400',
  ),
  CategoryModel(
    id: 'sneakers',
    name: 'Sneakers',
    nameAr: 'أحذية رياضية',
    icon: Icons.directions_run_rounded,
    color: const Color(0xFF00A676),
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
  ),
  CategoryModel(
    id: 'formal_shoes',
    name: 'Formal Shoes',
    nameAr: 'أحذية رسمية',
    icon: Icons.work_rounded,
    color: const Color(0xFF8B5E3C),
    imageUrl:
        'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=400',
  ),
  CategoryModel(
    id: 'kids',
    name: 'Kids Fashion',
    nameAr: 'أزياء الأطفال',
    icon: Icons.child_care_rounded,
    color: const Color(0xFFFFB703),
    imageUrl:
        'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?w=400',
  ),
  CategoryModel(
    id: 'sportswear',
    name: 'Sportswear',
    nameAr: 'ملابس رياضية',
    icon: Icons.fitness_center_rounded,
    color: const Color(0xFF7B61FF),
    imageUrl:
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400',
  ),
  CategoryModel(
    id: 'bags',
    name: 'Bags',
    nameAr: 'الحقائب',
    icon: Icons.shopping_bag_rounded,
    color: const Color(0xFF00B4D8),
    imageUrl:
        'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=400',
  ),
  CategoryModel(
    id: 'accessories',
    name: 'Accessories',
    nameAr: 'الإكسسوارات',
    icon: Icons.watch_rounded,
    color: const Color(0xFFEF476F),
    imageUrl:
        'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=400',
  ),
];

final List<ProductModel> dummyProducts = [
  ProductModel(
    id: 'p001',
    name: 'Premium Cotton Overshirt',
    nameAr: 'قميص قطني فاخر',
    price: 149.00,
    originalPrice: 199.00,
    description:
        'Soft mid-weight cotton overshirt with a relaxed cut, clean stitching, and everyday styling for work or weekends.',
    descriptionAr:
        'قميص قطني متوسط السماكة بقصة مريحة وخياطة أنيقة، مناسب للإطلالات اليومية والعمل ونهاية الأسبوع.',
    rating: 4.8,
    reviewCount: 1240,
    imageUrl:
        'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800',
    category: 'men',
    isFeatured: true,
    isNew: true,
    unit: 'Piece',
    unitAr: 'قطعة',
    specs: {
      'Material': '100% Cotton',
      'Fit': 'Relaxed',
      'Sizes': 'S - XXL',
      'Care': 'Machine Wash',
    },
    colors: ['#1F2937', '#E5E7EB', '#6B7280'],
  ),
  ProductModel(
    id: 'p002',
    name: 'Pleated Midi Dress',
    nameAr: 'فستان ميدي بكسرات',
    price: 229.00,
    originalPrice: 279.00,
    description:
        'Elegant pleated midi dress with a flowing silhouette and breathable fabric for occasions and refined daily looks.',
    descriptionAr:
        'فستان ميدي أنيق بكسرات وقماش مريح بقصة انسيابية، مناسب للمناسبات والإطلالات اليومية الراقية.',
    rating: 4.9,
    reviewCount: 980,
    imageUrl:
        'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=800',
    category: 'women',
    isFeatured: true,
    unit: 'Piece',
    unitAr: 'قطعة',
    specs: {
      'Material': 'Crepe Blend',
      'Length': 'Midi',
      'Sizes': 'XS - XL',
      'Fit': 'Regular',
    },
    colors: ['#111827', '#B45309', '#F3E8FF'],
  ),
  ProductModel(
    id: 'p003',
    name: 'AirFlex Running Sneakers',
    nameAr: 'حذاء إيرفلكس للجري',
    price: 319.00,
    originalPrice: 399.00,
    description:
        'Lightweight running sneakers with cushioned soles, breathable mesh, and stable grip for training and daily walks.',
    descriptionAr:
        'حذاء رياضي خفيف للجري بنعل مبطن وشبك قابل للتهوية وثبات ممتاز للتمارين والمشي اليومي.',
    rating: 4.9,
    reviewCount: 2100,
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
    category: 'sneakers',
    isFeatured: true,
    isNew: true,
    unit: 'Pair',
    unitAr: 'زوج',
    specs: {
      'Upper': 'Breathable Mesh',
      'Sole': 'EVA Cushion',
      'Sizes': '39 - 46',
      'Use': 'Running',
    },
    colors: ['#FFFFFF', '#111827', '#EF4444'],
  ),
  ProductModel(
    id: 'p004',
    name: 'Leather Oxford Shoes',
    nameAr: 'حذاء أوكسفورد جلدي',
    price: 389.00,
    originalPrice: 449.00,
    description:
        'Polished genuine leather Oxford shoes with padded lining and a timeless profile for formal outfits.',
    descriptionAr:
        'حذاء أوكسفورد من الجلد الطبيعي ببطانة مريحة وتصميم كلاسيكي يناسب الإطلالات الرسمية.',
    rating: 4.7,
    reviewCount: 640,
    imageUrl:
        'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=800',
    category: 'formal_shoes',
    unit: 'Pair',
    unitAr: 'زوج',
    specs: {
      'Material': 'Genuine Leather',
      'Lining': 'Padded',
      'Sizes': '40 - 45',
      'Style': 'Oxford',
    },
    colors: ['#3B2415', '#111111'],
  ),
  ProductModel(
    id: 'p005',
    name: 'Kids Denim Jacket',
    nameAr: 'جاكيت جينز للأطفال',
    price: 119.00,
    description:
        'Durable kids denim jacket with soft lining, snap buttons, and an easy fit for active days.',
    descriptionAr:
        'جاكيت جينز متين للأطفال ببطانة ناعمة وأزرار سهلة وقصة مريحة للأيام النشطة.',
    rating: 4.6,
    reviewCount: 420,
    imageUrl:
        'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=800',
    category: 'kids',
    isNew: true,
    unit: 'Piece',
    unitAr: 'قطعة',
    specs: {
      'Material': 'Denim',
      'Age': '4 - 10 Years',
      'Closure': 'Snap Buttons',
      'Fit': 'Comfort',
    },
    colors: ['#2563EB', '#93C5FD'],
  ),
  ProductModel(
    id: 'p006',
    name: 'Performance Training Set',
    nameAr: 'طقم رياضي للتمارين',
    price: 179.00,
    originalPrice: 219.00,
    description:
        'Moisture-wicking sportswear set with stretch fabric for gym sessions, outdoor runs, and relaxed movement.',
    descriptionAr:
        'طقم رياضي بقماش مرن يمتص الرطوبة، مناسب للنادي والجري والحركة اليومية المريحة.',
    rating: 4.8,
    reviewCount: 760,
    imageUrl:
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
    category: 'sportswear',
    isFeatured: true,
    unit: 'Set',
    unitAr: 'طقم',
    specs: {
      'Fabric': 'Stretch Knit',
      'Pieces': 'Top + Pants',
      'Sizes': 'S - XL',
      'Feature': 'Quick Dry',
    },
    colors: ['#111827', '#0EA5E9', '#22C55E'],
  ),
  ProductModel(
    id: 'p007',
    name: 'Minimal Crossbody Bag',
    nameAr: 'حقيبة كروس بودي بسيطة',
    price: 135.00,
    description:
        'Compact crossbody bag with adjustable strap, secure zipper, and enough room for daily essentials.',
    descriptionAr:
        'حقيبة كروس بودي صغيرة بحزام قابل للتعديل وسحاب آمن ومساحة مناسبة للاحتياجات اليومية.',
    rating: 4.7,
    reviewCount: 530,
    imageUrl:
        'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=800',
    category: 'bags',
    unit: 'Piece',
    unitAr: 'قطعة',
    specs: {
      'Material': 'Vegan Leather',
      'Strap': 'Adjustable',
      'Closure': 'Zip',
      'Size': 'Small',
    },
    colors: ['#000000', '#C08457', '#F8FAFC'],
  ),
  ProductModel(
    id: 'p008',
    name: 'Classic Steel Watch',
    nameAr: 'ساعة ستانلس كلاسيكية',
    price: 259.00,
    originalPrice: 299.00,
    description:
        'Classic stainless-steel watch with a clean dial, water resistance, and an adjustable bracelet.',
    descriptionAr:
        'ساعة كلاسيكية من الستانلس ستيل بميناء أنيق ومقاومة للماء وسوار قابل للتعديل.',
    rating: 4.8,
    reviewCount: 870,
    imageUrl:
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
    category: 'accessories',
    unit: 'Piece',
    unitAr: 'قطعة',
    specs: {
      'Case': 'Stainless Steel',
      'Water Resist': '3 ATM',
      'Movement': 'Quartz',
      'Warranty': '1 Year',
    },
    colors: ['#D1D5DB', '#111827'],
  ),
];

List<ProductModel> get featuredProducts =>
    dummyProducts.where((p) => p.isFeatured).toList();

List<ProductModel> get newArrivals =>
    dummyProducts.where((p) => p.isNew).toList();

List<ProductModel> getProductsByCategory(String categoryId) =>
    dummyProducts.where((p) => p.category == categoryId).toList();

List<ProductModel> get discountedProducts =>
    dummyProducts.where((p) => p.discountPercent != null).toList();

List<ProductModel> get topRatedProducts {
  final sorted = List<ProductModel>.from(dummyProducts)
    ..sort((a, b) => b.rating.compareTo(a.rating));
  return sorted.take(6).toList();
}
