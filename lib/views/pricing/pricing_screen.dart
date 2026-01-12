import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_scaffold.dart';
import '../../theme/app_theme.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Column(
          children: [
            Text(
              'Simple Pricing for Everyone',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose the plan that fits your needs. No hidden fees.',
              style: TextStyle(color: Colors.black54, fontSize: 18),
            ),
            const SizedBox(height: 80),
            
            Wrap(
              spacing: 40,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              children: [
                const _PricingCard(
                  title: 'Personal',
                  price: 'Free',
                  description: 'Perfect for individuals starting out.',
                  features: ['5 Try-ons per month', 'Access to Shop', 'Standard Preview Quality'],
                  buttonText: 'Get Started',
                  isPopular: false,
                ),
                _PricingCard(
                  title: 'Pro',
                  price: '\$19',
                  period: '/mo',
                  description: 'For fashion enthusiasts and influencers.',
                  features: const ['Unlimited Try-ons', 'HD Result Downloads', 'Early Access to New Items', 'Priority Support'],
                  buttonText: 'Go Pro',
                  isPopular: true,
                  onTap: () {
                    context.push('/payment', extra: {
                      'amount': 19.0,
                      'title': 'Pro Plan',
                      'description': 'Monthly subscription for Pro features.',
                    });
                  },
                ),
                const _PricingCard(
                  title: 'Brand',
                  price: 'Custom',
                  description: 'Tailored solutions for retailers and labels.',
                  features: ['Full Catalog Integration', 'API Access', 'Custom Analytics', 'Dedicated Account Manager'],
                  buttonText: 'Contact Sales',
                  isPopular: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String? period;
  final String description;
  final List<String> features;
  final String buttonText;
  final bool isPopular;
  final VoidCallback? onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    this.period,
    required this.description,
    required this.features,
    required this.buttonText,
    required this.isPopular,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isPopular ? AppTheme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'MOST POPULAR',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPopular ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: isPopular ? Colors.white : Colors.black,
                ),
              ),
              if (period != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 4),
                  child: Text(
                    period!,
                    style: TextStyle(
                      color: isPopular ? Colors.white70 : Colors.black54,
                      fontSize: 18,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              color: isPopular ? Colors.white70 : Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white24),
          const SizedBox(height: 32),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isPopular ? Colors.white : AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      feature,
                      style: TextStyle(
                        color: isPopular ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? Colors.white : AppTheme.primaryColor,
                foregroundColor: isPopular ? AppTheme.primaryColor : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
