import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skillbridge_mobile/widgets/premium_loader.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../../../widgets/custom_feedback_popup.dart';

import 'forgot_password_screen.dart';
import 'role_selection_screen.dart';
import '../../data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPasswordVisible = false;
  bool _isOtpLogin = false;
  bool _isLoading = false;
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      if (!mounted) return;
      if (!mounted) return;
      CustomFeedbackPopup.show(
        context,
        title: 'Invalid Email',
        message: 'Please enter a valid email address',
        type: FeedbackType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.sendLoginOTP(_emailController.text.trim());
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        setState(() => _otpSent = true);
        CustomFeedbackPopup.show(
          context,
          title: 'OTP Sent',
          message: result['message'] ?? 'Check your email for the verification code',
          type: FeedbackType.otp,
        );
      } else {
        CustomFeedbackPopup.show(
          context,
          title: 'Failed to Send',
          message: result['message'] ?? 'Unable to send OTP. Please try again.',
          type: FeedbackType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomFeedbackPopup.show(
        context,
        title: 'Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      debugPrint('═══════════════════════════════════════');
      debugPrint('🔐 LOGIN: Starting login process');
      debugPrint('═══════════════════════════════════════');
      
      Map<String, dynamic> result;
      if (_isOtpLogin) {
        debugPrint('📧 Login method: OTP');
        result = await _authService.loginWithOTP(
          _emailController.text.trim(),
          _otpController.text.trim(),
        );
      } else {
        debugPrint('🔑 Login method: Password');
        result = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      debugPrint('📦 Login API Response:');
      debugPrint('   Success: ${result['success']}');
      debugPrint('   Message: ${result['message']}');

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        debugPrint('✅ Login successful!');
        final String? token = result['data']?['token'];
        debugPrint('🎫 Token from response: ${token != null ? "EXISTS (length: ${token.length})" : "NULL"}');
        
        if (token != null) {
          debugPrint('💾 Saving token to storage...');
          await AuthService.setToken(token);
          debugPrint('✅ Token saved successfully');
          
          // Verify token was saved
          final savedToken = AuthService.token;
          debugPrint('🔍 Verification - Token in memory: ${savedToken != null ? "EXISTS" : "NULL"}');
        } else {
          debugPrint('⚠️ No token in login response!');
        }
        
        if (!mounted) return;
        
        final String role = result['data']?['user']?['role'] ?? 'user';
        debugPrint('👤 User role: $role');
        
        CustomFeedbackPopup.show(
          context,
          title: 'Welcome!',
          message: result['message'] ?? 'Login successful!',
          type: FeedbackType.success,
          onConfirm: () {
            debugPrint('🚀 Navigating to main screen for role: $role');
            if (role == 'worker') {
              Navigator.of(context).pushNamedAndRemoveUntil('/worker-main', (route) => false);
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil('/tenant-main', (route) => false);
            }
          },
        );
        
        debugPrint('═══════════════════════════════════════');
        debugPrint('🏁 LOGIN: Login process complete');
        debugPrint('═══════════════════════════════════════\n');
      } else {
        debugPrint('❌ Login failed: ${result['message']}');
        CustomFeedbackPopup.show(
          context,
          title: 'Login Failed',
          message: result['message'] ?? 'Invalid credentials. Please try again.',
          type: FeedbackType.error,
        );
      }
    } catch (e) {
      debugPrint('💥 LOGIN ERROR: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomFeedbackPopup.show(
        context,
        title: 'Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
    }
  }

  void _toggleLoginMode() {
    setState(() {
      _isOtpLogin = !_isOtpLogin;
      _otpSent = false;
      _passwordController.clear();
      _otpController.clear();
    });
  }

  Future<void> _showExitDialog() async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Exit App',
          style: TextStyle(
            color: AppTheme.colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Are you sure you want to exit SkillBridge?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.colors.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen height for responsive spacing
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (Platform.isAndroid) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.colors.surface,
                AppTheme.colors.jobCardSecondary.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      
                      // Logo and Welcome Text
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.colors.surface,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.colors.primary.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Icon(
                            Icons.person_outline,
                            size: 50,
                            color: AppTheme.colors.primary,
                          )
                          // Note: Replace Icon with Image.asset if logo exists
                          // Image.asset('assets/logoSkillBridge.png', fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.colors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Login to continue to SkillBridge',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.colors.onSurface.withValues(alpha: 0.7),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
  
                      // Login Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.colors.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: AppTheme.colors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              /// EMAIL
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: AppTheme.colors.onSurface),
                                decoration: _buildInputDecoration(
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
  
                              /// PASSWORD LOGIN
                              if (!_isOtpLogin) ...[
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: _buildInputDecoration(
                                    label: 'Password',
                                    icon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: AppTheme.colors.primary,
                                      ),
                                      onPressed: () => setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      }),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        ForgotPasswordScreen.routeName,
                                      );
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: AppTheme.colors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
  
                              /// OTP LOGIN
                              if (_isOtpLogin) ...[
                                if (!_otpSent) ...[
                                  const SizedBox(height: 10),
                                  OutlinedButton.icon(
                                    onPressed: _isLoading ? null : _sendOtp,
                                    icon: const Icon(Icons.sms_outlined),
                                    label: const Text('Send Verification Code'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      side: BorderSide(color: AppTheme.colors.primary),
                                      foregroundColor: AppTheme.colors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  TextFormField(
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    decoration: _buildInputDecoration(
                                      label: 'Enter OTP',
                                      icon: Icons.pin_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter OTP';
                                      }
                                      if (value.length != 6) {
                                        return 'OTP must be 6 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _isLoading ? null : _sendOtp,
                                      child: const Text('Resend OTP'),
                                    ),
                                  ),
                                ],
                              ],
  
                              const SizedBox(height: 32),
  
                              /// LOGIN BUTTON
                              ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.colors.primary,
                                  foregroundColor: AppTheme.colors.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  elevation: 4,
                                  shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,

                                        child: PremiumLoader(
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
  
                      const SizedBox(height: 24),
  
                      /// TOGGLE LOGIN MODE
                      TextButton(
                        onPressed: _toggleLoginMode,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          backgroundColor: AppTheme.colors.surface,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isOtpLogin ? Icons.lock_outline : Icons.sms_outlined,
                              size: 20,
                              color: AppTheme.colors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isOtpLogin
                                  ? 'Login with Password instead'
                                  : 'Login with OTP instead',
                              style: TextStyle(
                                color: AppTheme.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
  
                      const SizedBox(height: 32),
                      
                      // Register Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Text(
                            "Don't have an account? ",
                            style: TextStyle(color: AppTheme.colors.onSurface.withValues(alpha: 0.6)),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(RoleSelectionScreen.routeName);
                            },
                            child: Text(
                              'Register Now',
                              style: TextStyle(
                                color: AppTheme.colors.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintStyle: TextStyle(color: AppTheme.colors.onSurface.withValues(alpha: 0.4)),
      prefixIcon: Icon(icon, color: AppTheme.colors.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppTheme.colors.jobCardSecondary.withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.colors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }
}
