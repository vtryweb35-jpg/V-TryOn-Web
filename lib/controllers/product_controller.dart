import 'package:flutter/material.dart';
// import 'dart:io';
import '../services/api_service.dart';
import '../models/product.dart';

class ProductController extends ChangeNotifier {
  static final ProductController _instance = ProductController._internal();
  factory ProductController() => _instance;
  ProductController._internal();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  bool _isFiltering = false;

  List<Product> get products => _isFiltering ? _filteredProducts : _products;
  bool get isLoading => _isLoading;

  List<String> get categories {
    final Set<String> uniqueCategories = {};
    for (var p in _products) {
      uniqueCategories.add(_normalizeCategory(p.category));
    }
    return ['All', ...uniqueCategories.toList()..sort()];
  }

  String _normalizeCategory(String category) {
    if (category.isEmpty) return 'Other';
    final trimmed = category.trim();
    if (trimmed.toLowerCase() == 'tshirt' || trimmed.toLowerCase() == 't-shirt') {
      return 'T-Shirt';
    }
    // Simple title case implementation
    if (trimmed.length <= 1) return trimmed.toUpperCase();
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1).toLowerCase()}';
  }

  void filterProducts(String query, String category) {
    if (query.isEmpty && (category == 'All' || category.isEmpty)) {
      _isFiltering = false;
      _filteredProducts = [];
    } else {
      _isFiltering = true;
      _filteredProducts = _products.where((product) {
        final matchesQuery = product.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = category == 'All' || category.isEmpty || _normalizeCategory(product.category) == category;
        return matchesQuery && matchesCategory;
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchAllProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> data = await ApiService.get('/products');
      _products = data.map((json) => Product.fromJson(json)).toList();
      _filteredProducts = [];
      _isFiltering = false;
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> data = await ApiService.get('/products/myproducts');
      _products = data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching my products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product, dynamic imageFile) async {
    try {
      if (imageFile != null) {
        final data = await ApiService.upload(
          '/products', 
          imageFile, 
          'image',
          fields: {
            'name': product.name,
            'price': product.price.toString(),
            'category': product.category,
            'description': product.description,
            'brand': product.brand ?? '',
            'countInStock': '10', // Default stock
          }
        );
         _products.insert(0, Product.fromJson(data));
      } else {
         final data = await ApiService.post('/products', {
            'name': product.name,
            'price': product.price,
            'category': product.category,
            'description': product.description,
            'brand': product.brand,
            'image': product.imageUrl,
         });
         _products.insert(0, Product.fromJson(data));
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(Product updatedProduct, dynamic imageFile) async {
    try {
      final String endpoint = '/products/${updatedProduct.id}';
      late dynamic data;

      if (imageFile != null) {
        data = await ApiService.upload(
          endpoint,
          imageFile,
          'image',
          method: 'PUT',
          fields: {
            'name': updatedProduct.name,
            'price': updatedProduct.price.toString(),
            'category': updatedProduct.category,
            'description': updatedProduct.description,
            'brand': updatedProduct.brand ?? '',
          },
        );
      } else {
        data = await ApiService.put(endpoint, {
          'name': updatedProduct.name,
          'price': updatedProduct.price,
          'category': updatedProduct.category,
          'description': updatedProduct.description,
          'brand': updatedProduct.brand,
        });
      }

      final product = Product.fromJson(data);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await ApiService.delete('/products/$id');
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
