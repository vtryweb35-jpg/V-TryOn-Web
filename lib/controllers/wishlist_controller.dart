import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../controllers/auth_controller.dart';

class WishlistController extends ChangeNotifier {
  static final WishlistController _instance = WishlistController._internal();
  factory WishlistController() => _instance;
  
  WishlistController._internal() {
    _loadWishlist();
  }

  final List<Product> _items = [];
  List<Product> get items => List.unmodifiable(_items);

  bool isWishlisted(String productId) {
    return _items.any((item) => item.id == productId);
  }

  void toggleWishlist(Product product) {
    if (isWishlisted(product.id)) {
      _items.removeWhere((item) => item.id == product.id);
    } else {
      _items.add(product);
    }
    _saveWishlist();
    notifyListeners();
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = AuthController().userId ?? 'guest';
    final String? wishlistJson = prefs.getString('wishlist_items_$userId');
    
    _items.clear();
    if (wishlistJson != null) {
      final List<dynamic> decodedList = json.decode(wishlistJson);
      _items.addAll(decodedList.map((item) => Product.fromJson(item)).toList());
    }
    notifyListeners();
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = AuthController().userId ?? 'guest';
    final String wishlistJson = json.encode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('wishlist_items_$userId', wishlistJson);
  }

  Future<void> reset() async {
    await _loadWishlist();
  }
}
