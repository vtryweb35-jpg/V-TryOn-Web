import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_scaffold.dart';
import '../../utils/app_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final auth = AuthController();
    _nameController = TextEditingController(text: auth.userName);
    _emailController = TextEditingController(text: auth.userEmail);
    _phoneController = TextEditingController(text: auth.phone);
    _addressController = TextEditingController(text: auth.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          await AuthController().uploadProfileImage(bytes);
        } else {
          // For mobile, still using path for now as ApiService handles it
          await AuthController().uploadProfileImage(pickedFile.path);
        }
        if (mounted) {
          AppSnackbar.show(
            context,
            message: 'Profile picture updated!',
            isError: false,
          );
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.show(
            context,
            message: 'Failed to upload image: $e',
            isError: true,
          );
        }
      }
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await AuthController().updateProfile(
          name: _nameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
        );
        if(mounted) {
          AppSnackbar.show(
            context,
            message: 'Profile updated successfully!',
            isError: false,
          );
        }
      } catch (e) {
        if(mounted) {
          AppSnackbar.show(
            context,
            message: 'Failed to update profile: $e',
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController();
    
    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Settings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your account information and preferences.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 48),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Section
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1), width: 4),
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.05),
                                  backgroundImage: auth.profilePic != null && auth.profilePic!.isNotEmpty 
                                      ? NetworkImage(auth.profilePic!) 
                                      : null,
                                  child: auth.profilePic == null || auth.profilePic!.isEmpty
                                      ? Text(
                                          auth.userName?.substring(0, 1).toUpperCase() ?? 'U',
                                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _pickImage,
                            child: const Text(
                              'Update Picture',
                              style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 48),
                    
                    // Details Section
                    Expanded(
                      flex: 2,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildInfoCard(
                              title: 'Personal Information',
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  icon: Icons.person_outline,
                                  validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                                ),
                                const SizedBox(height: 24),
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  icon: Icons.email_outlined,
                                  enabled: false, // Email usually handled separately for security
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _buildInfoCard(
                              title: 'Contact & Address',
                              children: [
                                _buildTextField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  icon: Icons.phone_outlined,
                                ),
                                const SizedBox(height: 24),
                                _buildTextField(
                                  controller: _addressController,
                                  label: 'Shipping Address',
                                  icon: Icons.location_on_outlined,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Save Changes',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        filled: !enabled,
        fillColor: enabled ? Colors.transparent : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }
}
