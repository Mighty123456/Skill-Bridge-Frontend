import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import 'login_screen.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/auth_service.dart';
import '../../../../widgets/custom_feedback_popup.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const routeName = '/forgot-password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  int _step = 1; // 1: Email, 2: OTP, 3: New Password
  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      if (!mounted) return;
      CustomFeedbackPopup.show(
        context,
        title: 'Invalid Email',
        message: 'Please enter a valid email address',
        type: FeedbackType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.forgotPassword(_emailController.text.trim());
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        setState(() {
          _step = 2;
        });
        CustomFeedbackPopup.show(
          context,
          title: 'OTP Sent',
          message: result['message'] ?? 'Please check your email for the verification code',
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
      setState(() {
        _isLoading = false;
      });
      CustomFeedbackPopup.show(
        context,
        title: 'Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      if (!mounted) return;
      CustomFeedbackPopup.show(
        context,
        title: 'Invalid OTP',
        message: 'Please enter a valid 6-digit verification code',
        type: FeedbackType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.verifyResetOTP(
        _emailController.text.trim(),
        _otpController.text.trim(),
      );
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        setState(() {
          _step = 3;
        });
        CustomFeedbackPopup.show(
          context,
          title: 'Verified!',
          message: result['message'] ?? 'OTP verified successfully',
          type: FeedbackType.success,
        );
      } else {
        CustomFeedbackPopup.show(
          context,
          title: 'Verification Failed',
          message: result['message'] ?? 'Invalid OTP code. Please try again.',
          type: FeedbackType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      CustomFeedbackPopup.show(
        context,
        title: 'Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      if (!mounted) return;
      CustomFeedbackPopup.show(
        context,
        title: 'Mismatch',
        message: 'Passwords do not match. Please check again.',
        type: FeedbackType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.resetPassword(
        _emailController.text.trim(),
        _otpController.text.trim(),
        _newPasswordController.text.trim(),
      );
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        CustomFeedbackPopup.show(
          context,
          title: 'Success!',
          message: result['message'] ?? 'Your password has been reset successfully',
          type: FeedbackType.success,
          onConfirm: () {
            // Navigate back to login
            Navigator.of(context).pushNamedAndRemoveUntil(
              LoginScreen.routeName,
              (route) => false,
            );
          },
        );
      } else {
        CustomFeedbackPopup.show(
          context,
          title: 'Reset Failed',
          message: result['message'] ?? 'Unable to reset password. Please try again.',
          type: FeedbackType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      CustomFeedbackPopup.show(
        context,
        title: 'Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Forgot Password',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.colors.background,
              AppTheme.colors.background.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Progress Indicator
                  _buildProgressIndicator(),
                  
                  const SizedBox(height: 40),
                  
                  // Step 1: Email Input
                  if (_step == 1) ...[
                    _buildEmailStep(),
                  ],
                  
                  // Step 2: OTP Verification
                  if (_step == 2) ...[
                    _buildOtpStep(),
                  ],
                  
                  // Step 3: New Password
                  if (_step == 3) ...[
                    _buildPasswordStep(),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Back to Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remember your password? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: AppTheme.colors.primary,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Expanded(
          child: _buildStepIndicator(
            stepNumber: 1,
            label: 'Email',
            isActive: _step >= 1,
            isCompleted: _step > 1,
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            color: _step >= 2
                ? AppTheme.colors.primary
                : AppTheme.colors.onSurface.withValues(alpha: 0.3),
          ),
        ),
        Expanded(
          child: _buildStepIndicator(
            stepNumber: 2,
            label: 'OTP',
            isActive: _step >= 2,
            isCompleted: _step > 2,
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            color: _step >= 3
                ? AppTheme.colors.primary
                : AppTheme.colors.onSurface.withValues(alpha: 0.3),
          ),
        ),
        Expanded(
          child: _buildStepIndicator(
            stepNumber: 3,
            label: 'Reset',
            isActive: _step >= 3,
            isCompleted: false,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator({
    required int stepNumber,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppTheme.colors.success
                : isActive
                    ? AppTheme.colors.primary
                    : AppTheme.colors.onSurface.withValues(alpha: 0.3),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    color: AppTheme.colors.onPrimary,
                    size: 20,
                  )
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: isActive
                          ? AppTheme.colors.onPrimary
                          : AppTheme.colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? AppTheme.colors.primary
                : AppTheme.colors.onSurface.withValues(alpha: 0.6),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reset Password',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppTheme.colors.primary,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email address and we\'ll send you an OTP to reset your password',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.colors.onSurface.withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !_isLoading,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email address',
            prefixIcon: Icon(Icons.email, color: AppTheme.colors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
            ),
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
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colors.primary,
            foregroundColor: AppTheme.colors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Send OTP',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Verify OTP',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppTheme.colors.primary,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a 6-digit OTP to ${_emailController.text}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.colors.onSurface.withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          enabled: !_isLoading,
          decoration: InputDecoration(
            labelText: 'Enter OTP',
            hintText: 'Enter 6-digit OTP',
            prefixIcon: Icon(Icons.pin, color: AppTheme.colors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
            ),
          ),
          maxLength: 6,
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive OTP? ",
              style: TextStyle(
                color: AppTheme.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _sendOtp,
              child: Text(
                'Resend OTP',
                style: TextStyle(
                  color: AppTheme.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colors.primary,
            foregroundColor: AppTheme.colors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Verify OTP',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'New Password',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppTheme.colors.primary,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Create a strong password for your account',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.colors.onSurface.withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _newPasswordController,
          obscureText: !_isPasswordVisible,
          enabled: !_isLoading,
          decoration: InputDecoration(
            labelText: 'New Password',
            hintText: 'Enter your new password',
            prefixIcon: Icon(Icons.lock, color: AppTheme.colors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.colors.primary,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a new password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (!value.contains(RegExp(r'[A-Z]'))) {
              return 'Password must contain at least one uppercase letter';
            }
            if (!value.contains(RegExp(r'[0-9]'))) {
              return 'Password must contain at least one number';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          enabled: !_isLoading,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Re-enter your new password',
            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.colors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.colors.primary,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _newPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colors.success,
            foregroundColor: AppTheme.colors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}

