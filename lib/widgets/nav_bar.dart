import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../views/auth/login_modal.dart';
import '../controllers/cart_controller.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_router.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  bool _isLoggingOut = false;

  void _handleLogout() {
    final auth = AuthController();
    setState(() => _isLoggingOut = true);
    auth.logout();
    AppRouter.router.go('/');
    // Period of "lock" to prevent premature cleanup of the PopupMenuButton context
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isLoggingOut = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final cartController = CartController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
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
          
            // Desktop Menu
            ListenableBuilder(
              listenable: AuthController(),
              builder: (context, _) {
                final auth = AuthController();
                return Row(
                  children: [
                    _NavLink(title: 'Overview', isActive: location == '/', onTap: () => context.go('/')),
                    _NavLink(title: 'Shop', isActive: location == '/shop', onTap: () => context.go('/shop')),
                    _NavLink(title: 'Try-On', isActive: location == '/try-on', onTap: () => context.go('/try-on')),
                    _NavLink(title: 'Pricing', isActive: location == '/pricing', onTap: () => context.go('/pricing')),
                    _NavLink(title: 'About', isActive: location == '/about', onTap: () => context.go('/about')),
                    _NavLink(title: 'Contact', isActive: location == '/contact', onTap: () => context.go('/contact')),
                    if (auth.isBrand)
                      _NavLink(title: 'Admin', isActive: location == '/admin', onTap: () => context.go('/admin')),
                  ],
                );
              },
            ),

          // Actions
          ListenableBuilder(
            listenable: AuthController(),
            builder: (context, _) {
              final auth = AuthController();
              return Row(
                children: [
                  // Cart Badge
                  ListenableBuilder(
                    listenable: cartController,
                    builder: (context, child) {
                      return _CartIcon(cartController: cartController);
                    },
                  ),
                  const SizedBox(width: 8),
                  if (!auth.isLoggedIn && !_isLoggingOut)
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
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'logout') {
                          _handleLogout();
                        } else if (value == 'profile') {
                          AppRouter.router.push('/profile');
                        } else if (value == 'orders') {
                          AppRouter.router.push('/orders');
                        }
                      },
                      offset: const Offset(0, 50),
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey[100]!, width: 1),
                      ),
                      itemBuilder: (context) => [
                        // User Info Header
                        PopupMenuItem(
                          enabled: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                auth.userName ?? 'User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                auth.userEmail ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Divider(),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'profile',
                          child: _DropdownItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Profile Settings',
                          ),
                        ),
                        if (!auth.isBrand)
                          const PopupMenuItem(
                            value: 'orders',
                            child: _DropdownItem(
                              icon: Icons.shopping_bag_outlined,
                              label: 'My Orders',
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'settings',
                          child: _DropdownItem(
                            icon: Icons.settings_outlined,
                            label: 'Account Settings',
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'logout',
                          child: _DropdownItem(
                            icon: Icons.logout_rounded,
                            label: 'Log Out',
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          backgroundImage: auth.profilePic != null && auth.profilePic!.isNotEmpty
                              ? NetworkImage(auth.profilePic!) 
                              : null,
                          child: auth.profilePic == null || auth.profilePic!.isEmpty
                              ? Text(
                                  auth.userName?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: AppTheme.primaryColor,
                                    fontSize: 14,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CartIcon extends StatefulWidget {
  final CartController cartController;
  const _CartIcon({required this.cartController});

  @override
  State<_CartIcon> createState() => _CartIconState();
}

class _CartIconState extends State<_CartIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _isHovered ? 1.1 : 1.0,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => context.go('/cart'),
              icon: Icon(
                widget.cartController.totalItems > 0 ? Icons.shopping_bag : Icons.shopping_bag_outlined,
                color: _isHovered ? AppTheme.primaryColor : Colors.black87,
              ),
            ),
            if (widget.cartController.totalItems > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${widget.cartController.totalItems}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _NavLink({required this.title, required this.isActive, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onHover: (hovering) => setState(() => _isHovered = hovering),
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: (widget.isActive || _isHovered) ? AppTheme.primaryColor : Colors.black54,
                fontWeight: (widget.isActive || _isHovered) ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: (widget.isActive || _isHovered) ? 16 : 0,
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
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class _DropdownItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _DropdownItem({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.black54),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: color ?? Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
