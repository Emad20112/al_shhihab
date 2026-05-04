import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/dummy_data.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/shop_repository.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(apiClient: ref.watch(apiClientProvider));
});

final shopProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  try {
    final products = await ref.watch(shopRepositoryProvider).fetchProducts();
    return products.isEmpty ? dummyProducts : products;
  } catch (_) {
    return dummyProducts;
  }
});

final shopCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  try {
    final categories = await ref
        .watch(shopRepositoryProvider)
        .fetchCategories();
    return categories.isEmpty ? dummyCategories : categories;
  } catch (_) {
    return dummyCategories;
  }
});
