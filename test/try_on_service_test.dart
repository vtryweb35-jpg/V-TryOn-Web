import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_try_web/services/try_on_service.dart';

void main() {
  group('TryOnService Tests', () {
    test('runTryOn throws exception on network error', () async {
      final personBytes = Uint8List(0);
      final clothBytes = Uint8List(0);

      expect(
        () => TryOnService.runTryOn(
          personImageBytes: personBytes,
          clothImageBytes: clothBytes,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
