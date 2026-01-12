import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class StatsSection extends StatefulWidget {
  const StatsSection({super.key});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      color: const Color(0xFFF8F9FA),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Wrap(
            spacing: 100,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: const [
              _StatItem(value: '500K+', label: 'Active Users'),
              _StatItem(value: '2M+', label: 'Products Available'),
              _StatItem(value: '1,200+', label: 'Partner Brands'),
              _StatItem(value: '40%', label: 'Lower Returns'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryColor,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.black45,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
