import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class HowItWorksSection extends StatefulWidget {
  const HowItWorksSection({super.key});

  @override
  State<HowItWorksSection> createState() => _HowItWorksSectionState();
}

class _HowItWorksSectionState extends State<HowItWorksSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      color: Colors.white,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Text(
              'How V-Try Works',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    fontSize: 32,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Three simple steps to your perfect outfit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 80),
            Wrap(
              spacing: 40,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              children: const [
                _FeatureCard(
                  icon: Icons.upload_file,
                  title: 'Upload',
                  description: 'Upload your photo or use our models to see how clothes fit on you.',
                  index: 0,
                ),
                _FeatureCard(
                  icon: Icons.checkroom,
                  title: 'Browse & Try',
                  description: 'Explore thousands of products and see how they look on you instantly.',
                  index: 1,
                ),
                _FeatureCard(
                  icon: Icons.verified_user,
                  title: 'Buy with Confidence',
                  description: 'Make informed decisions and reduce returns with our perfect fit guarantee.',
                  index: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final int index;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.index,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 320,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered ? AppTheme.primaryColor.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.1 : 0.05),
              blurRadius: _isHovered ? 30 : 15,
              offset: Offset(0, _isHovered ? 15 : 5),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _isHovered ? AppTheme.primaryColor : AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: _isHovered ? Colors.white : AppTheme.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                height: 1.6,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
