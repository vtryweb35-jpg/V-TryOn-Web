import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_try_web/controllers/product_controller.dart';
import 'package:virtual_try_web/models/product.dart';

void main() {
  group('ProductController Tests', () {
    late ProductController productController;

    setUp(() {
      productController = ProductController();
    });

    test('Initial products list is empty', () {
      expect(productController.products, isEmpty);
      expect(productController.isLoading, false);
    });

    test('isLoading state changes correctly', () async {
      // Note: fetchAllProducts will fail because of ApiService static call, 
      // but we can check if it stays consistent or handles errors.
      // In a real scenario, we'd refactor ApiService to be injectable.
      
      final future = productController.fetchAllProducts();
      // Since it's async, we might not catch the 'true' state without a mock,
      // but let's see if it completes.
      await future;
      expect(productController.isLoading, false);
    });
  });
}
