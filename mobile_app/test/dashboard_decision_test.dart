import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/school_model.dart';
import 'package:mobile_app/services/dashboard_service.dart';
import 'package:mobile_app/utils/business_rules.dart';

void main() {
  group('Dashboard Decision-Making & Risk Triage Tests with Business Rules', () {
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
          latestAttendancePercentage: 94.0, // Healthy (>=85%)
          weeklyAttendancePercentage: 92.0,
          monthlyAttendancePercentage: 91.0,
          feeSubmissionRate: 95.0, // Healthy (>=90%)
          feesCollected: 475000.0,
          feesPending: 25000.0,
          examStatus: 'On track', // Healthy
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
          weeklyAttendancePercentage: 66.0,
          monthlyAttendancePercentage: 68.0,
          feeSubmissionRate: 40.0, // Critical (<75%)
          feesCollected: 160000.0,
          feesPending: 240000.0,
          examStatus: 'Lagging', // Critical
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
          latestAttendancePercentage: 82.0, // Warning (75-84.9%)
          weeklyAttendancePercentage: 81.0,
          monthlyAttendancePercentage: 80.0,
          feeSubmissionRate: 80.0, // Warning (75-89.9%)
          feesCollected: 400000.0,
          feesPending: 100000.0,
          examStatus: 'On track', // Healthy
          feedbackStatus: 'good',
        ),
      ];
    });

    test('Needs Attention filter isolates all high-risk and warning schools', () {
      final needsAttention = testSchools.where((s) => s.overallStatus != KPIStatus.healthy).toList();

      expect(needsAttention.length, 2);
      expect(needsAttention.map((s) => s.school.schoolId), containsAll(['SCH002', 'SCH003']));
    });

    test('Critical attendance triage identifies schools below 75%', () {
      final critical = testSchools
          .where((s) => s.attendanceStatus == KPIStatus.critical)
          .toList();
      expect(critical.length, 1);
      expect(critical.first.school.name, 'Bright Future Public School');
      expect(critical.first.latestAttendancePercentage, 64.0);
    });

    test('Warning attendance triage identifies schools between 75% and 84.9%', () {
      final warning = testSchools
          .where((s) => s.attendanceStatus == KPIStatus.warning)
          .toList();
      expect(warning.length, 1);
      expect(warning.first.school.schoolId, 'SCH003');
      expect(warning.first.latestAttendancePercentage, 82.0);
    });

    test('Lagging exams triage identifies schools behind schedule', () {
      final lagging = testSchools
          .where((s) => s.examKPIStatus == KPIStatus.critical)
          .toList();
      expect(lagging.length, 1);
      expect(lagging.first.school.schoolId, 'SCH002');
    });

    test('Priority Risk sorting places Critical first, then Warning, then Healthy', () {
      final sorted = List<SchoolDashboardData>.from(testSchools)
        ..sort((a, b) {
          final aSev = a.overallStatus.severity;
          final bSev = b.overallStatus.severity;
          if (aSev != bSev) return bSev.compareTo(aSev); // Highest severity first
          return a.latestAttendancePercentage.compareTo(b.latestAttendancePercentage);
        });

      // SCH002 (Critical) first, SCH003 (Warning) second, SCH001 (Healthy) third
      expect(sorted[0].school.schoolId, 'SCH002');
      expect(sorted[1].school.schoolId, 'SCH003');
      expect(sorted[2].school.schoolId, 'SCH001');
    });

    test('On Track triage filter returns only healthy schools', () {
      final onTrackSchools = testSchools.where((s) => s.overallStatus == KPIStatus.healthy).toList();

      expect(onTrackSchools.length, 1);
      expect(onTrackSchools.first.school.schoolId, 'SCH001');
    });
  });
}

