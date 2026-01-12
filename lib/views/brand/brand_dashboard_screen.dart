import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../theme/app_theme.dart';

class BrandDashboardScreen extends StatelessWidget {
  const BrandDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Brand Dashboard', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Manage your subscription and track your item performance.', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 48),
            
            // Stats Row
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _StatCard(title: 'Active Subscription', value: 'PRO PLAN', icon: Icons.verified),
                _StatCard(title: 'Total Products', value: '24', icon: Icons.inventory),
                _StatCard(title: 'Monthly Try-ons', value: '1,240', icon: Icons.accessibility_new),
              ],
            ),
            
            const SizedBox(height: 60),
            
            // Subscription Section
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Your Next Billing', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 8),
                        Text('January 15, 2025', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        Text('Monthly Pro Plan - \$19 / mo', style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                    child: const Text('MANAGE BILLING'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 32),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
