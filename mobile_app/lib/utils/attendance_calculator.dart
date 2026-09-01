import '../models/attendance_model.dart';

/// Pure utility class for computing date-bounded attendance metrics.
///
/// Ensures strict calendar boundaries:
/// - Weekly: Current week's Monday 00:00:00 through Sunday 23:59:59.999
/// - Monthly: Current month's 1st day 00:00:00 through last day 23:59:59.999
///
/// Missing daily attendance records are treated as "no data" rather than 0%,
/// and averages are calculated only from valid records whose dates fall inside
/// the specified boundaries.
class AttendanceCalculator {
  const AttendanceCalculator._();

  /// Returns the start (Monday 00:00:00) and end (Sunday 23:59:59.999) of the week for [date].
  static ({DateTime start, DateTime end}) getWeekDateRange([DateTime? date]) {
    final target = date ?? DateTime.now();
    // Dart: Monday is weekday 1, Sunday is weekday 7
    final weekStart = DateTime(
      target.year,
      target.month,
      target.day - (target.weekday - 1),
      0,
      0,
      0,
      0,
    );
    final weekEnd = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 6,
      23,
      59,
      59,
      999,
    );
    return (start: weekStart, end: weekEnd);
  }

  /// Returns the start (1st 00:00:00) and end (last day 23:59:59.999) of the month for [date].
  static ({DateTime start, DateTime end}) getMonthDateRange([DateTime? date]) {
    final target = date ?? DateTime.now();
    final monthStart = DateTime(target.year, target.month, 1, 0, 0, 0, 0);
    // Day 0 of month + 1 resolves to the last day of the current month (handles 28, 29, 30, 31 days)
    final monthEnd = DateTime(target.year, target.month + 1, 0, 23, 59, 59, 999);
    return (start: monthStart, end: monthEnd);
  }

  /// Safely extracts the calendar date for an [AttendanceModel] record.
  static DateTime parseRecordDate(AttendanceModel record) {
    final parsed = DateTime.tryParse(record.date);
    if (parsed != null) {
      return DateTime(parsed.year, parsed.month, parsed.day);
    }
    return DateTime(
      record.createdAt.year,
      record.createdAt.month,
      record.createdAt.day,
    );
  }

  /// Checks whether [recordDate] falls within [start] and [end] inclusive.
  static bool isDateInRange(DateTime recordDate, DateTime start, DateTime end) {
    return (recordDate.isAfter(start) || recordDate.isAtSameMomentAs(start)) &&
        (recordDate.isBefore(end) || recordDate.isAtSameMomentAs(end));
  }

  /// Filters records that fall strictly within [startDate] and [endDate].
  static List<AttendanceModel> filterRecordsByDateRange(
    List<AttendanceModel> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    return records.where((r) {
      final date = parseRecordDate(r);
      return isDateInRange(date, startDate, endDate);
    }).toList();
  }

  /// Computes the arithmetic mean percentage of records whose dates fall strictly
  /// within Monday 00:00:00 to Sunday 23:59:59.999 of the target week.
  ///
  /// Returns 0.0 if no records fall in this date range.
  static double calculateWeeklyAttendance(
    List<AttendanceModel> records, {
    DateTime? targetDate,
  }) {
    final range = getWeekDateRange(targetDate);
    final weeklyRecords = filterRecordsByDateRange(records, range.start, range.end);

    if (weeklyRecords.isEmpty) return 0.0;

    final sum = weeklyRecords
        .map((r) => r.attendancePercentage.clamp(0.0, 100.0))
        .reduce((a, b) => a + b);
    return sum / weeklyRecords.length;
  }

  /// Computes the arithmetic mean percentage of records whose dates fall strictly
  /// within the 1st day 00:00:00 to the last day 23:59:59.999 of the target month.
  ///
  /// Returns 0.0 if no records fall in this date range.
  static double calculateMonthlyAttendance(
    List<AttendanceModel> records, {
    DateTime? targetDate,
  }) {
    final range = getMonthDateRange(targetDate);
    final monthlyRecords = filterRecordsByDateRange(records, range.start, range.end);

    if (monthlyRecords.isEmpty) return 0.0;

    final sum = monthlyRecords
        .map((r) => r.attendancePercentage.clamp(0.0, 100.0))
        .reduce((a, b) => a + b);
    return sum / monthlyRecords.length;
  }

  /// Returns the latest recorded attendance, or the attendance specifically for [targetDate].
  static double getDailyAttendance(
    List<AttendanceModel> records, {
    DateTime? targetDate,
  }) {
    if (records.isEmpty) return 0.0;

    if (targetDate != null) {
      final targetDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      for (final r in records) {
        final d = parseRecordDate(r);
        if (d.isAtSameMomentAs(targetDay)) {
          return r.attendancePercentage.clamp(0.0, 100.0);
        }
      }
    }

    // Default to the first (most recent) record
    return records.first.attendancePercentage.clamp(0.0, 100.0);
  }

  /// Returns the count of valid recorded attendance days within the target week.
  static int getWeeklyRecordCount(
    List<AttendanceModel> records, {
    DateTime? targetDate,
  }) {
    final range = getWeekDateRange(targetDate);
    return filterRecordsByDateRange(records, range.start, range.end).length;
  }

  /// Returns the count of valid recorded attendance days within the target month.
  static int getMonthlyRecordCount(
    List<AttendanceModel> records, {
    DateTime? targetDate,
  }) {
    final range = getMonthDateRange(targetDate);
    return filterRecordsByDateRange(records, range.start, range.end).length;
  }
}
