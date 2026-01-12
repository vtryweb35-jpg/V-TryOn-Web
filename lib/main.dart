import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:virtual_try_web/controllers/auth_controller.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  Stripe.publishableKey = "pk_test_51SkdSX8Sd0JMjmXe0vBvrJ22oCdqEvgnqcBDpXefqZ0gyKBs7o5UrTCl3oA59b4D8v1054zuSI0nXltC3E0xFDbC00ECxNPAtv";
  
  // Initialize AuthController and check for cached session
  final authController = AuthController();
  await authController.checkLoginStatus();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Virtual Try-On',
      theme: AppTheme.lightTheme,
      
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

