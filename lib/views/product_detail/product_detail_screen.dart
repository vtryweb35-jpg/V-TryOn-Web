import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_scaffold.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../auth/login_modal.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedSize = 'M';

  void _showSizeChart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Size Chart'),
        content: SingleChildScrollView(
          child: Table(
            border: TableBorder.all(color: Colors.black12),
            children: [
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Size',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Chest (in)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Waist (in)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ...['S', 'M', 'L', 'XL'].map(
                (s) => TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text(s)),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        s == 'S'
                            ? '36'
                            : s == 'M'
                            ? '38'
                            : s == 'L'
                            ? '40'
                            : '42',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        s == 'S'
                            ? '30'
                            : s == 'M'
                            ? '32'
                            : s == 'L'
                            ? '34'
                            : '36',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = ProductController().products;

    if (allProducts.isEmpty) {
      // If we navigate directly or refresh, we might need to fetch
      ProductController().fetchAllProducts();
      return const AppScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final product = allProducts.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => allProducts.first, // Fallback
    );
    final isDesktop = MediaQuery.of(context).size.width > 900;

    // Similar Products (excluding current)
    final similarProducts = allProducts
        .where((p) => p.id != widget.productId)
        .take(8)
        .toList();

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 24,
                vertical: 60,
              ),
              child: Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... Product Image (unchanged)
                  Expanded(
                    flex: isDesktop ? 6 : 0,
                    child: Container(
                      height: 500,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.shopping_bag,
                              color: Colors.grey[400],
                              size: 100,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (isDesktop) const SizedBox(width: 60),
                  if (!isDesktop) const SizedBox(height: 40),

                  // Product Info
                  Expanded(
                    flex: isDesktop ? 4 : 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        // ... name, price, description (unchanged)
                        const SizedBox(height: 16),
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Size Selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Select Size',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: _showSizeChart,
                              child: const Text(
                                'Size Chart',
                                style: TextStyle(color: AppTheme.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: ['S', 'M', 'L', 'XL'].map((size) {
                            final isSelected = selectedSize == size;
                            return GestureDetector(
                              onTap: () => setState(() => selectedSize = size),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    size,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (!AuthController().isLoggedIn) {
                                _showLoginRequiredDialog(context, 'virtual try-on');
                                return;
                              }
                              context.go('/try-on', extra: product);
                            },
                            icon: const Icon(Icons.accessibility_new, size: 24),
                            label: const Text('VIRTUAL TRY-ON'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              if (!AuthController().isLoggedIn) {
                                _showLoginRequiredDialog(context, 'add items to cart');
                                return;
                              }
                              CartController().addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} (Size $selectedSize) added to cart!',
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                            ),
                            child: const Text('ADD TO CART'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Similar Products Section
            if (similarProducts.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 80 : 24,
                  vertical: 80,
                ),
                color: Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Similar Products',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 400,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: similarProducts.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 24),
                            child: ProductCard(product: similarProducts[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.account_circle_outlined, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text('Sign In Required', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'To $action, please sign in to your account. It only takes a minute!',
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
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
            child: const Text('GO TO LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
