import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/school_model.dart';
import 'package:mobile_app/services/dashboard_service.dart';
import 'package:mobile_app/utils/business_rules.dart';

void main() {
  group('District Frontend Filtering Unit Tests with Business Rules', () {
    late List<SchoolDashboardData> testSchools;

    setUp(() {
      testSchools = [
        SchoolDashboardData(
          school: SchoolModel(
            schoolId: 'SCH001',
            name: 'Apex Academy Jaipur',
            address: 'Malviya Nagar, Jaipur',
            districtId: 'DIST001',
            studentCount: 1200,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          latestAttendancePercentage: 92.0, // Healthy (>=85%)
          weeklyAttendancePercentage: 88.0,
          monthlyAttendancePercentage: 86.0,
          feeSubmissionRate: 92.0, // Healthy (>=90%)
          feesCollected: 460000.0,
          feesPending: 40000.0,
          examStatus: 'On track',
          feedbackStatus: 'good',
        ),
        SchoolDashboardData(
          school: SchoolModel(
            schoolId: 'SCH002',
            name: 'Bright Future Public School',
            address: 'Vaishali Nagar, Jaipur',
            districtId: 'DIST001',
            studentCount: 850,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          latestAttendancePercentage: 64.0, // Critical (<75%)
          weeklyAttendancePercentage: 68.0,
          monthlyAttendancePercentage: 72.0,
          feeSubmissionRate: 45.0, // Critical (<75%)
          feesCollected: 180000.0,
          feesPending: 220000.0,
          examStatus: 'Lagging',
          feedbackStatus: 'needs_review',
        ),
        SchoolDashboardData(
          school: SchoolModel(
            schoolId: 'SCH003',
            name: 'Central Heritage School',
            address: 'Mansarovar, Jaipur',
            districtId: 'DIST001',
            studentCount: 950,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          latestAttendancePercentage: 78.0, // Warning (75-84.9%)
          weeklyAttendancePercentage: 80.0,
          monthlyAttendancePercentage: 79.0,
          feeSubmissionRate: 80.0, // Warning (75-89.9%)
          feesCollected: 400000.0,
          feesPending: 100000.0,
          examStatus: 'On track',
          feedbackStatus: 'good',
        ),
      ];
    });

    test('Attendance threshold filtering: critical (<75%) returns SCH002', () {
      final criticalSchools = testSchools
          .where((s) => ThresholdRules.evaluateAttendance(s.latestAttendancePercentage) == KPIStatus.critical)
          .toList();
      expect(criticalSchools.length, 1);
      expect(criticalSchools.first.school.schoolId, 'SCH002');
    });

    test('Attendance threshold filtering: warning (75-84.9%) returns SCH003', () {
      final warningSchools = testSchools
          .where((s) => ThresholdRules.evaluateAttendance(s.latestAttendancePercentage) == KPIStatus.warning)
          .toList();
      expect(warningSchools.length, 1);
      expect(warningSchools.first.school.schoolId, 'SCH003');
    });

    test('Attendance threshold filtering: healthy (>=85%) returns SCH001', () {
      final healthySchools = testSchools
          .where((s) => ThresholdRules.evaluateAttendance(s.latestAttendancePercentage) == KPIStatus.healthy)
          .toList();
      expect(healthySchools.length, 1);
      expect(healthySchools.first.school.schoolId, 'SCH001');
    });

    test('Fees collection rate filtering: critical (<75%) returns SCH002', () {
      final lowFeeSchools = testSchools
          .where((s) => ThresholdRules.evaluateFees(s.feeSubmissionRate) == KPIStatus.critical)
          .toList();
      expect(lowFeeSchools.length, 1);
      expect(lowFeeSchools.first.school.schoolId, 'SCH002');
    });

    test('Fees collection rate filtering: warning (75-89.9%) returns SCH003', () {
      final warningFeeSchools = testSchools
          .where((s) => ThresholdRules.evaluateFees(s.feeSubmissionRate) == KPIStatus.warning)
          .toList();
      expect(warningFeeSchools.length, 1);
      expect(warningFeeSchools.first.school.schoolId, 'SCH003');
    });

    test('Fees collection rate filtering: healthy (>=90%) returns SCH001', () {
      final healthyFeeSchools = testSchools
          .where((s) => ThresholdRules.evaluateFees(s.feeSubmissionRate) == KPIStatus.healthy)
          .toList();
      expect(healthyFeeSchools.length, 1);
      expect(healthyFeeSchools.first.school.schoolId, 'SCH001');
    });

    test('Fees sorting: pending amount descending puts SCH002 first', () {
      final sorted = List<SchoolDashboardData>.from(testSchools)
        ..sort((a, b) => b.feesPending.compareTo(a.feesPending));
      expect(sorted.first.school.schoolId, 'SCH002');
      expect(sorted.first.feesPending, 220000.0);
    });

    test('Exam status filtering: lagging/critical returns only schools with overdue exams', () {
      final laggingSchools = testSchools
          .where((s) => s.examKPIStatus == KPIStatus.critical)
          .toList();
      expect(laggingSchools.length, 1);
      expect(laggingSchools.first.school.schoolId, 'SCH002');
    });

    test('Exam status filtering: on track returns schools on schedule', () {
      final onTrackSchools = testSchools
          .where((s) => s.examKPIStatus == KPIStatus.healthy)
          .toList();
      expect(onTrackSchools.length, 2);
      expect(onTrackSchools.map((s) => s.school.schoolId), containsAll(['SCH001', 'SCH003']));
    });
  });
}

