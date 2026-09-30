import 'package:flutter/foundation.dart';
import 'package:whitematrix_app/models/product.dart';

/// Represents a single product entry in the shopping cart with its quantity
class CartEntry {
  final Product product;
  final int quantity;

  const CartEntry({required this.product, required this.quantity});
}

/// Controller responsible for managing cart state, quantities, and totals
class CartController extends ChangeNotifier {
  final Map<int, CartEntry> _entries = {};

  List<CartEntry> get items => List.unmodifiable(_entries.values);

  /// Total number of items in the cart
  int get itemCount =>
      _entries.values.fold(0, (sum, entry) => sum + entry.quantity);

  /// Cart subtotal (calculated based on discounted prices)
  double get subtotal => _entries.values.fold(
        0.0,
        (sum, entry) => sum + (entry.product.discountedPrice * entry.quantity),
      );

  /// Free delivery above $50, otherwise $5.00
  double get deliveryFee => (subtotal > 50 || subtotal == 0) ? 0.0 : 5.0;

  /// Estimated tax (5%)
  double get tax => subtotal * 0.05;

  /// Grand total
  double get total => subtotal + deliveryFee + tax;

  /// Check if a product is already in the cart
  bool isInCart(int productId) => _entries.containsKey(productId);

  /// Add a product to cart (or increment quantity if already added)
  void add(Product product, {int quantity = 1}) {
    final current = _entries[product.id];
    _entries[product.id] = CartEntry(
      product: product,
      quantity: (current?.quantity ?? 0) + quantity,
    );
    notifyListeners();
  }

  /// Update the quantity of a specific product
  void setQuantity(int productId, int quantity) {
    final current = _entries[productId];
    if (current == null) return;

    if (quantity < 1) {
      _entries.remove(productId);
    } else {
      _entries[productId] = CartEntry(
        product: current.product,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  /// Remove a product entirely from the cart
  void remove(int productId) {
    if (_entries.remove(productId) != null) {
      notifyListeners();
    }
  }

  /// Clear all cart items (called after successful checkout)
  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
