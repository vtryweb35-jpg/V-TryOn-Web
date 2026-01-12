import 'package:flutter_stripe/flutter_stripe.dart';
import 'api_service.dart';

class StripeService {
  static Future<void> init() async {
    // Already initialized in main.dart, but good to have a placeholder
  }

  static Future<bool> makePayment({
    required double amount,
    required String currency,
    required String orderId,
  }) async {
    try {
      print('StripeService: Creating PaymentIntent for amount: $amount');
      // 1. Create PaymentIntent on backend
      final response = await ApiService.post('/payment/create-payment-intent', {
        'amount': amount,
        'currency': currency,
        'orderId': orderId,
      });

      print('StripeService: Backend response: $response');

      if (response == null || response['clientSecret'] == null) {
        throw Exception('Failed to get clientSecret from backend. Response: $response');
      }

      final String clientSecret = response['clientSecret'];
      print('StripeService: Received clientSecret');

      // 2. Confirm payment on Web
      // On Web, we must provide'data' to avoid assertion failures,
      // and it will pull the card details from the mounted CardField automatically.
      print('StripeService: Confirming payment...');
      
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      print('StripeService: Payment confirmation sent to Stripe');

      // 3. Confirm payment on backend to update order status
      print('StripeService: Updating order status on backend');
      await ApiService.post('/payment/confirm-payment', {
        'orderId': orderId,
        'paymentIntentId': clientSecret.contains('_secret') 
            ? clientSecret.split('_secret')[0] 
            : clientSecret,
      });

      print('StripeService: Payment flow complete');
      return true;
    } catch (e) {
      print('Stripe Error Details: $e');
      if (e is StripeException) {
          print('Stripe Specific Error: ${e.error.localizedMessage}');
      }
      rethrow;
    }
  }
}
