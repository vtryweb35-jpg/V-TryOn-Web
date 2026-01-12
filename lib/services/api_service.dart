import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to access localhost
  // Use http://localhost:5000 for iOS simulator or web
  static const String baseUrl = 'http://localhost:5000/api'; 
  
  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Refactored upload to be more flexible (doesn't require dart:io File)
  static Future<dynamic> upload(String endpoint, dynamic file, String fieldName, {Map<String, String>? fields, String method = 'POST'}) async {
    var request = http.MultipartRequest(method, Uri.parse('$baseUrl$endpoint'));
    
    // Add headers
    _headers.forEach((key, value) {
        if (key != 'Content-Type') {
           request.headers[key] = value;
        }
    });

    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Handle File (non-web) vs Bytes (web)
    if (file is String) {
      // Assuming it's a file path
      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        file,
        contentType: MediaType('image', 'jpeg'), 
      ));
    } else if (file is List<int>) {
      // Assuming it's bytes (for web)
      request.files.add(http.MultipartFile.fromBytes(
        fieldName,
        file,
        filename: 'upload.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    } else {
      throw Exception('Unsupported file type for upload');
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      try {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Error occurred');
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Server error: ${response.statusCode}');
      }
    }
  }
}
