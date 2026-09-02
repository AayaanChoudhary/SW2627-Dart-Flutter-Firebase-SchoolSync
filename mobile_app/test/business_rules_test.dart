import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/exam_model.dart';
import 'package:mobile_app/utils/business_rules.dart';

void main() {
  group('Business Rules Engine & KPI Threshold Tests', () {
    // ── 1. Attendance Thresholds ─────────────────────────────────────────────
    group('Attendance Thresholds (>=85% Healthy, 75-84.9% Warning, <75% Critical)', () {
      test('Attendance >= 85.0% returns Healthy', () {
        expect(ThresholdRules.evaluateAttendance(100.0), KPIStatus.healthy);
        expect(ThresholdRules.evaluateAttendance(92.5), KPIStatus.healthy);
        expect(ThresholdRules.evaluateAttendance(85.0), KPIStatus.healthy);
      });

      test('Attendance 75.0% - 84.99% returns Warning', () {
        expect(ThresholdRules.evaluateAttendance(84.99), KPIStatus.warning);
        expect(ThresholdRules.evaluateAttendance(80.0), KPIStatus.warning);
        expect(ThresholdRules.evaluateAttendance(75.0), KPIStatus.warning);
      });

      test('Attendance < 75.0% returns Critical', () {
        expect(ThresholdRules.evaluateAttendance(74.99), KPIStatus.critical);
        expect(ThresholdRules.evaluateAttendance(60.0), KPIStatus.critical);
        expect(ThresholdRules.evaluateAttendance(0.0), KPIStatus.critical);
      });
    });

    // ── 2. Fees Thresholds ───────────────────────────────────────────────────
    group('Fees Thresholds (>=90% Healthy, 75-89.9% Warning, <75% Critical)', () {
      test('Fees Submission Rate >= 90.0% returns Healthy', () {
        expect(ThresholdRules.evaluateFees(100.0), KPIStatus.healthy);
        expect(ThresholdRules.evaluateFees(95.0), KPIStatus.healthy);
        expect(ThresholdRules.evaluateFees(90.0), KPIStatus.healthy);
      });

      test('Fees Submission Rate 75.0% - 89.99% returns Warning', () {
        expect(ThresholdRules.evaluateFees(89.99), KPIStatus.warning);
        expect(ThresholdRules.evaluateFees(82.0), KPIStatus.warning);
        expect(ThresholdRules.evaluateFees(75.0), KPIStatus.warning);
      });

      test('Fees Submission Rate < 75.0% returns Critical', () {
        expect(ThresholdRules.evaluateFees(74.99), KPIStatus.critical);
        expect(ThresholdRules.evaluateFees(50.0), KPIStatus.critical);
        expect(ThresholdRules.evaluateFees(0.0), KPIStatus.critical);
      });
    });

    // ── 3. Exams Timeline Thresholds ─────────────────────────────────────────
    group('Exams Timeline Thresholds (On Schedule / Approaching / Overdue)', () {
      final now = DateTime(2026, 8, 20, 10, 0);

      ExamModel makeExam({
        required String id,
        required DateTime date,
        String status = 'scheduled',
      }) {
        return ExamModel(
          examId: id,
          examName: 'Test Exam $id',
          subject: 'Math',
          classNumber: 10,
          scheduledDate: date,
          status: status,
          createdAt: now.subtract(const Duration(days: 10)),
          updatedAt: now.subtract(const Duration(days: 10)),
        );
      }

      test('Overdue exam generates Critical status', () {
        final exams = [
          makeExam(id: 'E1', date: now.subtract(const Duration(days: 2))), // Overdue
          makeExam(id: 'E2', date: now.add(const Duration(days: 10))),
        ];

        final eval = ThresholdRules.evaluateExams(exams, targetDate: now);
        expect(eval.status, KPIStatus.critical);
        expect(eval.overdueCount, 1);
      });

      test('Exam within 3 days (approaching deadline) generates Warning status', () {
        final exams = [
          makeExam(id: 'E1', date: now.add(const Duration(days: 2))), // Approaching
          makeExam(id: 'E2', date: now.add(const Duration(days: 14))),
        ];

        final eval = ThresholdRules.evaluateExams(exams, targetDate: now);
        expect(eval.status, KPIStatus.warning);
        expect(eval.approachingCount, 1);
        expect(eval.overdueCount, 0);
      });

      test('All exams > 3 days away or completed generate Healthy status', () {
        final exams = [
          makeExam(id: 'E1', date: now.subtract(const Duration(days: 5)), status: 'completed'),
          makeExam(id: 'E2', date: now.add(const Duration(days: 7))),
        ];

        final eval = ThresholdRules.evaluateExams(exams, targetDate: now);
        expect(eval.status, KPIStatus.healthy);
        expect(eval.onScheduleCount, 1);
        expect(eval.overdueCount, 0);
        expect(eval.approachingCount, 0);
      });
    });

    // ── 4. Composite School Status Evaluation ────────────────────────────────
    group('Composite School Health Status Aggregation', () {
      test('Any Critical KPI results in Overall Critical', () {
        final status = ThresholdRules.evaluateSchoolStatus(
          attendanceStatus: KPIStatus.critical,
          feeStatus: KPIStatus.healthy,
          examStatus: KPIStatus.healthy,
        );
        expect(status, KPIStatus.critical);
      });

      test('Any Warning KPI without Critical results in Overall Warning', () {
        final status = ThresholdRules.evaluateSchoolStatus(
          attendanceStatus: KPIStatus.warning,
          feeStatus: KPIStatus.healthy,
          examStatus: KPIStatus.healthy,
        );
        expect(status, KPIStatus.warning);
      });

      test('All Healthy KPIs result in Overall Healthy', () {
        final status = ThresholdRules.evaluateSchoolStatus(
          attendanceStatus: KPIStatus.healthy,
          feeStatus: KPIStatus.healthy,
          examStatus: KPIStatus.healthy,
        );
        expect(status, KPIStatus.healthy);
      });
    });

    // ── 5. Actionable Alert Generation Foundation ────────────────────────────
    group('Alert Generation Foundation', () {
      test('Generates structured alerts for threshold violations', () {
        final alerts = ThresholdRules.generateSchoolAlerts(
          attendancePercentage: 68.0, // Critical
          feeSubmissionRate: 80.0, // Warning
          feesPending: 50000.0,
          examStatus: KPIStatus.critical,
          overdueExamsCount: 2,
        );

        expect(alerts.length, 3);
        expect(alerts.any((a) => a.metricType == 'attendance' && a.status == KPIStatus.critical), isTrue);
        expect(alerts.any((a) => a.metricType == 'fees' && a.status == KPIStatus.warning), isTrue);
        expect(alerts.any((a) => a.metricType == 'exams' && a.status == KPIStatus.critical), isTrue);
      });

      test('Generates empty alerts list for all healthy metrics', () {
        final alerts = ThresholdRules.generateSchoolAlerts(
          attendancePercentage: 92.0,
          feeSubmissionRate: 95.0,
          feesPending: 0.0,
          examStatus: KPIStatus.healthy,
        );

        expect(alerts.isEmpty, isTrue);
      });
    });
  });
}
