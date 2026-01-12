import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';

enum UserRole { customer, brand, guest }

class AuthController extends ChangeNotifier {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  UserRole _role = UserRole.guest;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _profilePic;
  String? _phone;
  String? _address;

  UserRole get role => _role;
  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get profilePic => _profilePic;
  String? get phone => _phone;
  String? get address => _address;
  bool get isBrand => _role == UserRole.brand;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token != null) {
      _isLoggedIn = true;
      final roleStr = prefs.getString('user_role');
      _role = roleStr == 'brand' ? UserRole.brand : UserRole.customer;
      _userId = prefs.getString('user_id');
      _userName = prefs.getString('user_name');
      _userEmail = prefs.getString('user_email');
      _profilePic = prefs.getString('user_profile_pic');
      _phone = prefs.getString('user_phone');
      _address = prefs.getString('user_address');
      
      ApiService.setToken(token);
      
      // Load user-specific data
      await CartController().reset();
      await WishlistController().reset();
      notifyListeners();
    } else {
      await CartController().reset();
      await WishlistController().reset();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      await _setUserData(data);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'role': role == UserRole.brand ? 'admin' : 'user',
      });

      await _setUserData(data);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      final data = await ApiService.put('/auth/profile', {
        'name': name,
        'phone': phone,
        'address': address,
      });

      // Update stored data as well
      final prefs = await SharedPreferences.getInstance();
      if (name != null) await prefs.setString('user_name', name);
      if (phone != null) await prefs.setString('user_phone', phone);
      if (address != null) await prefs.setString('user_address', address);

      _userName = data['name'];
      _phone = data['phone'];
      _address = data['address'];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadProfileImage(dynamic file) async {
    try {
      final data = await ApiService.upload('/auth/upload-profile', file, 'profilePic');
      _profilePic = data['profilePic'];
      
      final prefs = await SharedPreferences.getInstance();
      if (_profilePic != null) await prefs.setString('user_profile_pic', _profilePic!);
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }


  Future<void> _setUserData(Map<String, dynamic> data) async {
    _isLoggedIn = true;
    _role = data['role'] == 'admin' || data['role'] == 'brand' ? UserRole.brand : UserRole.customer;
    _userId = data['_id']; 
    _userName = data['name'];
    _userEmail = data['email'];
    _profilePic = data['profilePic'];
    _phone = data['phone'];
    _address = data['address'];
    
    final token = data['token'];
    if (token != null) {
      ApiService.setToken(token);
    }

    final prefs = await SharedPreferences.getInstance();
    if (token != null) await prefs.setString('token', token);
    await prefs.setString('user_role', isBrand ? 'brand' : 'customer');
    if (_userId != null) await prefs.setString('user_id', _userId!);
    if (_userName != null) await prefs.setString('user_name', _userName!);
    if (_userEmail != null) await prefs.setString('user_email', _userEmail!);
    if (_profilePic != null) await prefs.setString('user_profile_pic', _profilePic!);
    if (_phone != null) await prefs.setString('user_phone', _phone!);
    if (_address != null) await prefs.setString('user_address', _address!);

    // Reset controllers for new user
    await CartController().reset();
    await WishlistController().reset();

    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _role = UserRole.guest;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _profilePic = null;
    _phone = null;
    _address = null;
    ApiService.setToken(null);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Reset controllers for guest
    await CartController().reset();
    await WishlistController().reset();
    
    notifyListeners();
  }
}
