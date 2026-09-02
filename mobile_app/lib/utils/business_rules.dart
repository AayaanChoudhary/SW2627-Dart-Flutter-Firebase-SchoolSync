import 'package:flutter/material.dart';
import '../models/exam_model.dart';

/// Standard 3-tier operational health status for school KPIs and alerts.
enum KPIStatus {
  healthy,
  warning,
  critical;

  String get label {
    switch (this) {
      case KPIStatus.healthy:
        return 'Healthy';
      case KPIStatus.warning:
        return 'Warning';
      case KPIStatus.critical:
        return 'Critical';
    }
  }

  /// Primary indicator color
  Color get color {
    switch (this) {
      case KPIStatus.healthy:
        return const Color(0xFF4A6741); // Forest green
      case KPIStatus.warning:
        return const Color(0xFFCBB158); // Amber gold
      case KPIStatus.critical:
        return const Color(0xFFC98591); // Crimson red
    }
  }

  /// Solid badge / button fill color
  Color get solidColor {
    switch (this) {
      case KPIStatus.healthy:
        return const Color(0xFF8FA57C);
      case KPIStatus.warning:
        return const Color(0xFFD4A359);
      case KPIStatus.critical:
        return const Color(0xFFC98591);
    }
  }

  /// Light background tint for pills and cards
  Color get backgroundColor {
    switch (this) {
      case KPIStatus.healthy:
        return const Color(0xFFE8F0E5);
      case KPIStatus.warning:
        return const Color(0xFFFFF9E6);
      case KPIStatus.critical:
        return const Color(0xFFFAEAED);
    }
  }

  /// Border color for alert outlines
  Color get borderColor {
    switch (this) {
      case KPIStatus.healthy:
        return const Color(0xFFC8DEC2);
      case KPIStatus.warning:
        return const Color(0xFFF0E0B0);
      case KPIStatus.critical:
        return const Color(0xFFE0BAC0);
    }
  }

  /// Associated status icon
  IconData get icon {
    switch (this) {
      case KPIStatus.healthy:
        return Icons.check_circle_outline_rounded;
      case KPIStatus.warning:
        return Icons.warning_amber_rounded;
      case KPIStatus.critical:
        return Icons.error_outline_rounded;
    }
  }

  /// Severity rank (0 = lowest risk, 2 = highest risk)
  int get severity {
    switch (this) {
      case KPIStatus.healthy:
        return 0;
      case KPIStatus.warning:
        return 1;
      case KPIStatus.critical:
        return 2;
    }
  }
}

/// Structured operational alert generated from KPI threshold violations.
class OperationalAlert {
  final String title;
  final String message;
  final KPIStatus status;
  final String metricType; // 'attendance', 'fees', 'exams'

  const OperationalAlert({
    required this.title,
    required this.message,
    required this.status,
    required this.metricType,
  });
}

/// Pure business rules engine for KPI threshold evaluation and alert generation.
///
/// Workflow:
/// School Data ──> Calculate KPIs ──> Compare against Thresholds ──> Generate Status & Alerts
class ThresholdRules {
  const ThresholdRules._();

  // ── 1. Attendance Thresholds ─────────────────────────────────────────────
  // ≥ 85%       → Healthy
  // 75–84.9%    → Warning
  // < 75%       → Critical
  static const double attendanceHealthyThreshold = 85.0;
  static const double attendanceWarningThreshold = 75.0;

  static KPIStatus evaluateAttendance(double percentage) {
    final clamped = percentage.clamp(0.0, 100.0);
    if (clamped >= attendanceHealthyThreshold) {
      return KPIStatus.healthy;
    } else if (clamped >= attendanceWarningThreshold) {
      return KPIStatus.warning;
    } else {
      return KPIStatus.critical;
    }
  }

  // ── 2. Fees Submission Rate Thresholds ───────────────────────────────────
  // ≥ 90%       → Healthy
  // 75–89.9%    → Warning
  // < 75%       → Critical
  static const double feeHealthyThreshold = 90.0;
  static const double feeWarningThreshold = 75.0;

  static KPIStatus evaluateFees(double submissionRate) {
    final clamped = submissionRate.clamp(0.0, 100.0);
    if (clamped >= feeHealthyThreshold) {
      return KPIStatus.healthy;
    } else if (clamped >= feeWarningThreshold) {
      return KPIStatus.warning;
    } else {
      return KPIStatus.critical;
    }
  }

  // ── 3. Exams Timeline Thresholds ─────────────────────────────────────────
  // On schedule           → Healthy (No overdue, no exams within approaching window)
  // Approaching deadline  → Warning (Any scheduled exam within approaching window, e.g. 3 days)
  // Overdue               → Critical (Any scheduled exam past due date)
  static const int examApproachingWindowDays = 3;

  static ({
    KPIStatus status,
    int overdueCount,
    int approachingCount,
    int onScheduleCount,
  }) evaluateExams(
    List<ExamModel> exams, {
    DateTime? targetDate,
  }) {
    final now = targetDate ?? DateTime.now();
    final approachingLimit = now.add(const Duration(days: examApproachingWindowDays));

    int overdueCount = 0;
    int approachingCount = 0;
    int onScheduleCount = 0;

    for (final exam in exams) {
      if (exam.status == 'cancelled' || exam.status == 'completed') {
        continue;
      }

      if (exam.scheduledDate.isBefore(now)) {
        overdueCount++;
      } else if (!exam.scheduledDate.isAfter(approachingLimit)) {
        approachingCount++;
      } else {
        onScheduleCount++;
      }
    }

    KPIStatus status;
    if (overdueCount > 0) {
      status = KPIStatus.critical;
    } else if (approachingCount > 0) {
      status = KPIStatus.warning;
    } else {
      status = KPIStatus.healthy;
    }

    return (
      status: status,
      overdueCount: overdueCount,
      approachingCount: approachingCount,
      onScheduleCount: onScheduleCount,
    );
  }

  // ── 4. Composite School Health Status ────────────────────────────────────
  /// Computes the overall operational status for a school by aggregating
  /// its Attendance, Fee, and Exam KPI statuses based on maximum severity.
  static KPIStatus evaluateSchoolStatus({
    required KPIStatus attendanceStatus,
    required KPIStatus feeStatus,
    required KPIStatus examStatus,
  }) {
    if (attendanceStatus == KPIStatus.critical ||
        feeStatus == KPIStatus.critical ||
        examStatus == KPIStatus.critical) {
      return KPIStatus.critical;
    }
    if (attendanceStatus == KPIStatus.warning ||
        feeStatus == KPIStatus.warning ||
        examStatus == KPIStatus.warning) {
      return KPIStatus.warning;
    }
    return KPIStatus.healthy;
  }

  // ── 5. Alert Generation Foundation ───────────────────────────────────────
  /// Generates human-readable, actionable alerts for a school based on KPI
  /// threshold violations.
  static List<OperationalAlert> generateSchoolAlerts({
    required double attendancePercentage,
    required double feeSubmissionRate,
    required double feesPending,
    required KPIStatus examStatus,
    int overdueExamsCount = 0,
    int approachingExamsCount = 0,
  }) {
    final List<OperationalAlert> alerts = [];

    // Attendance alerts
    final attStatus = evaluateAttendance(attendancePercentage);
    if (attStatus == KPIStatus.critical) {
      alerts.add(OperationalAlert(
        title: 'Critical Attendance Drop',
        message:
            'Attendance is at ${attendancePercentage.toStringAsFixed(1)}% (below critical threshold of ${attendanceWarningThreshold.toStringAsFixed(0)}%).',
        status: KPIStatus.critical,
        metricType: 'attendance',
      ));
    } else if (attStatus == KPIStatus.warning) {
      alerts.add(OperationalAlert(
        title: 'Attendance Warning',
        message:
            'Attendance is at ${attendancePercentage.toStringAsFixed(1)}% (below healthy target of ${attendanceHealthyThreshold.toStringAsFixed(0)}%).',
        status: KPIStatus.warning,
        metricType: 'attendance',
      ));
    }

    // Fee alerts
    final fStatus = evaluateFees(feeSubmissionRate);
    if (fStatus == KPIStatus.critical && feesPending > 0) {
      alerts.add(OperationalAlert(
        title: 'Critical Fee Deficit',
        message:
            'Collection rate is ${feeSubmissionRate.toStringAsFixed(1)}% (below critical threshold of ${feeWarningThreshold.toStringAsFixed(0)}%).',
        status: KPIStatus.critical,
        metricType: 'fees',
      ));
    } else if (fStatus == KPIStatus.warning && feesPending > 0) {
      alerts.add(OperationalAlert(
        title: 'Fee Collection Lag',
        message:
            'Collection rate is ${feeSubmissionRate.toStringAsFixed(1)}% (below target of ${feeHealthyThreshold.toStringAsFixed(0)}%).',
        status: KPIStatus.warning,
        metricType: 'fees',
      ));
    }

    // Exam alerts
    if (overdueExamsCount > 0) {
      alerts.add(OperationalAlert(
        title: 'Overdue Exams',
        message:
            '$overdueExamsCount ${overdueExamsCount == 1 ? 'exam is' : 'exams are'} overdue and past scheduled timeline.',
        status: KPIStatus.critical,
        metricType: 'exams',
      ));
    } else if (approachingExamsCount > 0) {
      alerts.add(OperationalAlert(
        title: 'Approaching Exam Deadlines',
        message:
            '$approachingExamsCount ${approachingExamsCount == 1 ? 'exam has' : 'exams have'} deadlines approaching within $examApproachingWindowDays days.',
        status: KPIStatus.warning,
        metricType: 'exams',
      ));
    }

    return alerts;
  }
}
