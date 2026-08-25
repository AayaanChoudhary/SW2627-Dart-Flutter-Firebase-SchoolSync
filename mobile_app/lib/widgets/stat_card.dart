import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final double? percentage;
  final bool isArrow;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.percentage,
    this.isArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 175,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2DCCE), width: 1),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 10,
                color: Color(0x22000000),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            if (isArrow) ...[
              const SizedBox(height: 8),
              Builder(builder: (context) {
                final isLagging = value.toLowerCase().contains('lagging');
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isLagging ? const Color(0xFFFDEEF0) : const Color(0xFFEBF3E8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLagging ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    size: 26,
                    color: isLagging ? const Color(0xFFB54C5D) : const Color(0xFF4A6B43),
                  ),
                );
              }),
              const SizedBox(height: 4),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ] else if (percentage != null) ...[
              SizedBox(
                width: 70,
                height: 45,
                child: CustomPaint(
                  painter: _SemiCircularGaugePainter(percentage: percentage!),
                ),
              ),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _SemiCircularGaugePainter extends CustomPainter {
  final double percentage;

  _SemiCircularGaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 2);
    final radius = size.width / 2 - 6;

    final trackPaint = Paint()
      ..color = const Color(0xFFE2DCCE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = const Color(0xFF372B20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      trackPaint,
    );

    // Draw progress arc
    final sweepAngle = pi * percentage.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SemiCircularGaugePainter oldDelegate) =>
      oldDelegate.percentage != percentage;
}