import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.checkroom, color: AppTheme.primaryColor, size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          'V-Try',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Virtual Try-on technology for the world\'s catalog.',
                      style: TextStyle(color: Colors.white54, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _SocialIcon(icon: Icons.facebook),
                        const SizedBox(width: 16),
                        _SocialIcon(icon: Icons.camera_alt),
                        const SizedBox(width: 16),
                        _SocialIcon(icon: Icons.alternate_email),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 40),

              // Links
              if (MediaQuery.of(context).size.width > 800) ...[
                _FooterColumn(
                  title: 'Services',
                  links: const {
                    'Shop': '/shop',
                    'Pricing': '/pricing',
                    'Try-On': '/try-on',
                    'API Integration': '/contact',
                    'Developer Docs': '/contact',
                  },
                ),
                _FooterColumn(
                  title: 'Company',
                  links: const {
                    'About Us': '/about',
                    'Contact': '/contact',
                  },
                ),
                _FooterColumn(
                  title: 'Legal',
                  links: const {
                    'Privacy': '/about', // Placeholder
                    'Terms': '/about',    // Placeholder
                    'Security': '/about', // Placeholder
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 60),
          const Divider(color: Colors.white12),
          const SizedBox(height: 24),
          const Text(
            '© 2024 V-Try. All rights reserved.',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final Map<String, String> links;

  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ...links.entries.map((entry) => _FooterLink(label: entry.key, route: entry.value)),
        ],
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final String route;

  const _FooterLink({required this.label, required this.route});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go(widget.route),
        onHover: (hovering) => setState(() => _isHovered = hovering),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: _isHovered ? AppTheme.primaryColor : Colors.white54,
            fontSize: 14,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isHovered ? AppTheme.primaryColor : Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          color: _isHovered ? Colors.white : Colors.white54,
          size: 20,
        ),
      ),
    );
  }
}
