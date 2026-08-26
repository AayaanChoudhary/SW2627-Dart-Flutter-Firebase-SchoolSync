import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/school_model.dart';
import 'package:mobile_app/services/dashboard_service.dart';

void main() {
  group('District Frontend Filtering Unit Tests', () {
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
          latestAttendancePercentage: 92.0,
          weeklyAttendancePercentage: 88.0,
          monthlyAttendancePercentage: 86.0,
          feeSubmissionRate: 85.0,
          feesCollected: 425000.0,
          feesPending: 75000.0,
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
          latestAttendancePercentage: 64.0,
          weeklyAttendancePercentage: 68.0,
          monthlyAttendancePercentage: 72.0,
          feeSubmissionRate: 45.0,
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
          latestAttendancePercentage: 78.0,
          weeklyAttendancePercentage: 80.0,
          monthlyAttendancePercentage: 79.0,
          feeSubmissionRate: 72.0,
          feesCollected: 360000.0,
          feesPending: 140000.0,
          examStatus: 'On track',
          feedbackStatus: 'good',
        ),
      ];
    });

    test('Attendance threshold filtering: critical (<70%) returns only SCH002 for daily', () {
      final criticalSchools = testSchools
          .where((s) => s.latestAttendancePercentage < 70.0)
          .toList();
      expect(criticalSchools.length, 1);
      expect(criticalSchools.first.school.schoolId, 'SCH002');
    });

    test('Attendance threshold filtering: good (>=85%) returns SCH001', () {
      final goodSchools = testSchools
          .where((s) => s.latestAttendancePercentage >= 85.0)
          .toList();
      expect(goodSchools.length, 1);
      expect(goodSchools.first.school.schoolId, 'SCH001');
    });

    test('Fees collection rate filtering: low (<50%) returns SCH002', () {
      final lowFeeSchools = testSchools
          .where((s) => s.feeSubmissionRate < 50.0)
          .toList();
      expect(lowFeeSchools.length, 1);
      expect(lowFeeSchools.first.school.schoolId, 'SCH002');
    });

    test('Fees sorting: pending amount descending puts SCH002 first', () {
      final sorted = List<SchoolDashboardData>.from(testSchools)
        ..sort((a, b) => b.feesPending.compareTo(a.feesPending));
      expect(sorted.first.school.schoolId, 'SCH002');
      expect(sorted.first.feesPending, 220000.0);
    });

    test('Exam status filtering: lagging returns only schools with lagging exams', () {
      final laggingSchools = testSchools
          .where((s) => s.examStatus.toLowerCase() == 'lagging')
          .toList();
      expect(laggingSchools.length, 1);
      expect(laggingSchools.first.school.schoolId, 'SCH002');
    });

    test('Exam status filtering: on track returns schools on schedule', () {
      final onTrackSchools = testSchools
          .where((s) => s.examStatus.toLowerCase() == 'on track')
          .toList();
      expect(onTrackSchools.length, 2);
      expect(onTrackSchools.map((s) => s.school.schoolId), containsAll(['SCH001', 'SCH003']));
    });
  });
}
