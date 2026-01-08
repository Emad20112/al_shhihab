import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/dummy_data.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SEARCH PROVIDER - Search State Management
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Manages search query and filters products in real-time.
///
/// Features:
/// • Real-time search as user types
/// • Filters by product name, Arabic name, and category
/// • Case-insensitive matching
/// ═══════════════════════════════════════════════════════════════════════════

/// Provider for the current search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered search results
final searchResultsProvider = Provider<List<ProductModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  if (query.isEmpty) {
    return [];
  }

  return dummyProducts.where((product) {
    // Search in English name
    final nameMatch = product.name.toLowerCase().contains(query);

    // Search in Arabic name
    final nameArMatch = product.nameAr.contains(query);

    // Search in category
    final categoryMatch = product.category.toLowerCase().contains(query);

    // Search in description
    final descMatch = product.description.toLowerCase().contains(query);

    return nameMatch || nameArMatch || categoryMatch || descMatch;
  }).toList();
});

/// Provider to check if search has results
final hasSearchResultsProvider = Provider<bool>((ref) {
  final query = ref.watch(searchQueryProvider);
  final results = ref.watch(searchResultsProvider);
  return query.isNotEmpty && results.isNotEmpty;
});

/// Provider to check if search is active (query not empty but no results)
final isNoResultsProvider = Provider<bool>((ref) {
  final query = ref.watch(searchQueryProvider);
  final results = ref.watch(searchResultsProvider);
  return query.trim().isNotEmpty && results.isEmpty;
});

/// Popular search tags for suggestions
final popularTagsProvider = Provider<List<String>>((ref) {
  return [
    'iPhone',
    'Samsung',
    'Headphones',
    'Laptop',
    'Watch',
    'Gaming',
    'Wireless',
    'Tablet',
  ];
});

/// Arabic popular tags
final popularTagsArProvider = Provider<List<String>>((ref) {
  return [
    'آيفون',
    'سامسونج',
    'سماعات',
    'لابتوب',
    'ساعة',
    'ألعاب',
    'لاسلكي',
    'تابلت',
  ];
});
