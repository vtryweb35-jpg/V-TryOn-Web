import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../auth/login_modal.dart';
import '../../../controllers/auth_controller.dart';

class LandingNavBar extends StatefulWidget {
  const LandingNavBar({super.key});

  @override
  State<LandingNavBar> createState() => _LandingNavBarState();
}

class _LandingNavBarState extends State<LandingNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            InkWell(
              onTap: () => context.go('/'),
              child: Row(
                children: [
                  const Icon(Icons.checkroom, color: AppTheme.primaryColor, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    'V-Try',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                ],
              ),
            ),
            
            // Desktop Menu & Actions
            ListenableBuilder(
              listenable: AuthController(),
              builder: (context, _) {
                final auth = AuthController();
                return Row(
                  children: [
                    if (MediaQuery.of(context).size.width > 800) ...[
                      if (!auth.isBrand) ...[
                        _NavLink(title: 'Shop', route: '/shop'),
                        _NavLink(title: 'Try-On', route: '/try-on'),
                        _NavLink(title: 'Pricing', route: '/pricing'),
                        _NavLink(title: 'About', route: '/about'),
                        _NavLink(title: 'Contact', route: '/contact'),
                      ] else ...[
                        _NavLink(title: 'Admin Dashboard', route: '/admin'),
                      ],
                    ],
                    const SizedBox(width: 24),
                    if (!auth.isLoggedIn)
                      _NavButton(
                        label: 'Log In',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const LoginModal(),
                          );
                        },
                      )
                    else
                      Row(
                        children: [
                          Text('Hi, ${auth.userName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(width: 16),
                          _NavButton(
                            label: 'Log Out',
                            onPressed: () => auth.logout(),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String title;
  final String route;

  const _NavLink({required this.title, required this.route});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => context.go(widget.route),
        onHover: (hovering) => setState(() => _isHovered = hovering),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: _isHovered ? AppTheme.primaryColor : Colors.black54,
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: _isHovered ? 20 : 0,
              margin: const EdgeInsets.only(top: 4),
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _NavButton({required this.label, required this.onPressed});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _isHovered ? 1.05 : 1.0,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: _isHovered ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
