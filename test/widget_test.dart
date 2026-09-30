import 'package:flutter_test/flutter_test.dart';
import 'package:whitematrix_app/controller/auth_controller.dart';
import 'package:whitematrix_app/controller/cart_controller.dart';
import 'package:whitematrix_app/controller/product_controller.dart';
import 'package:whitematrix_app/models/product.dart';
import 'package:whitematrix_app/service/product_service.dart';

class _FakeProductService extends ProductService {
  @override
  Future<List<String>> fetchCategories() async => ['beauty'];

  @override
  Future<PagedProducts> fetchProducts({
    int limit = 20,
    int skip = 0,
    String? category,
    String? query,
    String? sortBy,
    String? order,
  }) async =>
      PagedProducts([_product], 1);
}

final _product = Product(
  id: 1,
  title: 'Test product',
  description: 'A test product description',
  category: 'beauty',
  brand: 'TestBrand',
  price: 10,
  discountPercentage: 0,
  rating: 4.5,
  thumbnail: 'https://example.com/thumb.jpg',
  images: const [],
);

void main() {
  test('ProductController initialization loads categories and products', () async {
    final controller = ProductController(service: _FakeProductService());

    await controller.init();

    expect(controller.categories, ['all', 'beauty']);
    expect(controller.items, [_product]);
    expect(controller.total, 1);
    expect(controller.isLoading, isFalse);
    controller.dispose();
  });

  test('CartController adds items, updates quantities, and calculates totals correctly', () {
    final cart = CartController();

    // Initial state
    expect(cart.itemCount, 0);
    expect(cart.subtotal, 0.0);

    // Add 2 items
    cart.add(_product, quantity: 2);
    expect(cart.itemCount, 2);
    expect(cart.subtotal, 20.0);
    expect(cart.isInCart(_product.id), isTrue);

    // Add 1 more item
    cart.add(_product);
    expect(cart.itemCount, 3);
    expect(cart.subtotal, 30.0);

    // Set quantity explicitly
    cart.setQuantity(_product.id, 1);
    expect(cart.itemCount, 1);
    expect(cart.subtotal, 10.0);

    // Tax and delivery calculations
    expect(cart.deliveryFee, 5.0); // Subtotal <= 50 has $5 delivery fee
    expect(cart.tax, 0.5);         // 5% of 10.0 = 0.5
    expect(cart.total, 15.5);

    // Remove item
    cart.remove(_product.id);
    expect(cart.items, isEmpty);
    expect(cart.itemCount, 0);

    cart.dispose();
  });

  group('AuthController validation', () {
    test('accepts valid email and phone numbers', () {
      expect(AuthController.validateIdentifier('demo@shop.com'), isNull);
      expect(AuthController.validateIdentifier('saras@gmail.com'), isNull);
      expect(AuthController.validateIdentifier('9876543210'), isNull);
    });

    test('rejects empty or invalid identifiers', () {
      expect(AuthController.validateIdentifier(''), isNotNull);
      expect(AuthController.validateIdentifier('   '), isNotNull);
      expect(AuthController.validateIdentifier('notanemail'), isNotNull);
      expect(AuthController.validateIdentifier('12345'), isNotNull);
    });

    test('validates password minimum length requirement', () {
      expect(AuthController.validatePassword(''), isNotNull);
      expect(AuthController.validatePassword('12345'), isNotNull);
      expect(AuthController.validatePassword('Demo@123'), isNull);
      expect(AuthController.validatePassword('saras@123'), isNull);
    });
  });
}
