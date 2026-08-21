import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Uppercase spaced section-header label used across detail tabs.
class SectionHeader extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final double letterSpacing;

  const SectionHeader({
    super.key,
    required this.text,
    this.color = AppColors.secondaryText,
    this.fontSize = 11,
    this.letterSpacing = 1.6,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
