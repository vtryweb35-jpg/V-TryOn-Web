import 'package:flutter/material.dart';
import 'nav_bar.dart';
import '../views/landing/widgets/footer.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final bool showNavBar;
  final bool showFooter;

  const AppScaffold({
    super.key,
    required this.body,
    this.showNavBar = true,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (showNavBar) const NavBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  body,
                  if (showFooter) const Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
