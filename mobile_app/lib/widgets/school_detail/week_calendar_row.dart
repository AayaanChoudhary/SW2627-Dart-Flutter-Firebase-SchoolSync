import 'package:flutter/material.dart';
import '../../models/attendance_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/attendance_calculator.dart';

/// Renders the M T W T F S S weekly calendar row.
/// Each cell shows a green ✓ (attendance present), pink – (absent/weekend),
/// or a light grey box (no data / future date).
class WeekCalendarRow extends StatelessWidget {
  final List<AttendanceModel> attendanceRecords;

  const WeekCalendarRow({super.key, required this.attendanceRecords});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Monday 00:00 of the current week
    final monday = AttendanceCalculator.getWeekDateRange(now).start;

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Build a set of YYYY-MM-DD keys that have an attendance record
    final recordedDates = <String, double>{};
    for (final r in attendanceRecords) {
      recordedDates[r.date] = r.attendancePercentage;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final dateKey =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        final isWeekend = i >= 5;
        final isFuture = day.isAfter(now);
        final hasRecord = recordedDates.containsKey(dateKey);
        final pct = recordedDates[dateKey] ?? 0.0;
        final isPresent = hasRecord && pct > 0;

        Color bgColor;
        Widget icon;

        if (isWeekend || (!hasRecord && isFuture)) {
          // Weekend or future day — neutral dash
          bgColor = const Color(0xFFF5EFE6);
          icon = const Icon(Icons.remove, size: 14, color: Color(0xFFB8AFA5));
        } else if (isPresent) {
          bgColor = const Color(0xFFE8F0E5);
          icon = const Icon(Icons.check, size: 14, color: Color(0xFF4A6741));
        } else {
          // Past day with no / zero attendance
          bgColor = const Color(0xFFFAEAED);
          icon = const Icon(Icons.remove, size: 14, color: Color(0xFFC98591));
        }

        return Column(
          children: [
            Text(
              dayLabels[i],
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isPresent
                      ? const Color(0xFFB5CEAD)
                      : isWeekend || isFuture
                          ? const Color(0xFFE2DCCE)
                          : const Color(0xFFE0BAC0),
                  width: 1,
                ),
              ),
              child: Center(child: icon),
            ),
          ],
        );
      }),
    );
  }
}
