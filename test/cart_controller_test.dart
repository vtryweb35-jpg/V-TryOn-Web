import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_try_web/controllers/cart_controller.dart';
import 'package:virtual_try_web/models/product.dart';

void main() {
  group('CartController Tests', () {
    late CartController cartController;
    final testProduct = Product(
      id: '1',
      name: 'Test Product',
      price: 10.0,
      imageUrl: '/img.jpg',
      category: 'Cat',
      description: 'Desc',
    );

    setUp(() {
      cartController = CartController();
      cartController.clearCart();
    });

    test('Add item to cart increases count', () {
      cartController.addToCart(testProduct);
      expect(cartController.totalItems, 1);
      expect(cartController.totalPrice, 10.0);
    });

    test('Add same item twice increases quantity', () {
      cartController.addToCart(testProduct);
      cartController.addToCart(testProduct);
      expect(cartController.totalItems, 2);
      expect(cartController.items.length, 1);
      expect(cartController.totalPrice, 20.0);
    });

    test('Remove item from cart', () {
      cartController.addToCart(testProduct);
      cartController.removeFromCart('1');
      expect(cartController.totalItems, 0);
    });

    test('Update quantity', () {
      cartController.addToCart(testProduct);
      cartController.updateQuantity('1', 5);
      expect(cartController.totalItems, 5);
      expect(cartController.totalPrice, 50.0);
    });

    test('Setting quantity to 0 removes item', () {
      cartController.addToCart(testProduct);
      cartController.updateQuantity('1', 0);
      expect(cartController.items, isEmpty);
    });
  });
}
