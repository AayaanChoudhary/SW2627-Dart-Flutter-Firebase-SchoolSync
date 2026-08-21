import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// A row of pill-shaped toggle buttons. The selected option is filled dark;
/// others show a dashed/outlined border.
class PillToggle extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const PillToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (i) {
        final isSelected = i == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                left: i == 0 ? 0 : 6,
                right: i == options.length - 1 ? 0 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.text : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.text
                      : const Color(0xFFCBC5B8),
                  width: 1.5,
                ),
              ),
              child: Text(
                options[i].toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppColors.card : AppColors.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
