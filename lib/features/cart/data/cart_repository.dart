import '../../../core/network/api_client.dart';

class CartRepository {
  const CartRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<int?> addItem({required String productId, int quantity = 1}) async {
    final response = await _apiClient.post<int?>(
      '/shop/carts/add',
      body: {'product_id': productId, 'quantity': quantity},
      fromData: (value) {
        if (value is! Map) return null;
        final item = value['item'];
        if (item is! Map) return null;
        return _intFromJson(item['rowId'] ?? item['row_id'] ?? item['id']);
      },
    );
    return response.data;
  }

  Future<void> updateQuantity({
    required int rowId,
    required int quantity,
  }) async {
    await _apiClient.post<void>(
      '/shop/carts/updateqty/$rowId',
      body: {'quantity': quantity},
      fromData: (_) {},
    );
  }

  Future<void> deleteItem(int rowId) async {
    await _apiClient.delete<void>(
      '/shop/carts/delete/$rowId',
      fromData: (_) {},
    );
  }

  Future<void> clearCart() async {
    await _apiClient.delete<void>('/shop/carts/destroy', fromData: (_) {});
  }

  int? _intFromJson(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
