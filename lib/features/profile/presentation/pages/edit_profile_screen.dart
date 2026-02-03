import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';

import 'package:skillbridge_mobile/widgets/premium_loader.dart';
import 'package:skillbridge_mobile/widgets/custom_feedback_popup.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import '../../../auth/data/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});

  static const String routeName = '/edit-profile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  
  // Professional details for workers
  late TextEditingController _experienceController;
  List<String> _skills = [];
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.userData;
    final address = user['address'] ?? {};
    
    _nameController = TextEditingController(text: user['name'] ?? '');
    _phoneController = TextEditingController(text: user['phone'] ?? '');
    _streetController = TextEditingController(text: address['street'] ?? '');
    _cityController = TextEditingController(text: address['city'] ?? '');
    _stateController = TextEditingController(text: address['state'] ?? '');
    _pincodeController = TextEditingController(text: address['pincode'] ?? '');
    
    _experienceController = TextEditingController(text: (user['experience'] ?? '0').toString());
    _skills = List<String>.from(user['skills'] ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final String role = widget.userData['role']?.toString().toLowerCase() ?? 'user';
      final bool isWorker = role == 'worker';

      final Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': {
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'pincode': _pincodeController.text.trim(),
        },
      };

      if (isWorker) {
        updateData['experience'] = int.tryParse(_experienceController.text) ?? 0;
        updateData['skills'] = _skills;
      }

      final result = await _authService.updateProfile(updateData);

      if (mounted) {
        setState(() => _isSaving = false);
        if (result['success'] == true) {
          CustomFeedbackPopup.show(
            context,
            title: 'Success',
            message: 'Profile updated successfully!',
            type: FeedbackType.success,
            onConfirm: () => Navigator.of(context).pop(true),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Update failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String role = widget.userData['role']?.toString().toLowerCase() ?? 'user';
    final bool isWorker = role == 'worker';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: const PremiumAppBar(
        title: 'Edit Profile',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('BASIC INFORMATION'),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Phone is required' : null,
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('ADDRESS DETAILS'),
              _buildTextField(
                controller: _streetController,
                label: 'Street Address',
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      icon: Icons.location_city_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _stateController,
                      label: 'State',
                      icon: Icons.map_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _pincodeController,
                label: 'Pincode',
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
              ),

              if (isWorker) ...[
                const SizedBox(height: 32),
                _buildSectionTitle('PROFESSIONAL DETAILS'),
                _buildTextField(
                  controller: _experienceController,
                  label: 'Years of Experience',
                  icon: Icons.history_edu_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildSkillsInput(),
              ],

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectanglePlatform.borderRadius20,
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const PremiumLoader(color: Colors.white, size: 24)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.blueGrey[400],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Function(String)? onFieldSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.colors.primary, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSkillsInput() {
    final controller = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: controller,
          label: 'Add Skill (Press Enter)',
          icon: Icons.star_border_rounded,
          onFieldSubmitted: (v) {
            if (v.isNotEmpty && !_skills.contains(v)) {
              setState(() => _skills.add(v));
              controller.clear();
            }
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.map((skill) => Chip(
            label: Text(skill),
            onDeleted: () => setState(() => _skills.remove(skill)),
            backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
            labelStyle: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold),
            deleteIconColor: AppTheme.colors.primary,
          )).toList(),
        ),
      ],
    );
  }
}

class RoundedRectanglePlatform {
  static final borderRadius20 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));
}
