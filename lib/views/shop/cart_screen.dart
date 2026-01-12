import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_scaffold.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../auth/login_modal.dart';
import '../../theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartController = CartController();

  @override
  void initState() {
    super.initState();
    _cartController.addListener(_rebuild);
  }

  @override
  void dispose() {
    _cartController.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = _cartController.items;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return AppScaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 80 : 24,
          vertical: 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Shopping Cart',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            
            if (items.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
                    const SizedBox(height: 24),
                    const Text('Your cart is empty', style: TextStyle(fontSize: 20, color: Colors.grey)),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CONTINUE SHOPPING'),
                    ),
                  ],
                ),
              )
            else
              Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // List of Items
                  Expanded(
                    flex: isDesktop ? 7 : 0,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const Divider(height: 40),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text(item.product.category, style: const TextStyle(color: Colors.black54)),
                                ],
                              ),
                            ),
                            
                            // Quantity Controls
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _cartController.updateQuantity(item.product.id, item.quantity - 1),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text('${item.quantity}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                IconButton(
                                  onPressed: () => _cartController.updateQuantity(item.product.id, item.quantity + 1),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                            
                            const SizedBox(width: 24),
                            Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            
                            const SizedBox(width: 24),
                            IconButton(
                              onPressed: () => _cartController.removeFromCart(item.product.id),
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  
                  if (isDesktop) const SizedBox(width: 60),
                  if (!isDesktop) const SizedBox(height: 60),

                  // Order Summary
                  Expanded(
                    flex: isDesktop ? 3 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Order Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 32),
                          _SummaryRow(label: 'Subtotal', value: '\$${_cartController.totalPrice.toStringAsFixed(2)}'),
                          const _SummaryRow(label: 'Shipping', value: 'FREE'),
                          const Divider(height: 40),
                          _SummaryRow(
                            label: 'Total',
                            value: '\$${_cartController.totalPrice.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (!AuthController().isLoggedIn) {
                                  _showLoginRequiredDialog(context);
                                  return;
                                }
                                context.push('/checkout');
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                backgroundColor: AppTheme.primaryColor,
                              ),
                              child: const Text('PROCEED TO CHECKOUT'),
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
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('Login Required', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Please sign in to your account to proceed with your order and enjoy a personalized shopping experience.',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('MAYBE LATER', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const LoginModal(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('LOG IN NOW', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? Colors.black : Colors.black54, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 16)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 24 : 16)),
        ],
      ),
    );
  }
}
