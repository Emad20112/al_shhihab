import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// WISHLIST PROVIDER - Favorites State Management
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Manages the user's wishlist/favorites using Riverpod.
///
/// Features:
/// • Toggle favorite status for products
/// • Check if a product is in wishlist
/// • Efficient rebuilds using family providers
/// ═══════════════════════════════════════════════════════════════════════════

/// State containing the set of favorite product IDs
class WishlistState {
  final Set<String> favoriteIds;

  const WishlistState({this.favoriteIds = const {}});

  WishlistState copyWith({Set<String>? favoriteIds}) {
    return WishlistState(favoriteIds: favoriteIds ?? this.favoriteIds);
  }

  bool isFavorite(String productId) => favoriteIds.contains(productId);

  int get count => favoriteIds.length;
}

/// Notifier for managing wishlist state
class WishlistNotifier extends Notifier<WishlistState> {
  @override
  WishlistState build() {
    return const WishlistState();
  }

  /// Toggle a product's favorite status
  void toggleFavorite(String productId) {
    final currentFavorites = Set<String>.from(state.favoriteIds);

    if (currentFavorites.contains(productId)) {
      currentFavorites.remove(productId);
    } else {
      currentFavorites.add(productId);
    }

    state = state.copyWith(favoriteIds: currentFavorites);
  }

  /// Add a product to favorites
  void addToFavorites(String productId) {
    if (!state.isFavorite(productId)) {
      final currentFavorites = Set<String>.from(state.favoriteIds);
      currentFavorites.add(productId);
      state = state.copyWith(favoriteIds: currentFavorites);
    }
  }

  /// Remove a product from favorites
  void removeFromFavorites(String productId) {
    if (state.isFavorite(productId)) {
      final currentFavorites = Set<String>.from(state.favoriteIds);
      currentFavorites.remove(productId);
      state = state.copyWith(favoriteIds: currentFavorites);
    }
  }

  /// Clear all favorites
  void clearAll() {
    state = const WishlistState();
  }
}

/// Main wishlist provider
final wishlistProvider = NotifierProvider<WishlistNotifier, WishlistState>(() {
  return WishlistNotifier();
});

/// Convenience provider to check if a specific product is favorite
/// Usage: ref.watch(isFavoriteProvider(productId))
final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(wishlistProvider).isFavorite(productId);
});

/// Provider for wishlist count (for badges)
final wishlistCountProvider = Provider<int>((ref) {
  return ref.watch(wishlistProvider).count;
});
