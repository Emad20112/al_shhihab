import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// DUMMY DATA - Electronics Store Mock Data
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Contains models and mock data for:
/// • Products (high-end electronics with futuristic names)
/// • Categories (with icons and colors)
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// PRODUCT MODEL
// ═══════════════════════════════════════════════════════════════════════════

class ProductModel {
  final String id;
  final String name;
  final String nameAr;
  final double price;
  final double? originalPrice; // For showing discounts
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
    this.isFeatured = false,
    this.isNew = false,
    this.stockCount = 10,
    this.specs = const {},
    this.colors = const [],
  });

  /// Calculate discount percentage
  int? get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return ((originalPrice! - price) / originalPrice! * 100).round();
  }

  /// Check if in stock
  bool get inStock => stockCount > 0;
}

// ═══════════════════════════════════════════════════════════════════════════
// CATEGORY MODEL
// ═══════════════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════════════
// DUMMY CATEGORIES
// ═══════════════════════════════════════════════════════════════════════════

final List<CategoryModel> dummyCategories = [
  CategoryModel(
    id: 'smartphones',
    name: 'Smartphones',
    nameAr: 'الهواتف الذكية',
    icon: Icons.phone_iphone_rounded,
    color: const Color(0xFF00D9FF),
    imageUrl:
        'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400',
  ),
  CategoryModel(
    id: 'laptops',
    name: 'Laptops',
    nameAr: 'اللابتوب',
    icon: Icons.laptop_mac_rounded,
    color: const Color(0xFFBB00FF),
    imageUrl:
        'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400',
  ),
  CategoryModel(
    id: 'headphones',
    name: 'Headphones',
    nameAr: 'سماعات الرأس',
    icon: Icons.headphones_rounded,
    color: const Color(0xFFFF00E5),
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
  ),
  CategoryModel(
    id: 'smartwatches',
    name: 'Smartwatches',
    nameAr: 'الساعات الذكية',
    icon: Icons.watch_rounded,
    color: const Color(0xFF00FF88),
    imageUrl:
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
  ),
  CategoryModel(
    id: 'gaming',
    name: 'Gaming',
    nameAr: 'الألعاب',
    icon: Icons.sports_esports_rounded,
    color: const Color(0xFFFF6B00),
    imageUrl:
        'https://images.unsplash.com/photo-1612287230202-1ff1d85d1bdf?w=400',
  ),
  CategoryModel(
    id: 'audio',
    name: 'Audio',
    nameAr: 'الصوتيات',
    icon: Icons.speaker_rounded,
    color: const Color(0xFF6C63FF),
    imageUrl: 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=400',
  ),
  CategoryModel(
    id: 'tablets',
    name: 'Tablets',
    nameAr: 'الأجهزة اللوحية',
    icon: Icons.tablet_mac_rounded,
    color: const Color(0xFF00A3FF),
    imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
  ),
  CategoryModel(
    id: 'accessories',
    name: 'Accessories',
    nameAr: 'الإكسسوارات',
    icon: Icons.cable_rounded,
    color: const Color(0xFFFFAB00),
    imageUrl:
        'https://images.unsplash.com/photo-1625772452859-1c03d5bf1137?w=400',
  ),
];

// ═══════════════════════════════════════════════════════════════════════════
// DUMMY PRODUCTS - High-End Futuristic Electronics
// ═══════════════════════════════════════════════════════════════════════════

final List<ProductModel> dummyProducts = [
  // ─────────────────────────────────────────────────────────────────────────
  // FEATURED HERO PRODUCTS
  // ─────────────────────────────────────────────────────────────────────────
  ProductModel(
    id: 'p001',
    name: 'Neon Gaming Headset Pro',
    nameAr: 'سماعة الألعاب نيون برو',
    price: 299.99,
    originalPrice: 399.99,
    description:
        'Immersive 7.1 surround sound with RGB lighting that syncs with your gameplay. Features active noise cancellation and a retractable boom mic.',
    descriptionAr:
        'صوت محيطي غامر 7.1 مع إضاءة RGB تتزامن مع ألعابك. تتميز بإلغاء الضوضاء النشط وميكروفون قابل للسحب.',
    rating: 4.9,
    reviewCount: 2847,
    imageUrl:
        'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=800',
    category: 'headphones',
    isFeatured: true,
    isNew: true,
    specs: {
      'Driver Size': '50mm Neodymium',
      'Frequency': '20Hz - 40kHz',
      'Impedance': '32Ω',
      'Connectivity': 'Wireless 2.4GHz / Bluetooth 5.2',
      'Battery': '30 hours',
    },
    colors: ['#00F5FF', '#FF00E5', '#00FF88'],
  ),
  ProductModel(
    id: 'p002',
    name: 'Cyberpunk Laptop X1',
    nameAr: 'لابتوب سايبربانك X1',
    price: 2499.99,
    originalPrice: 2999.99,
    description:
        'Ultra-thin powerhouse with holographic display technology. RTX 5090 graphics and 14th Gen processor for next-level performance.',
    descriptionAr:
        'محطة طاقة رفيعة للغاية مع تقنية العرض الهولوغرافي. رسومات RTX 5090 ومعالج الجيل 14 للأداء المتفوق.',
    rating: 4.8,
    reviewCount: 1256,
    imageUrl:
        'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=800',
    category: 'laptops',
    isFeatured: true,
    specs: {
      'Display': '16" 4K OLED 240Hz',
      'Processor': 'Intel Core i9-14900HX',
      'GPU': 'NVIDIA RTX 5090 16GB',
      'RAM': '64GB DDR5',
      'Storage': '2TB NVMe SSD',
    },
    colors: ['#1A1A2E', '#0D0D1A'],
  ),
  ProductModel(
    id: 'p003',
    name: 'Holographic Smartwatch Ultra',
    nameAr: 'ساعة هولوغرافية ألترا',
    price: 899.99,
    originalPrice: 1099.99,
    description:
        'Project notifications in mid-air with our revolutionary holographic display. Health monitoring with AI-powered insights.',
    descriptionAr:
        'اعرض الإشعارات في الهواء مع شاشتنا الهولوغرافية الثورية. مراقبة صحية مع رؤى مدعومة بالذكاء الاصطناعي.',
    rating: 4.7,
    reviewCount: 892,
    imageUrl:
        'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=800',
    category: 'smartwatches',
    isFeatured: true,
    isNew: true,
    specs: {
      'Display': '2.1" AMOLED + Hologram',
      'Battery': '7 days',
      'Water Resistance': '10ATM',
      'Sensors': 'Heart, SpO2, ECG, Temp',
      'Connectivity': 'LTE / WiFi / BT 5.3',
    },
    colors: ['#00D9FF', '#BB00FF', '#FF6B00'],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // SMARTPHONES
  // ─────────────────────────────────────────────────────────────────────────
  ProductModel(
    id: 'p004',
    name: 'Quantum Phone 15 Pro',
    nameAr: 'كوانتم فون 15 برو',
    price: 1299.99,
    description:
        'Quantum processor with neural AI engine. 200MP camera system captures light beyond human perception.',
    descriptionAr:
        'معالج كمي مع محرك ذكاء اصطناعي عصبي. نظام كاميرا 200 ميجابكسل يلتقط الضوء فوق الإدراك البشري.',
    rating: 4.9,
    reviewCount: 5621,
    imageUrl:
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800',
    category: 'smartphones',
    isNew: true,
    specs: {
      'Display': '6.8" LTPO OLED 144Hz',
      'Processor': 'Quantum A20 Bionic',
      'Camera': '200MP + 50MP + 12MP',
      'Battery': '6000mAh',
      'Charging': '200W Wired / 80W Wireless',
    },
    colors: ['#F5F5FF', '#1A1A2E', '#00D9FF'],
  ),
  ProductModel(
    id: 'p005',
    name: 'Nebula Fold Z',
    nameAr: 'نيبولا فولد زد',
    price: 1899.99,
    originalPrice: 2199.99,
    description:
        'Triple-fold design transforms from phone to tablet to laptop mode. Seamless multitasking on a borderless display.',
    descriptionAr:
        'تصميم ثلاثي الطي يتحول من هاتف إلى جهاز لوحي إلى وضع لابتوب. تعدد مهام سلس على شاشة بدون حدود.',
    rating: 4.6,
    reviewCount: 1823,
    imageUrl:
        'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=800',
    category: 'smartphones',
    isFeatured: true,
    specs: {
      'Display': '8.5" Foldable AMOLED',
      'Processor': 'Nebula X2 Chip',
      'RAM': '16GB',
      'Storage': '512GB',
      'Hinges': 'Titanium Multi-Axis',
    },
    colors: ['#BB00FF', '#00FF88'],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // GAMING
  // ─────────────────────────────────────────────────────────────────────────
  ProductModel(
    id: 'p006',
    name: 'Void Controller Elite',
    nameAr: 'وحدة تحكم فويد إيليت',
    price: 199.99,
    description:
        'Haptic feedback that puts you in the game. Customizable RGB, hall-effect triggers, and zero-latency wireless.',
    descriptionAr:
        'ردود فعل لمسية تضعك في اللعبة. RGB قابل للتخصيص، محفزات تأثير هول، ولاسلكي بدون تأخير.',
    rating: 4.8,
    reviewCount: 3421,
    imageUrl:
        'https://images.unsplash.com/photo-1592840496694-26d035b52b48?w=800',
    category: 'gaming',
    isNew: true,
    specs: {
      'Connectivity': 'Wireless 2.4GHz / Bluetooth',
      'Battery': '40 hours',
      'Triggers': 'Hall Effect Analog',
      'Compatibility': 'PC, PlayStation, Xbox, Switch',
      'Features': 'Programmable Back Buttons',
    },
    colors: ['#00F5FF', '#FF00E5', '#1A1A2E'],
  ),
  ProductModel(
    id: 'p007',
    name: 'Aurora Gaming Monitor 32"',
    nameAr: 'شاشة أورورا للألعاب 32 بوصة',
    price: 1299.99,
    originalPrice: 1599.99,
    description:
        'OLED perfection with 360Hz refresh rate and 0.03ms response time. Immerse yourself in true HDR 1400.',
    descriptionAr:
        'كمال OLED مع معدل تحديث 360Hz ووقت استجابة 0.03 مللي ثانية. انغمس في HDR 1400 الحقيقي.',
    rating: 4.9,
    reviewCount: 987,
    imageUrl:
        'https://images.unsplash.com/photo-1616588589676-62b3bd4ff6d2?w=800',
    category: 'gaming',
    isFeatured: true,
    specs: {
      'Panel': '32" QD-OLED',
      'Resolution': '4K UHD',
      'Refresh Rate': '360Hz',
      'Response Time': '0.03ms',
      'HDR': 'HDR 1400',
    },
    colors: ['#1A1A2E'],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // AUDIO
  // ─────────────────────────────────────────────────────────────────────────
  ProductModel(
    id: 'p008',
    name: 'Pulse Earbuds Pro',
    nameAr: 'سماعات بالس برو',
    price: 249.99,
    description:
        'Spatial audio that adapts to your environment. Crystal-clear calls with AI voice isolation technology.',
    descriptionAr:
        'صوت مكاني يتكيف مع بيئتك. مكالمات واضحة تماماً مع تقنية عزل الصوت بالذكاء الاصطناعي.',
    rating: 4.7,
    reviewCount: 4532,
    imageUrl:
        'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=800',
    category: 'audio',
    isNew: true,
    specs: {
      'Driver': '11mm Custom',
      'ANC': 'Adaptive AI-Powered',
      'Battery': '8h + 32h case',
      'Codec': 'LDAC, aptX Lossless',
      'Water Resistance': 'IPX5',
    },
    colors: ['#F5F5FF', '#1A1A2E', '#00D9FF'],
  ),
  ProductModel(
    id: 'p009',
    name: 'Titan Soundbar Pro',
    nameAr: 'ساوند بار تيتان برو',
    price: 799.99,
    originalPrice: 999.99,
    description:
        'Dolby Atmos 11.1.4 channel sound from a single bar. AI upscaling makes everything sound like a concert.',
    descriptionAr:
        'صوت Dolby Atmos 11.1.4 قناة من شريط واحد. ترقية الذكاء الاصطناعي تجعل كل شيء يبدو كحفل موسيقي.',
    rating: 4.8,
    reviewCount: 1267,
    imageUrl: 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=800',
    category: 'audio',
    specs: {
      'Channels': '11.1.4',
      'Power': '1100W',
      'Dolby': 'Atmos, Vision, TrueHD',
      'Connectivity': 'HDMI eARC, WiFi, BT',
      'Subwoofer': '12" Wireless',
    },
    colors: ['#1A1A2E'],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // TABLETS
  // ─────────────────────────────────────────────────────────────────────────
  ProductModel(
    id: 'p010',
    name: 'Canvas Pro Tablet 14"',
    nameAr: 'جهاز كانفاس برو 14 بوصة',
    price: 1199.99,
    description:
        'The ultimate creative tool with pressure-sensitive stylus and infinite canvas. Desktop-class performance.',
    descriptionAr:
        'الأداة الإبداعية المثلى مع قلم حساس للضغط ولوحة لا نهائية. أداء بمستوى سطح المكتب.',
    rating: 4.8,
    reviewCount: 2156,
    imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800',
    category: 'tablets',
    isFeatured: true,
    specs: {
      'Display': '14.6" OLED 120Hz',
      'Processor': 'M4 Max Chip',
      'RAM': '32GB',
      'Storage': '1TB',
      'Stylus': '4096 Pressure Levels',
    },
    colors: ['#F5F5FF', '#1A1A2E'],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // ACCESSORIES
  // ─────────────────────────────────────────────────────────────────────────
  ProductModel(
    id: 'p011',
    name: 'Infinity Charging Pad',
    nameAr: 'قاعدة شحن إنفينيتي',
    price: 149.99,
    description:
        'Charge up to 5 devices simultaneously with our maglev technology. No more tangled cables.',
    descriptionAr:
        'اشحن حتى 5 أجهزة في وقت واحد مع تقنية المغناطيس. لا مزيد من الكابلات المتشابكة.',
    rating: 4.6,
    reviewCount: 1823,
    imageUrl:
        'https://images.unsplash.com/photo-1586816879360-004f5b0c51e3?w=800',
    category: 'accessories',
    isNew: true,
    specs: {
      'Power': '100W Total',
      'Devices': 'Up to 5',
      'Fast Charge': 'Qi2, MagSafe',
      'Material': 'Glass + Aluminum',
      'Features': 'Device Detection',
    },
    colors: ['#F5F5FF', '#1A1A2E'],
  ),
  ProductModel(
    id: 'p012',
    name: 'HyperDrive USB-C Hub',
    nameAr: 'موزع USB-C هايبر درايف',
    price: 89.99,
    description:
        '12-in-1 connectivity solution with 8K HDMI, 10Gbps data, and 100W passthrough charging.',
    descriptionAr:
        'حل اتصال 12 في 1 مع HDMI 8K ونقل بيانات 10Gbps وشحن مرور 100W.',
    rating: 4.5,
    reviewCount: 2934,
    imageUrl:
        'https://images.unsplash.com/photo-1625772452859-1c03d5bf1137?w=800',
    category: 'accessories',
    specs: {
      'Ports': '12-in-1',
      'HDMI': '8K@60Hz / 4K@120Hz',
      'USB': '2x USB-A, 2x USB-C',
      'Card Reader': 'SD / microSD UHS-II',
      'Charging': '100W PD Passthrough',
    },
    colors: ['#B8B8D0'],
  ),
];

// ═══════════════════════════════════════════════════════════════════════════
// HELPER GETTERS
// ═══════════════════════════════════════════════════════════════════════════

/// Get featured products
List<ProductModel> get featuredProducts =>
    dummyProducts.where((p) => p.isFeatured).toList();

/// Get new arrivals
List<ProductModel> get newArrivals =>
    dummyProducts.where((p) => p.isNew).toList();

/// Get products by category
List<ProductModel> getProductsByCategory(String categoryId) =>
    dummyProducts.where((p) => p.category == categoryId).toList();

/// Get products with discount
List<ProductModel> get discountedProducts =>
    dummyProducts.where((p) => p.discountPercent != null).toList();

/// Get top rated products
List<ProductModel> get topRatedProducts {
  final sorted = List<ProductModel>.from(dummyProducts)
    ..sort((a, b) => b.rating.compareTo(a.rating));
  return sorted.take(6).toList();
}
