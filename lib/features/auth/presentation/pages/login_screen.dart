import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';

import 'forgot_password_screen.dart';
import 'role_selection_screen.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _otpSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('OTP sent to your email'),
        backgroundColor: AppTheme.colors.success,
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacementNamed(RoleSelectionScreen.routeName);
  }

  void _toggleLoginMode() {
    setState(() {
      _isOtpLogin = !_isOtpLogin;
      _otpSent = false;
      _passwordController.clear();
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen height for responsive spacing
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppTheme.colors.primary),
      ),
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
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
