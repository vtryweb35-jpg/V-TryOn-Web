import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import 'widgets/hero_section.dart';
import 'widgets/how_it_works_section.dart';
import 'widgets/stats_section.dart';
import 'widgets/cta_section.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: const [
          HeroSection(),
          HowItWorksSection(),
          StatsSection(),
          CTASection(),
        ],
      ),
    );
  }
}
