import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_try_web/controllers/auth_controller.dart';
import 'package:virtual_try_web/services/api_service.dart';

// We will mock SharedPreferences and ApiService calls if possible
// However, ApiService has static methods, which are hard to mock in Dart/Mockito without refactoring.
// For now, we will focus on what we CAN test easily or mock SharedPreferences.

@GenerateMocks([SharedPreferences])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthController Tests', () {
    late AuthController authController;

    setUp(() {
      authController = AuthController();
    });

    test('Initial state is guest and not logged in', () {
      expect(authController.isLoggedIn, false);
      expect(authController.role, UserRole.guest);
    });

    test('logout clears the state', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'some_token',
        'user_role': 'customer',
      });
      
      await authController.checkLoginStatus();
      expect(authController.isLoggedIn, true);

      await authController.logout();
      
      expect(authController.isLoggedIn, false);
      expect(authController.role, UserRole.guest);
      expect(authController.userName, isNull);
    });
  });
}
