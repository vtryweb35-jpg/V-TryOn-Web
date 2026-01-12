import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        child: Column(
          children: [
            const Text('Our Mission', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text(
              'Redefining the online shopping experience through AI-powered virtual try-on.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
            const SizedBox(height: 80),
            
            Flex(
              direction: MediaQuery.of(context).size.width > 900 ? Axis.horizontal : Axis.vertical,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.history_edu, size: 100, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 60, height: 60),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Why V-Try?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      const Text(
                        'Online shopping is convenient but lacks the "try-before-you-buy" confidence. V-Try bridges this gap using state-of-the-art vision models, allowing customers to visualize garments on their own photos instantly.',
                        style: TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'We help brands reduce returns by up to 40% and increase customer satisfaction by providing a realistic preview of fit and style.',
                        style: TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
            
            // Innovation Section
            Flex(
              direction: MediaQuery.of(context).size.width > 900 ? Axis.horizontal : Axis.vertical,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Our Innovation', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      const Text(
                        'At the core of V-Try is a proprietary deep learning architecture designed specifically for high-fidelity clothing warping and texture preservation.',
                        style: TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Our models accounts for body pose, lighting conditions, and fabric physics to ensure that what you see on screen is exactly how it will look in person.',
                        style: TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 60, height: 60),
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.psychology, size: 100, color: Colors.black45),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 100),

            // Community Section
            Container(
              padding: const EdgeInsets.all(60),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    'Join the Community',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Be the first to know about new brand partnerships and technology updates.',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Icon(Icons.send, color: AppTheme.primaryColor),
                      ),
                    ),
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
