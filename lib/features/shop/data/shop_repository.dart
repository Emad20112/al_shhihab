import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../data/dummy_data.dart';

class ShopRepository {
  const ShopRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<ProductModel>> fetchProducts({
    String? categoryId,
    String? search,
    bool? featured,
  }) async {
    final response = await _apiClient.get<List<ProductModel>>(
      '/shop/products',
      authenticated: false,
      queryParameters: {
        'category_id': ?categoryId,
        if (search != null && search.trim().isNotEmpty) 'search': search,
        'featured': ?featured,
      },
      fromData: (value) {
        if (value is! List) return const <ProductModel>[];
        return value
            .whereType<Map>()
            .map((item) => _productFromJson(Map<String, dynamic>.from(item)))
            .toList();
      },
    );

    return response.data ?? const <ProductModel>[];
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _apiClient.get<List<CategoryModel>>(
      '/blog/categories',
      authenticated: false,
      fromData: (value) {
        if (value is! List) return const <CategoryModel>[];
        return value
            .whereType<Map>()
            .map((item) => _categoryFromJson(Map<String, dynamic>.from(item)))
            .toList();
      },
    );

    return response.data ?? const <CategoryModel>[];
  }

  ProductModel _productFromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? json['name']?.toString() ?? '',
      price: _doubleFromJson(json['price']) ?? 0,
      originalPrice: _doubleFromJson(json['original_price']),
      description: json['description']?.toString() ?? '',
      descriptionAr:
          json['description_ar']?.toString() ??
          json['description']?.toString() ??
          '',
      rating: _doubleFromJson(json['rating']) ?? 0,
      reviewCount: _intFromJson(json['review_count']) ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
      category:
          json['category_id']?.toString() ?? json['category']?.toString() ?? '',
      unit: json['unit']?.toString() ?? 'Piece',
      unitAr: json['unit_ar']?.toString() ?? 'قطعة',
      isFeatured: json['is_featured'] == true,
      isNew: json['is_new'] == true,
      stockCount: _intFromJson(json['stock_count']) ?? 0,
      specs: _stringMapFromJson(json['specs']),
      colors: _stringListFromJson(json['colors']),
    );
  }

  CategoryModel _categoryFromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? json['name']?.toString() ?? '',
      icon: _iconFromJson(json['icon']?.toString()),
      color: _colorFromJson(json['color']?.toString()),
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }

  IconData _iconFromJson(String? value) {
    switch (value) {
      case 'man':
        return Icons.man_rounded;
      case 'woman':
        return Icons.woman_rounded;
      case 'directions_run':
        return Icons.directions_run_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'watch':
        return Icons.watch_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _colorFromJson(String? value) {
    if (value == null || value.isEmpty) return const Color(0xFF0F766E);
    final hex = value.replaceFirst('#', '');
    final parsed = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
    return parsed == null ? const Color(0xFF0F766E) : Color(parsed);
  }

  Map<String, String> _stringMapFromJson(Object? value) {
    if (value is! Map) return const {};
    return value.map((key, item) => MapEntry(key.toString(), item.toString()));
  }

  List<String> _stringListFromJson(Object? value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }

  int? _intFromJson(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _doubleFromJson(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
