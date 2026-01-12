import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../services/stripe_service.dart';
import '../../utils/app_snackbar.dart';

class TestPaymentScreen extends StatefulWidget {
  const TestPaymentScreen({super.key});

  @override
  State<TestPaymentScreen> createState() => _TestPaymentScreenState();
}

class _TestPaymentScreenState extends State<TestPaymentScreen> {
  final _amountController = TextEditingController(text: '10');
  final _orderIdController = TextEditingController(text: 'ORDER123');
  bool _isLoading = false;

  Future<void> _handlePayment() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      AppSnackbar.show(context, message: 'Please enter a valid amount', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await StripeService.makePayment(
        amount: amount,
        currency: 'usd',
        orderId: _orderIdController.text,
      );

      if (success) {
        if (mounted) {
          AppSnackbar.show(context, message: 'Payment Successful!', isError: false);
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, message: 'Payment Failed: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stripe Test Payment')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Stripe Web Testing',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (USD)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _orderIdController,
              decoration: const InputDecoration(
                labelText: 'Order ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Card Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: const SizedBox(
                height: 50,
                child: CardField(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pay with Stripe', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Use Stripe test cards (4242...) to complete the transaction.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
