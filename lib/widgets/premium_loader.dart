import 'package:flutter/material.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'dart:math' as math;

class PremiumLoader extends StatefulWidget {
  final double size;
  final Color? color;
  
  const PremiumLoader({
    super.key, 
    this.size = 50.0,
    this.color,
  });

  @override
  State<PremiumLoader> createState() => _PremiumLoaderState();
}

class _PremiumLoaderState extends State<PremiumLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring - Teal
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: CustomPaint(
                    painter: _RingPainter(
                      color: widget.color ?? AppTheme.colors.primary,
                      strokeWidth: widget.size * 0.08,
                      startAngle: 0,
                      sweepAngle: 1.5 * math.pi,
                    ),
                    size: Size(widget.size, widget.size),
                  ),
                );
              },
            ),
            // Inner Ring - Orange (moving opposite speed or direction)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                   angle: -_controller.value * 2 * math.pi,
                  child: CustomPaint(
                    painter: _RingPainter(
                      color: widget.color != null 
                          ? widget.color!.withValues(alpha: 0.7) 
                          : AppTheme.colors.secondary,
                      strokeWidth: widget.size * 0.06,
                       startAngle: 0.5,
                      sweepAngle: math.pi,
                    ),
                    size: Size(widget.size * 0.65, widget.size * 0.65),
                  ),
                );
              },
            ),
            // Center Dot or Logo placeholder
            Container(
              width: widget.size * 0.2,
              height: widget.size * 0.2,
              decoration: BoxDecoration(
                color: widget.color ?? AppTheme.colors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  _RingPainter({
    required this.color, 
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
