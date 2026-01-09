import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/custom_feedback_popup.dart';
import 'package:skillbridge_mobile/features/auth/data/auth_service.dart';
import 'package:skillbridge_mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import 'edit_profile_screen.dart';
import 'package:skillbridge_mobile/features/worker/presentation/pages/worker_performance_screen.dart';

class ProfileScreen extends StatefulWidget {

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    debugPrint('═══════════════════════════════════════');
    debugPrint('🔍 PROFILE SCREEN: Starting profile fetch');
    debugPrint('═══════════════════════════════════════');
    
    setState(() => _isLoading = true);
    try {
      final currentToken = AuthService.token;
      if (currentToken == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
        }
        return;
      }
      
      final result = await _authService.getMe();
      
      if (result['success'] == true) {
        if (result['data'] != null && result['data']['user'] != null) {
          if (mounted) {
            setState(() {
              _userData = result['data']['user'];
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        final message = result['message']?.toString().toLowerCase() ?? '';
        if (message.contains('expired') || message.contains('invalid')) {
          if (mounted) {
            setState(() => _isLoading = false);
            CustomFeedbackPopup.show(
              context,
              title: 'Session Expired',
              message: 'Your session has expired. Please login again.',
              type: FeedbackType.error,
              onConfirm: () {
                AuthService.clearToken();
                Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
              },
            );
          }
        } else {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load profile: ${result['message']}')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final result = await _authService.uploadProfileImage(File(image.path));
      
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
          _fetchProfile(); // Refresh to show new image
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Upload failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading: $e')),
        );
      }
    }
  }

  void _logout() {
    CustomFeedbackPopup.show(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to end your session?',
      type: FeedbackType.error,
      onConfirm: () {
        AuthService.clearToken();
        Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.routeName,
          (route) => false,
        );
      },
    );
  }

  void _navigateToEditProfile() async {
    if (_userData == null) return;
    
    final result = await Navigator.of(context).pushNamed(
      EditProfileScreen.routeName,
      arguments: _userData,
    );

    if (result == true) {
      _fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: const PremiumAppBar(),
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.colors.primary,
          ),
        ),
      );
    }

    final user = _userData ?? {};
    final String role = (user['role'] ?? 'user').toString().toLowerCase();
    final bool isWorker = role == 'worker';
    final Map<String, dynamic> address = user['address'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: const PremiumAppBar(),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        color: AppTheme.colors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildPremiumHeader(user),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('ACCOUNT OVERVIEW'),
                        TextButton.icon(
                          onPressed: _navigateToEditProfile,
                          icon: Icon(Icons.edit_outlined, size: 16, color: AppTheme.colors.primary),
                          label: Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: AppTheme.colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildSettingsCard([
                      _SettingsItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Full Name',
                        subtitle: user['name'] ?? 'Not set',
                        trailing: user['name'] != null 
                            ? const Icon(Icons.verified_rounded, color: Colors.blue, size: 16)
                            : null,
                      ),
                      _SettingsItem(
                        icon: Icons.alternate_email_rounded,
                        title: 'Email Address',
                        subtitle: user['email'] ?? 'Not set',
                      ),
                      _SettingsItem(
                        icon: Icons.phone_android_rounded,
                        title: 'Phone Number',
                        subtitle: user['phone'] ?? 'Not set',
                      ),
                    ]),

                    const SizedBox(height: 28),

                    if (isWorker) ...[
                      _buildSectionHeader('PROFESSIONAL IDENTITY'),
                      _buildSettingsCard([
                        _SettingsItem(
                          icon: Icons.verified_user_outlined,
                          title: 'Verification Status',
                          subtitle: user['isVerified'] == true ? 'Verified Professional' : 'Verification Pending',
                          trailing: Icon(
                            user['isVerified'] == true ? Icons.check_circle : Icons.pending,
                            color: user['isVerified'] == true ? Colors.green : Colors.orange,
                          ),
                        ),
                        _SettingsItem(
                          icon: Icons.description_outlined,
                          title: 'Identity Documents',
                          subtitle: 'Aadhar & Govt ID uploaded',
                        ),
                        _SettingsItem(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Badges & Level',
                          subtitle: 'Gold Level - 12 Badges',
                          color: Colors.amber,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerPerformanceScreen()));
                          },
                        ),
                      ]),
                      const SizedBox(height: 28),
                      
                      _buildSectionHeader('WORK PORTFOLIO'),
                      Container(
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 28),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                                image: const DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1581094794329-c8112a89af12?q=80&w=200'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: index == 3 ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text('+5 more', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ) : null,
                            );
                          },
                        ),
                      ),

                      _buildSectionHeader('SKILLS & EXPERTISE'),
                      _buildSettingsCard([
                        _SettingsItem(
                          icon: Icons.work_outline_rounded,
                          title: 'Primary Skills',
                          subtitle: (user['skills'] as List?)?.isNotEmpty == true 
                              ? (user['skills'] as List).join(', ')
                              : 'Not specified',
                          color: AppTheme.colors.primary,
                        ),
                        _SettingsItem(
                          icon: Icons.history_edu_rounded,
                          title: 'Experience',
                          subtitle: '${user['experience'] ?? '0'} Years',
                        ),
                      ]),
                      const SizedBox(height: 28),
                    ],


                    _buildSectionHeader('LOCATION & ADDRESS'),
                    _buildSettingsCard([
                      _SettingsItem(
                        icon: Icons.location_city_rounded,
                        title: 'City',
                        subtitle: address['city'] ?? 'Not set',
                      ),
                      _SettingsItem(
                        icon: Icons.map_outlined,
                        title: 'State',
                        subtitle: address['state'] ?? 'Not set',
                      ),
                      if (address['street'] != null && address['street'].toString().isNotEmpty)
                        _SettingsItem(
                          icon: Icons.home_outlined,
                          title: 'Street Address',
                          subtitle: address['street'],
                        ),
                      if (address['pincode'] != null && address['pincode'].toString().isNotEmpty)
                        _SettingsItem(
                          icon: Icons.pin_drop_outlined,
                          title: 'Pincode',
                          subtitle: address['pincode'],
                        ),
                    ]),

                    const SizedBox(height: 32),
                    
                    _buildActionItem(
                      label: 'Sign Out',
                      icon: Icons.logout_rounded,
                      onTap: _logout,
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'SkillBridge v1.0.5',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(Map<String, dynamic> user) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.colors.primary.withValues(alpha: 0.08),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.05),
                  backgroundImage: user['profileImage'] != null 
                      ? NetworkImage(user['profileImage']) 
                      : null,
                  child: user['profileImage'] == null 
                      ? Icon(
                          Icons.person_rounded,
                          size: 56,
                          color: AppTheme.colors.primary.withValues(alpha: 0.2),
                        ) 
                      : null,
                ),
              ),
              if (_isUploadingPhoto)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: _isUploadingPhoto ? null : _pickAndUploadImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.colors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user['name'] ?? 'SkillBridge User',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E1E1E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.colors.primary,
                  AppTheme.colors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.colors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              (user['role'] ?? 'USER').toString().toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.blueGrey[600],
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<_SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x0F000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x02000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          final isLast = items.indexOf(item) == items.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (item.color ?? AppTheme.colors.primary)
                        .withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color ?? AppTheme.colors.primary,
                    size: 22,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing: item.trailing ??
                    const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Color(0xFFD1D5DB),
                    ),
                onTap: item.onTap,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: const Color(0x0A000000),
                  indent: 72,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final Widget? trailing;
  final VoidCallback? onTap;
  _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.trailing,
    this.onTap,
  });
}
