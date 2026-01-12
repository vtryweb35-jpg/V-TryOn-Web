import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../controllers/auth_controller.dart';

class CartController extends ChangeNotifier {
  static final CartController _instance = CartController._internal();
  factory CartController() => _instance;
  CartController._internal() {
    _loadCart();
  }

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = AuthController().userId ?? 'guest';
    final String? cartJson = prefs.getString('cart_items_$userId');
    
    _items.clear();
    if (cartJson != null) {
      final List<dynamic> decodedList = json.decode(cartJson);
      _items.addAll(decodedList.map((item) => CartItem.fromJson(item)).toList());
    }
    notifyListeners();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = AuthController().userId ?? 'guest';
    final String cartJson = json.encode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('cart_items_$userId', cartJson);
  }

  Future<void> reset() async {
    await _loadCart();
  }

  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }
}
