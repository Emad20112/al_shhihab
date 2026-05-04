import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dummy_data.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/cart/data/cart_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CART PROVIDER - Shopping Cart State Management
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Manages cart state with:
/// • Add/Remove items
/// • Increment/Decrement quantities
/// • Total price calculation
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// CART ITEM MODEL
// ═══════════════════════════════════════════════════════════════════════════

/// Cart item wraps a product with quantity
class CartItem {
  final ProductModel product;
  final int quantity;
  final int? rowId;

  const CartItem({required this.product, required this.quantity, this.rowId});

  /// Create a copy with updated quantity
  CartItem copyWith({int? quantity, int? rowId}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      rowId: rowId ?? this.rowId,
    );
  }

  /// Total price for this item (price × quantity)
  double get totalPrice => product.price * quantity;
}

// ═══════════════════════════════════════════════════════════════════════════
// CART NOTIFIER
// ═══════════════════════════════════════════════════════════════════════════

/// Cart notifier - handles cart operations (Riverpod v3 API)
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  CartRepository get _repository =>
      CartRepository(apiClient: ref.read(apiClientProvider));

  /// Add item to cart (increment if exists)
  void addItem(ProductModel product) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Product exists, increment quantity
      final updatedItems = [...state];
      final nextQuantity = updatedItems[existingIndex].quantity + 1;
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: nextQuantity,
      );
      state = updatedItems;
      _syncQuantity(updatedItems[existingIndex], nextQuantity);
    } else {
      // New product, add to cart
      state = [...state, CartItem(product: product, quantity: 1)];
      _syncAdd(product, 1);
    }
  }

  /// Set specific quantity for a product
  void setQuantity(ProductModel product, int quantity) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final updatedItems = [...state];
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: quantity,
      );
      state = updatedItems;
      _syncQuantity(updatedItems[existingIndex], quantity);
    } else {
      state = [...state, CartItem(product: product, quantity: quantity)];
      _syncAdd(product, quantity);
    }
  }

  /// Remove item from cart completely
  void removeItem(String productId) {
    CartItem? existing;
    for (final item in state) {
      if (item.product.id == productId) {
        existing = item;
        break;
      }
    }
    state = state.where((item) => item.product.id != productId).toList();
    if (existing?.rowId != null) {
      unawaited(_repository.deleteItem(existing!.rowId!).catchError((_) {}));
    }
  }

  /// Increment quantity by 1
  void incrementQuantity(String productId) {
    CartItem? changed;
    final updatedItems = state.map((item) {
      if (item.product.id == productId) {
        changed = item.copyWith(quantity: item.quantity + 1);
        return changed!;
      }
      return item;
    }).toList();
    state = updatedItems;
    if (changed != null) _syncQuantity(changed!, changed!.quantity);
  }

  /// Decrement quantity by 1 (remove if reaches 0)
  void decrementQuantity(String productId) {
    final item = state.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: dummyProducts.first, // Fallback, won't be used
        quantity: 0,
      ),
    );

    if (item.quantity <= 1) {
      // Remove item if quantity would be 0
      removeItem(productId);
    } else {
      // Decrement quantity
      CartItem? changed;
      final updatedItems = state.map((item) {
        if (item.product.id == productId) {
          changed = item.copyWith(quantity: item.quantity - 1);
          return changed!;
        }
        return item;
      }).toList();
      state = updatedItems;
      if (changed != null) _syncQuantity(changed!, changed!.quantity);
    }
  }

  /// Clear all items from cart
  void clearCart() {
    state = [];
    unawaited(_repository.clearCart().catchError((_) {}));
  }

  /// Get total price of all items
  double get totalPrice {
    return state.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Get total item count (sum of all quantities)
  int get itemCount {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Check if cart is empty
  bool get isEmpty => state.isEmpty;

  /// Check if product is in cart
  bool isInCart(String productId) {
    return state.any((item) => item.product.id == productId);
  }

  /// Get quantity of specific product
  int getQuantity(String productId) {
    final item = state.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: dummyProducts.first, quantity: 0),
    );
    return item.quantity;
  }

  void _syncAdd(ProductModel product, int quantity) {
    unawaited(
      _repository
          .addItem(productId: product.id, quantity: quantity)
          .then((rowId) {
            if (rowId == null) return;
            state = state
                .map(
                  (item) => item.product.id == product.id
                      ? item.copyWith(rowId: rowId)
                      : item,
                )
                .toList();
          })
          .catchError((_) {}),
    );
  }

  void _syncQuantity(CartItem item, int quantity) {
    if (item.rowId == null) {
      _syncAdd(item.product, quantity);
      return;
    }
    unawaited(
      _repository
          .updateQuantity(rowId: item.rowId!, quantity: quantity)
          .catchError((_) {}),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Main cart provider
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

/// Convenience provider for cart item count
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

/// Convenience provider for cart total price
final cartTotalPriceProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});

/// Convenience provider for cart empty state
final isCartEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});
