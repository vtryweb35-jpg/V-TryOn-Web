import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_scaffold.dart';
import '../../theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return AppScaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 80 : 24,
            vertical: 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Checkout: Billing & Shipping',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: 600,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField('Full Name', _nameCtrl, Icons.person_outline),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Email', _emailCtrl, Icons.email_outlined)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildTextField('Phone', _phoneCtrl, Icons.phone_android_outlined)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildTextField('Shipping Address', _addressCtrl, Icons.home_outlined),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('City', _cityCtrl, Icons.location_city_outlined)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildTextField('Postal Code', _postalCtrl, Icons.mark_as_unread_outlined)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildTextField('Country', _countryCtrl, Icons.public_outlined),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.push('/order-confirm', extra: {
                                  'name': _nameCtrl.text,
                                  'email': _emailCtrl.text,
                                  'phone': _phoneCtrl.text,
                                  'address': _addressCtrl.text,
                                  'city': _cityCtrl.text,
                                  'postalCode': _postalCtrl.text,
                                  'country': _countryCtrl.text,
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('CONTINUE TO CONFIRMATION', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }
}
