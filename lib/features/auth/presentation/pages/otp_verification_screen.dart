import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../data/auth_service.dart';
import 'login_screen.dart';
import '../../../../widgets/custom_feedback_popup.dart';

class OTPVerificationScreen extends StatefulWidget {
  static const routeName = '/verify-otp';
  
  final String email;
  final String flowType; // 'registration' or 'login'

  const OTPVerificationScreen({
    super.key,
    required this.email,
    this.flowType = 'registration',
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  Timer? _timer;
  int _start = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _start = 60;
      _canResend = false;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _canResend = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      CustomFeedbackPopup.show(
        context,
        title: 'Invalid OTP',
        message: 'Please enter a 6-digit verification code',
        type: FeedbackType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> result;
      if (widget.flowType == 'registration') {
        result = await _authService.verifyRegistrationOTP(widget.email, otp);
      } else {
        result = await _authService.loginWithOTP(widget.email, otp);
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        CustomFeedbackPopup.show(
          context,
          title: 'Verified!',
          message: result['message'] ?? 'Email verification successful!',
          type: FeedbackType.success,
          onConfirm: () {
            if (widget.flowType == 'registration') {
              Navigator.of(context).pushNamedAndRemoveUntil(
                LoginScreen.routeName,
                (route) => false,
              );
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/', // Replace with Home route
                (route) => false,
              );
            }
          },
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

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.resendOTP(widget.email);
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        startTimer();
        CustomFeedbackPopup.show(
          context,
          title: 'OTP Resent',
          message: 'A new verification code has been sent to ${widget.email}',
          type: FeedbackType.otp,
        );
      } else {
        CustomFeedbackPopup.show(
          context,
          title: 'Resend Failed',
          message: result['message'] ?? 'Unable to resend OTP. Please try again later.',
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
      appBar: AppBar(
        title: const Text('Verification'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppTheme.colors.primary),
        titleTextStyle: TextStyle(
          color: AppTheme.colors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: AppTheme.colors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'We have sent a verification code to\n${widget.email}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.colors.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // OTP Input Field
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.colors.jobCardSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 16,
                      color: AppTheme.colors.primary,
                    ),
                    maxLength: 6,
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      hintText: "000000",
                      hintStyle: TextStyle(
                        letterSpacing: 16,
                        color: Colors.black12,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 24),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                             strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
                
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        color: AppTheme.colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: _canResend ? _resendOTP : null,
                      child: Text(
                        _canResend ? 'Resend' : 'Resend in ${_start}s',
                        style: TextStyle(
                          color: _canResend ? AppTheme.colors.primary : Colors.grey,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
