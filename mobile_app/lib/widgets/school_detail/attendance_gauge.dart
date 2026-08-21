import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// A large semi-circular gauge widget that displays a percentage value.
/// Reuses the same CustomPainter pattern as [StatCard] but with
/// configurable dimensions and colours.
class AttendanceGauge extends StatelessWidget {
  final double percentage; // 0.0 – 100.0
  final double size;
  final Color trackColor;
  final Color fillColor;

  const AttendanceGauge({
    super.key,
    required this.percentage,
    this.size = 220,
    this.trackColor = AppColors.gaugeTrack,
    this.fillColor = const Color(0xFF4A6741),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.55,
      child: CustomPaint(
        painter: _GaugePainter(
          percentage: (percentage / 100.0).clamp(0.0, 1.0),
          trackColor: trackColor,
          fillColor: fillColor,
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color trackColor;
  final Color fillColor;

  _GaugePainter({
    required this.percentage,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 4);
    final radius = size.width / 2 - 12;
    const strokeWidth = 18.0;

    // Track arc
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      trackPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      sweepAngle,
      false,
      progressPaint,
    );

    // Knob at the tip of the progress arc
    if (percentage > 0.01) {
      final angle = pi + sweepAngle;
      final knobX = center.dx + radius * cos(angle);
      final knobY = center.dy + radius * sin(angle);
      final knobPaint = Paint()..color = const Color(0xFFDDD7CD);
      canvas.drawCircle(Offset(knobX, knobY), strokeWidth / 2 + 1, knobPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.percentage != percentage ||
      old.trackColor != trackColor ||
      old.fillColor != fillColor;
}
