import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class TryOnService {
  static const String baseUrl = 'http://localhost:8000';

  static Future<Map<String, dynamic>> runTryOn({
    required Uint8List personImageBytes,
    required Uint8List clothImageBytes,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/try-on'));

      request.files.add(http.MultipartFile.fromBytes(
        'person_image',
        personImageBytes,
        filename: 'person.jpg',
      ));

      request.files.add(http.MultipartFile.fromBytes(
        'cloth_image',
        clothImageBytes,
        filename: 'cloth.jpg',
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
