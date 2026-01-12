import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_scaffold.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../services/stripe_service.dart';

class OrderConfirmScreen extends StatefulWidget {
  final Map<String, String> shippingInfo;
  const OrderConfirmScreen({super.key, required this.shippingInfo});

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
  final _cart = CartController();
  final _orderController = OrderController();
  bool _isPlacingOrder = false;
  String _paymentMethod = 'Cash on Delivery';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return AppScaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 80 : 24,
            vertical: 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Confirmation',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Customer Details'),
                        const SizedBox(height: 16),
                        Text('Name: ${widget.shippingInfo['name']}', style: const TextStyle(fontSize: 18)),
                        Text('Email: ${widget.shippingInfo['email']}', style: const TextStyle(fontSize: 18)),
                        Text('Phone: ${widget.shippingInfo['phone']}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Shipping Address'),
                        const SizedBox(height: 16),
                        Text('${widget.shippingInfo['address']}', style: const TextStyle(fontSize: 18)),
                        Text('${widget.shippingInfo['city']}, ${widget.shippingInfo['postalCode']}', style: const TextStyle(fontSize: 18)),
                        _buildSectionTitle('Payment Method'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildPaymentOption('Cash on Delivery', Icons.payments_outlined),
                            const SizedBox(width: 24),
                            _buildPaymentOption('Card Payment', Icons.credit_card_outlined),
                          ],
                        ),
                        if (_paymentMethod == 'Card Payment') ...[
                          const SizedBox(height: 24),
                          const Text('Enter Card Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                            ),
                            child: const SizedBox(
                              height: 50,
                              child: CardField(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 40),
                        _buildSectionTitle('Order Items'),
                        const SizedBox(height: 16),
                        ..._cart.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(child: Text(item.product.name)),
                              Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Subtotal', '\$${_cart.totalPrice.toStringAsFixed(2)}'),
                          _buildSummaryRow('Shipping', 'FREE'),
                          const Divider(height: 40),
                          _buildSummaryRow('Total', '\$${_cart.totalPrice.toStringAsFixed(2)}', isTotal: true),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isPlacingOrder ? null : _placeOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isPlacingOrder 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('PLACE ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String label, IconData icon) {
    bool isSelected = _paymentMethod == label;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primaryColor : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor));
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? 22 : 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    setState(() => _isPlacingOrder = true);
    try {
      final orderItems = _cart.items.map((i) => OrderItem(
        name: i.product.name,
        qty: i.quantity,
        image: i.product.imageUrl,
        price: i.product.price,
        product: i.product.id,
      )).toList();

      final order = await _orderController.placeOrder(
        items: orderItems,
        shippingAddress: widget.shippingInfo,
        paymentMethod: _paymentMethod,
        totalPrice: _cart.totalPrice,
      );

      // Trigger Stripe if Card Payment is selected
      if (_paymentMethod == 'Card Payment') {
        final paymentSuccess = await StripeService.makePayment(
          amount: _cart.totalPrice,
          currency: 'usd',
          orderId: order.id,
        );

        if (!paymentSuccess) {
           throw Exception('Payment was not completed successfully.');
        }
      }

      _cart.clearCart();
      if (mounted) {
        AppSnackbar.show(
          context,
          message: _paymentMethod == 'Card Payment' 
              ? 'Payment Successful! Order placed.' 
              : 'Order placed successfully!',
          isError: false,
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error placing order: $e';
        
        if (e is StripeException) {
          // Check for specific Stripe failures or just use the updated message
          if (e.error.code == FailureCode.Failed) {
             errorMessage = 'Please enter valid card details.';
          } else {
             errorMessage = e.error.localizedMessage ?? e.error.message ?? 'Payment failed. Please check your card details.';
          }
        } else if (e.toString().contains('Payment')) {
           // Provide a cleaner fallback for generic payment exceptions
           errorMessage = 'Payment failed. Please verify your card details.';
        } else if (e.toString().contains('Exception:')) {
           // Clean up standard exceptions
           errorMessage = e.toString().split('Exception:')[1].trim();
        }

        AppSnackbar.show(
          context,
          message: errorMessage,
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }
}
