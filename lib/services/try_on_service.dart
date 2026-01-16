import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class TryOnService {
  static String get baseUrl => ApiService.baseUrl;

  static Future<Map<String, dynamic>> runTryOn({
    required Uint8List personImageBytes,
    required Uint8List clothImageBytes,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/try-on'));

      request.files.add(http.MultipartFile.fromBytes(
        'person',
        personImageBytes,
        filename: 'person.jpg',
      ));

      request.files.add(http.MultipartFile.fromBytes(
        'cloth',
        clothImageBytes,
        filename: 'cloth.jpg',
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'The AI try-on service is currently unavailable. Please try again later.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
