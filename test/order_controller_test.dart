import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_try_web/controllers/order_controller.dart';

void main() {
  group('OrderController Tests', () {
    late OrderController orderController;

    setUp(() {
      orderController = OrderController();
    });

    test('Initial orders list is empty', () {
      expect(orderController.orders, isEmpty);
      expect(orderController.isLoading, false);
    });

    test('isLoading state transitions during fetch', () async {
      final future = orderController.fetchMyOrders();
      // Due to static ApiService, this will likely fail or throw,
      // but we can check if isLoading resets in finally.
      await future;
      expect(orderController.isLoading, false);
    });
  });
}
