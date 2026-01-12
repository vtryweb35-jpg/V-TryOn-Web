import 'package:flutter/material.dart';
import '../../utils/app_snackbar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virtual_try_web/controllers/auth_controller.dart';
import 'package:virtual_try_web/services/api_service.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../controllers/product_controller.dart';
import '../../controllers/order_controller.dart';
import '../../models/product.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminActivity {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  AdminActivity({required this.label, required this.time, required this.icon, required this.color});

  factory AdminActivity.fromJson(Map<String, dynamic> json) {
    return AdminActivity(
      label: json['label'] ?? 'Unknown Activity',
      icon: _getIconData(json['icon']),
      color: _parseColor(json['color']),
      time: _formatTime(_parseDate(json['createdAt'])),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blue;
    try {
      final cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  static IconData _getIconData(String name) {
    switch (name) {
      case 'shopping_basket': return Icons.shopping_basket_rounded;
      case 'add_business': return Icons.add_business_rounded;
      case 'edit': return Icons.edit_rounded;
      case 'delete': return Icons.delete_outline;
      case 'info': return Icons.info_outline;
      case 'auto_awesome': return Icons.auto_awesome_rounded;
      default: return Icons.notifications_none_rounded;
    }
  }

  static String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM dd').format(date);
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Order> _orders = [];
  String _activeSection = 'Dashboard';
  Timer? _orderTimer;
  int _prevOrderCount = 0;
  List<AdminActivity> _activities = [];
  Map<String, dynamic>? _analytics;
  bool _isLoadingAnalytics = false;

  @override
  void initState() {
    super.initState();
    ProductController().fetchMyProducts();
    _fetchOrders();
    _fetchActivities();
    _fetchAnalytics();
    _startOrderPolling();
  }

  @override
  void dispose() {
    _orderTimer?.cancel();
    super.dispose();
  }

  void _startOrderPolling() {
    _orderTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchOrders(isPolling: true);
    });
  }

  String _getShortId(String id) {
    if (id.length <= 6) return id.toUpperCase();
    return id.substring(id.length - 6).toUpperCase();
  }

  Future<void> _fetchOrders({bool isPolling = false}) async {
    final orderCtrl = OrderController();
    await orderCtrl.fetchAllOrders();
    if (mounted) {
      if (isPolling && orderCtrl.orders.length > _prevOrderCount && _prevOrderCount != 0) {
        _showNewOrderNotification();
        final newOrder = orderCtrl.orders.first;
        _addActivity(
          label: 'New order #${_getShortId(newOrder.id)}',
          icon: Icons.shopping_basket_rounded,
          color: Colors.green,
        );
      }
      
      setState(() {
        _orders = orderCtrl.orders;
      });
      _prevOrderCount = _orders.length;
    }
  }

  void _addActivity({required String label, required IconData icon, required Color color}) async {
    final iconName = _getIconName(icon);
    final colorHex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    
    try {
      final data = await ApiService.post('/activities', {
        'label': label,
        'icon': iconName,
        'color': colorHex,
      });
      setState(() {
        _activities.insert(0, AdminActivity.fromJson(data));
        // Remove bottom if too many (UI constraint hint)
        if (_activities.length > 15) _activities.removeLast();
      });
    } catch (e) {
      debugPrint('Error logging activity: $e');
    }
  }

  Future<void> _fetchAnalytics() async {
    if (mounted) setState(() => _isLoadingAnalytics = true);
    try {
      final data = await ApiService.get('/analytics');
      if (mounted) {
        setState(() {
          _analytics = data;
          _isLoadingAnalytics = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching analytics: $e');
      if (mounted) setState(() => _isLoadingAnalytics = false);
    }
  }

  Future<void> _fetchActivities() async {
    try {
      final List<dynamic> data = await ApiService.get('/activities');
      if (mounted) {
        setState(() {
          _activities = data.map((json) => AdminActivity.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching activities: $e');
    }
  }

  void _confirmDeleteOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order?'),
        content: Text('Are you sure you want to delete order #${_getShortId(order.id)}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await OrderController().deleteOrder(order.id);
                _fetchOrders();
                _addActivity(
                  label: 'Deleted order #${_getShortId(order.id)}', 
                  icon: Icons.delete_outline, 
                  color: Colors.red
                );
                if (mounted) {
                   AppSnackbar.show(context, message: 'Order deleted', isError: false);
                }
              } catch (e) {
                if (mounted) {
                  AppSnackbar.show(context, message: 'Delete failed: $e', isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.shopping_basket_rounded) return 'shopping_basket';
    if (icon == Icons.add_business_rounded) return 'add_business';
    if (icon == Icons.edit_rounded) return 'edit';
    if (icon == Icons.delete_outline) return 'delete';
    if (icon == Icons.info_outline) return 'info';
    if (icon == Icons.auto_awesome_rounded) return 'auto_awesome';
    return 'bell';
  }

  void _showNewOrderNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.shopping_bag, color: Colors.white),
            SizedBox(width: 12),
            Text('NEW ORDER RECEIVED!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () => setState(() => _activeSection = 'Orders'),
        ),
      ),
    );
  }

  void _refresh() {
    ProductController().fetchMyProducts();
    _fetchActivities();
    _fetchAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          Hero(
                            tag: 'admin_logo',
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.bolt, color: AppTheme.primaryColor, size: 40),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'BRAND PORTAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 50),
                          _SidebarItem(
                            icon: Icons.dashboard_rounded, 
                            label: 'Overview', 
                            isActive: _activeSection == 'Dashboard',
                            onTap: () => setState(() => _activeSection = 'Dashboard'),
                          ),
                          _SidebarItem(
                            icon: Icons.inventory_2_rounded, 
                            label: 'Inventory', 
                            isActive: _activeSection == 'Products',
                            onTap: () => setState(() => _activeSection = 'Products'),
                          ),
                          _SidebarItem(
                            icon: Icons.shopping_basket_rounded, 
                            label: 'Orders', 
                            isActive: _activeSection == 'Orders',
                            onTap: () => setState(() => _activeSection = 'Orders'),
                          ),
                          _SidebarItem(
                            icon: Icons.analytics_rounded, 
                            label: 'Analytics', 
                            isActive: _activeSection == 'Users',
                            onTap: () => setState(() => _activeSection = 'Users'),
                          ),
                          _SidebarItem(
                            icon: Icons.settings_suggest_rounded, 
                            label: 'Preferences', 
                            isActive: _activeSection == 'Settings',
                            onTap: () => setState(() => _activeSection = 'Settings'),
                          ),
                          const Spacer(),
                          const Divider(color: Colors.white10),
                          _SidebarItem(
                            icon: Icons.logout_rounded, 
                            label: 'Log Out', 
                            onTap: () {
                              AuthController().logout();
                              context.go('/');
                            },
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Main Content
          Expanded(
            child: ListenableBuilder(
              listenable: ProductController(),
              builder: (context, _) {
                final productController = ProductController();
                if (productController.isLoading && productController.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildContent(),
                    ],
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Brand Admin',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            Text(
              _activeSection == 'Dashboard' ? 'Business Overview' : _activeSection,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            ),
          ],
        ),
        if (_activeSection == 'Products')
          ElevatedButton.icon(
            onPressed: () => _showProductDialog(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('NEW PRODUCT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_activeSection) {
      case 'Dashboard': return _buildDashboard();
      case 'Products': return _buildProductsTable();
      case 'Orders': return _buildOrdersTable();
      case 'Users': return _buildUsersTable();
      case 'Settings': return _buildSettings();
      default: return const SizedBox();
    }
  }

  Widget _buildDashboard() {
    // Top Stats
    final totalRevenue = _orders
        .where((o) => o.isPaid || o.status == 'Accepted' || o.status == 'Delivered')
        .fold(0.0, (sum, o) => sum + o.totalPrice);

    // Calculate Trend Data (Last 7 Days)
    final now = DateTime.now();
    final List<FlSpot> trendSpots = [];
    double maxDayRevenue = 100; // Seed with a minimum height for chart
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayRevenue = _orders
          .where((o) => (o.isPaid || o.status == 'Accepted' || o.status == 'Delivered') &&
              o.createdAt.year == date.year &&
              o.createdAt.month == date.month &&
              o.createdAt.day == date.day)
          .fold(0.0, (sum, o) => sum + o.totalPrice);
      
      if (dayRevenue > maxDayRevenue) maxDayRevenue = dayRevenue;
      trendSpots.add(FlSpot((6 - i).toDouble(), dayRevenue));
    }
    
    return Column(
          children: [
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Inventory Count', value: '${ProductController().products.length} Items', icon: Icons.inventory_2_rounded, color: Colors.indigo)),
                const SizedBox(width: 24),
                Expanded(child: _StatCard(label: 'Total Revenue', value: '\$${totalRevenue.toStringAsFixed(2)}', icon: Icons.payments_rounded, color: const Color(0xFF10B981))),
                const SizedBox(width: 24),
                Expanded(child: _StatCard(label: 'Active Campaigns', value: '4 Live', icon: Icons.campaign_rounded, color: Colors.orangeAccent)),
              ],
            ),
        const SizedBox(height: 24),
        // Charts and Recent Activity
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line Chart - Sales Trend
            Expanded(
              flex: 2,
              child: _ChartBox(
                title: 'Revenue Trend (7 Days)',
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    maxY: maxDayRevenue * 1.2,
                    lineBarsData: [
                      LineChartBarData(
                        spots: trendSpots,
                        isCurved: true,
                        color: AppTheme.primaryColor,
                        barWidth: 6,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Recent Activity
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                height: 450,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recent Store Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    _activities.isEmpty
                      ? Expanded(child: Center(child: Text('No recent activity', style: TextStyle(color: Colors.grey[400]))))
                      : Expanded(
                      child: ListView.builder(
                        itemCount: _activities.length,
                        itemBuilder: (context, index) {
                          final act = _activities[index];
                          return _ActivityItem(icon: act.icon, color: act.color, label: act.label, time: act.time);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductsTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          columns: const [
            DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: ProductController().products.map((product) => DataRow(
            cells: [
              DataCell(Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(product.imageUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                  ),
                  const SizedBox(width: 12),
                  Text(product.name),
                ],
              )),
              DataCell(Text(product.category)),
              DataCell(Text('\$${product.price}')),
              DataCell(Row(
                children: [
                  IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showProductDialog(product: product)),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () async {
                    try {
                      await ProductController().deleteProduct(product.id);
                      _refresh();
                      _addActivity(label: 'Deleted product: ${product.name}', icon: Icons.delete_outline, color: Colors.red);
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                    }
                  }),
                ],
              )),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildOrdersTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _orders.isEmpty 
          ? const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No orders yet', style: TextStyle(fontSize: 18, color: Colors.grey))))
          : DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          columns: const [
            DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _orders.map((order) => DataRow(
            cells: [
              DataCell(Text('#${_getShortId(order.id)}')),
              DataCell(Text(order.userName ?? 'Guest')),
              DataCell(Text(DateFormat('MMM dd, yyyy').format(order.createdAt))),
              DataCell(Text('\$${order.totalPrice.toStringAsFixed(2)}')),
              DataCell(
                PopupMenuButton<String>(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: order.status == 'Delivered' ? Colors.green.withValues(alpha: 0.1) : (order.status == 'Accepted' ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.status,
                          style: TextStyle(
                            color: order.status == 'Delivered' ? Colors.green[700] : (order.status == 'Accepted' ? Colors.blue[700] : Colors.orange[700]),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                  onSelected: (status) async {
                    try {
                      await OrderController().updateOrderStatus(order.id, status);
                      _fetchOrders();
                      _addActivity(label: 'Order #${order.id.substring(order.id.length - 6).toUpperCase()} is $status', icon: Icons.info_outline, color: Colors.blue);
                    } catch (e) {
                      if (mounted) {
                        AppSnackbar.show(
                          context,
                          message: 'Failed: $e',
                          isError: true,
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Processing', child: Text('Processing')),
                    const PopupMenuItem(value: 'Accepted', child: Text('Accepted')),
                    const PopupMenuItem(value: 'Delivered', child: Text('Delivered')),
                  ],
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmDeleteOrder(order),
                ),
              ),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildUsersTable() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(
              label: 'Conversion Rate', 
              value: '${_analytics?['conversionRate'] ?? '0'}%', 
              icon: Icons.track_changes_rounded, 
              color: Colors.purple
            )),
            const SizedBox(width: 24),
            Expanded(child: _StatCard(
              label: 'Try-On Usage', 
              value: '${_analytics?['totalTryOns'] ?? '0'} Times', 
              icon: Icons.auto_awesome_rounded, 
              color: Colors.cyan
            )),
            const SizedBox(width: 24),
            Expanded(child: _StatCard(
              label: 'New Customers', 
              value: '${_analytics?['newCustomers'] ?? '0'}', 
              icon: Icons.person_add_rounded, 
              color: Colors.pink
            )),
          ],
        ),
        const SizedBox(height: 24),
        _ChartBox(
          title: 'Try-On Conversion vs Traditional Views',
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: AppTheme.primaryColor, width: 22)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.blue, width: 22)]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.purple, width: 22)]),
                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: Colors.orange, width: 22)]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    final auth = AuthController();
    final nameCtrl = TextEditingController(text: auth.userName);
    final phoneCtrl = TextEditingController(text: auth.phone);
    final addressCtrl = TextEditingController(text: auth.address);
    bool isSaving = false;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Brand Profile Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              Text('Update your store information visible to customers.', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 40),
              
              _SettingField(label: 'Admin Name', controller: nameCtrl, icon: Icons.person_outline),
              const SizedBox(height: 24),
              _SettingField(label: 'Phone Number', controller: phoneCtrl, icon: Icons.phone_outlined),
              const SizedBox(height: 24),
              _SettingField(label: 'Store Address', controller: addressCtrl, icon: Icons.location_on_outlined, maxLines: 2),
              
              const SizedBox(height: 48),
              SizedBox(
                width: 200,
                height: 54,
                child: ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    setLocalState(() => isSaving = true);
                    try {
                      await auth.updateProfile(
                        name: nameCtrl.text,
                        phone: phoneCtrl.text,
                        address: addressCtrl.text,
                      );
                      if (context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    } finally {
                      setLocalState(() => isSaving = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Update Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _showProductDialog({Product? product}) {
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(
        product: product,
        onSave: () {
          _refresh();
          if (product == null) {
            _addActivity(label: 'New product added', icon: Icons.add_business_rounded, color: Colors.blue);
          } else {
            _addActivity(label: 'Product updated', icon: Icons.edit_rounded, color: Colors.orange);
          }
        },
      ),
    );
  }
}

class _SettingField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;

  const _SettingField({
    required this.label, 
    required this.controller, 
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  final Product? product;
  final VoidCallback onSave;

  const _ProductFormDialog({this.product, required this.onSave});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _catCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _brandCtrl;
  dynamic _imageFile;
  final _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _priceCtrl = TextEditingController(text: widget.product?.price.toString() ?? '');
    _catCtrl = TextEditingController(text: widget.product?.category ?? '');
    _descCtrl = TextEditingController(text: widget.product?.description ?? '');
    _brandCtrl = TextEditingController(text: widget.product?.brand ?? '');
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _imageFile = bytes);
      } else {
        setState(() => _imageFile = pickedFile.path);
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final newProduct = Product(
        id: widget.product?.id ?? '', // ID handled by backend if empty usually, or checking logic
        name: _nameCtrl.text,
        category: _catCtrl.text,
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        description: _descCtrl.text,
        imageUrl: widget.product?.imageUrl ?? '',
        brand: _brandCtrl.text,
      );

      // Assuming addProduct handles both add and update logic or we split it
      // For now using addProduct for new, updateProduct for existing (but update needs image support too)
      // The user task focused on "Add New Product" mainly. 
      if (widget.product == null) {
        await ProductController().addProduct(newProduct, _imageFile);
      } else {
        await ProductController().updateProduct(newProduct, _imageFile);
      }
      
      widget.onSave();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.product == null ? 'Add New Product' : 'Edit Product',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Upload
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _imageFile != null
                          ? (kIsWeb 
                              ? Image.memory(_imageFile as Uint8List, fit: BoxFit.cover)
                              : Image.network('file://${_imageFile as String}', fit: BoxFit.cover))
                          : (widget.product?.imageUrl.isNotEmpty == true
                              ? Image.network(widget.product!.imageUrl, fit: BoxFit.cover)
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                                    SizedBox(height: 4),
                                    Text('Upload', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                )),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Fields
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _brandCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Brand Name',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Price (\$)',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _catCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, required this.label, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: isActive ? Colors.white : Colors.white60),
          title: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white60, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 24),
          Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}

class _ChartBox extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartBox({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      height: 450,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 30),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String time;

  const _ActivityItem({required this.icon, required this.color, required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
