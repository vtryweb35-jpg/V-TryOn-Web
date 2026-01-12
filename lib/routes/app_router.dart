import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../controllers/auth_controller.dart';
import '../views/landing/landing_screen.dart';
import '../views/shop/shop_screen.dart';
import '../views/product_detail/product_detail_screen.dart';
import '../views/try_on/try_on_screen.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/pricing/pricing_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/brand/brand_dashboard_screen.dart';
import '../views/content/about_screen.dart';
import '../views/content/contact_screen.dart';
import '../views/shop/cart_screen.dart';
import '../views/shop/checkout_screen.dart';
import '../views/shop/order_confirm_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/orders/orders_screen.dart';
import '../views/payment/test_payment_screen.dart';
import '../views/payment/payment_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final auth = AuthController();
      final isBrand = auth.isBrand;
      final isLoggingIn = state.uri.path == '/'; 
      
      // If brand user is trying to access landing/public pages, redirect to admin
      if (isBrand && (state.uri.path == '/' || state.uri.path == '/shop')) {
        return '/admin';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
      GoRoute(path: '/shop', builder: (context, state) => const ShopScreen()),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(
        path: '/order-confirm', 
        builder: (context, state) {
          final info = state.extra as Map<String, String>;
          return OrderConfirmScreen(shippingInfo: info);
        }
      ),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/try-on',
        builder: (context, state) {
          final product = state.extra as Product?;
          return TryOnScreen(product: product);
        },
      ),
      GoRoute(path: '/pricing', builder: (context, state) => const PricingScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/brand-dashboard', builder: (context, state) => const BrandDashboardScreen()),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(path: '/contact', builder: (context, state) => const ContactScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return PaymentScreen(
            amount: extras['amount'] as double,
            title: extras['title'] as String,
            description: extras['description'] as String,
          );
        },
      ),
      GoRoute(path: '/test-payment', builder: (context, state) => const TestPaymentScreen()),
    ],
  );
}
