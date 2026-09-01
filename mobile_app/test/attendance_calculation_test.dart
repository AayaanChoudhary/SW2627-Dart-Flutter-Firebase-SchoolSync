import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/attendance_model.dart';
import 'package:mobile_app/utils/attendance_calculator.dart';

void main() {
  group('AttendanceCalculator Date-Bounded Calculations', () {
    // Reference date: Wednesday, August 19, 2026
    // Monday of this week: 2026-08-17 00:00:00
    // Sunday of this week: 2026-08-23 23:59:59.999
    // Month Start: 2026-08-01 00:00:00
    // Month End: 2026-08-31 23:59:59.999
    final targetDate = DateTime(2026, 8, 19, 14, 30);

    test('getWeekDateRange computes exact Monday 00:00:00 to Sunday 23:59:59.999', () {
      final range = AttendanceCalculator.getWeekDateRange(targetDate);
      expect(range.start, DateTime(2026, 8, 17, 0, 0, 0, 0));
      expect(range.end, DateTime(2026, 8, 23, 23, 59, 59, 999));
    });

    test('getMonthDateRange computes exact 1st 00:00:00 to last day 23:59:59.999', () {
      final range = AttendanceCalculator.getMonthDateRange(targetDate);
      expect(range.start, DateTime(2026, 8, 1, 0, 0, 0, 0));
      expect(range.end, DateTime(2026, 8, 31, 23, 59, 59, 999));
    });

    test('getMonthDateRange handles February in leap and non-leap years correctly', () {
      // Leap year 2028 (Feb has 29 days)
      final leapFeb = AttendanceCalculator.getMonthDateRange(DateTime(2028, 2, 10));
      expect(leapFeb.start, DateTime(2028, 2, 1, 0, 0, 0, 0));
      expect(leapFeb.end, DateTime(2028, 2, 29, 23, 59, 59, 999));

      // Non-leap year 2026 (Feb has 28 days)
      final nonLeapFeb = AttendanceCalculator.getMonthDateRange(DateTime(2026, 2, 10));
      expect(nonLeapFeb.start, DateTime(2026, 2, 1, 0, 0, 0, 0));
      expect(nonLeapFeb.end, DateTime(2026, 2, 28, 23, 59, 59, 999));
    });

    AttendanceModel makeRecord(String date, double pct) {
      return AttendanceModel(
        documentId: 'ATT_$date',
        attendancePercentage: pct,
        date: date,
        status: 'submitted',
        submittedBy: 'USR001',
        createdAt: DateTime.parse('$date 09:00:00'),
        updatedAt: DateTime.parse('$date 09:00:00'),
      );
    }

    test('Weekly attendance averages only records strictly within Monday-Sunday', () {
      final records = [
        makeRecord('2026-08-16', 50.0), // Sunday before week -> EXCLUDED
        makeRecord('2026-08-17', 90.0), // Monday -> INCLUDED
        makeRecord('2026-08-18', 80.0), // Tuesday -> INCLUDED
        makeRecord('2026-08-19', 100.0), // Wednesday -> INCLUDED
        makeRecord('2026-08-23', 90.0), // Sunday of this week -> INCLUDED
        makeRecord('2026-08-24', 40.0), // Monday next week -> EXCLUDED
      ];

      final weeklyAvg = AttendanceCalculator.calculateWeeklyAttendance(
        records,
        targetDate: targetDate,
      );

      // (90 + 80 + 100 + 90) / 4 = 360 / 4 = 90.0%
      expect(weeklyAvg, 90.0);
      expect(AttendanceCalculator.getWeeklyRecordCount(records, targetDate: targetDate), 4);
    });

    test('Monthly attendance averages only records strictly within 1st to last day of month', () {
      final records = [
        makeRecord('2026-07-31', 40.0), // Previous month -> EXCLUDED
        makeRecord('2026-08-01', 80.0), // First day -> INCLUDED
        makeRecord('2026-08-15', 90.0), // Mid-month -> INCLUDED
        makeRecord('2026-08-31', 70.0), // Last day -> INCLUDED
        makeRecord('2026-09-01', 30.0), // Next month -> EXCLUDED
      ];

      final monthlyAvg = AttendanceCalculator.calculateMonthlyAttendance(
        records,
        targetDate: targetDate,
      );

      // (80 + 90 + 70) / 3 = 240 / 3 = 80.0%
      expect(monthlyAvg, 80.0);
      expect(AttendanceCalculator.getMonthlyRecordCount(records, targetDate: targetDate), 3);
    });

    test('Missing days in a week/month do not pull down metric as 0%', () {
      // Only 2 days reported this week (e.g. Mon, Tue)
      final records = [
        makeRecord('2026-08-17', 90.0), // Monday
        makeRecord('2026-08-18', 92.0), // Tuesday
      ];

      final weeklyAvg = AttendanceCalculator.calculateWeeklyAttendance(
        records,
        targetDate: targetDate,
      );

      // Should average only the 2 submitted days: (90 + 92) / 2 = 91.0
      expect(weeklyAvg, 91.0);
    });

    test('Empty records list returns 0.0 without division by zero errors', () {
      final weeklyAvg = AttendanceCalculator.calculateWeeklyAttendance(
        [],
        targetDate: targetDate,
      );
      final monthlyAvg = AttendanceCalculator.calculateMonthlyAttendance(
        [],
        targetDate: targetDate,
      );
      expect(weeklyAvg, 0.0);
      expect(monthlyAvg, 0.0);
    });

    test('Records completely outside the date range return 0.0', () {
      final oldRecords = [
        makeRecord('2026-01-01', 95.0),
        makeRecord('2026-01-02', 96.0),
      ];

      final weeklyAvg = AttendanceCalculator.calculateWeeklyAttendance(
        oldRecords,
        targetDate: targetDate,
      );
      final monthlyAvg = AttendanceCalculator.calculateMonthlyAttendance(
        oldRecords,
        targetDate: targetDate,
      );

      expect(weeklyAvg, 0.0);
      expect(monthlyAvg, 0.0);
    });

    test('getDailyAttendance returns target date record or defaults to latest', () {
      final records = [
        makeRecord('2026-08-19', 88.0),
        makeRecord('2026-08-18', 84.0),
      ];

      expect(
        AttendanceCalculator.getDailyAttendance(records, targetDate: DateTime(2026, 8, 18)),
        84.0,
      );
      expect(
        AttendanceCalculator.getDailyAttendance(records),
        88.0,
      );
    });
  });
}
