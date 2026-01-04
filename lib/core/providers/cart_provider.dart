  import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dummy_data.dart';

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

  const CartItem({required this.product, required this.quantity});

  /// Create a copy with updated quantity
  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
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

  /// Add item to cart (increment if exists)
  void addItem(ProductModel product) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Product exists, increment quantity
      final updatedItems = [...state];
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      state = updatedItems;
    } else {
      // New product, add to cart
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  /// Remove item from cart completely
  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  /// Increment quantity by 1
  void incrementQuantity(String productId) {
    final updatedItems = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
    state = updatedItems;
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
      final updatedItems = state.map((item) {
        if (item.product.id == productId) {
          return item.copyWith(quantity: item.quantity - 1);
        }
        return item;
      }).toList();
      state = updatedItems;
    }
  }

  /// Clear all items from cart
  void clearCart() {
    state = [];
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
