import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';

class OrderController extends ChangeNotifier {
  static final OrderController _instance = OrderController._internal();
  factory OrderController() => _instance;
  OrderController._internal();

  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchMyOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> data = await ApiService.get('/orders/myorders');
      _orders = data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching my orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> data = await ApiService.get('/orders');
      _orders = data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching all orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order> placeOrder({
    required List<OrderItem> items,
    required Map<String, String> shippingAddress,
    required String paymentMethod,
    required double totalPrice,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.post('/orders', {
        'orderItems': items.map((i) => i.toJson()).toList(),
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'itemsPrice': totalPrice,
        'taxPrice': 0.0,
        'shippingPrice': 0.0,
        'totalPrice': totalPrice,
      });
      final newOrder = Order.fromJson(data);
      _orders.insert(0, newOrder);
      return newOrder;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    try {
      final data = await ApiService.put('/orders/$id/status', {
        'status': status,
      });
      final updatedOrder = Order.fromJson(data);
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      await ApiService.delete('/orders/$id');
      _orders.removeWhere((o) => o.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearOrders() async {
    try {
      await ApiService.delete('/orders/myorders');
      // Instead of clearing all, re-fetch to get the updated list (minus cleared ones)
      await fetchMyOrders();
    } catch (e) {
      rethrow;
    }
  }
}
