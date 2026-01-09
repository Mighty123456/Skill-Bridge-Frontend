import 'package:flutter/material.dart';
import '../shared/themes/app_theme.dart';
import 'dart:ui';

enum FeedbackType { success, error, info, otp }

class CustomFeedbackPopup extends StatefulWidget {
  final String title;
  final String message;
  final FeedbackType type;
  final VoidCallback? onConfirm;

  const CustomFeedbackPopup({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.onConfirm,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required FeedbackType type,
    VoidCallback? onConfirm,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: ScaleTransition(
            scale: curve,
            child: Opacity(
              opacity: anim1.value,
              child: CustomFeedbackPopup(
                title: title,
                message: message,
                type: type,
                onConfirm: onConfirm,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  State<CustomFeedbackPopup> createState() => _CustomFeedbackPopupState();
}

class _CustomFeedbackPopupState extends State<CustomFeedbackPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconAnimationController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotateAnimation;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _iconScaleAnimation = CurvedAnimation(
      parent: _iconAnimationController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );

    _iconRotateAnimation = Tween<double>(begin: -0.2, end: 0).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _iconAnimationController.forward();
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    IconData iconData;
    List<Color> gradientColors;

    switch (widget.type) {
      case FeedbackType.success:
        primaryColor = AppTheme.colors.success;
        iconData = Icons.check_circle_rounded;
        gradientColors = [const Color(0xFF66BB6A), const Color(0xFF43A047)];
        break;
      case FeedbackType.error:
        primaryColor = AppTheme.colors.error;
        iconData = Icons.error_rounded;
        gradientColors = [const Color(0xFFEF5350), const Color(0xFFD32F2F)];
        break;
      case FeedbackType.info:
        primaryColor = AppTheme.colors.info;
        iconData = Icons.info_rounded;
        gradientColors = [const Color(0xFF42A5F5), const Color(0xFF1976D2)];
        break;
      case FeedbackType.otp:
        primaryColor = AppTheme.colors.secondary;
        iconData = Icons.mark_email_read_rounded;
        gradientColors = [const Color(0xFFFF8C66), const Color(0xFFFF6B35)];
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Card
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.15),
                  blurRadius: 30.0,
                  offset: const Offset(0.0, 15.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.colors.onSurface,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.colors.onSurface.withValues(alpha: 0.6),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (widget.onConfirm != null) {
                        widget.onConfirm!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Floating Icon
          Positioned(
            top: -40,
            child: ScaleTransition(
              scale: _iconScaleAnimation,
              child: RotationTransition(
                turns: _iconRotateAnimation,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
