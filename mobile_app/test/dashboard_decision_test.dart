import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/school_model.dart';
import 'package:mobile_app/services/dashboard_service.dart';
import 'package:mobile_app/widgets/dashboard_action_center.dart';

void main() {
  group('Dashboard Decision-Making & Risk Triage Tests', () {
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
          latestAttendancePercentage: 94.0,
          weeklyAttendancePercentage: 92.0,
          monthlyAttendancePercentage: 91.0,
          feeSubmissionRate: 88.0,
          feesCollected: 450000.0,
          feesPending: 50000.0,
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
          latestAttendancePercentage: 64.0, // Critical attendance
          weeklyAttendancePercentage: 66.0,
          monthlyAttendancePercentage: 68.0,
          feeSubmissionRate: 40.0, // Low fee collection
          feesCollected: 160000.0,
          feesPending: 240000.0,
          examStatus: 'Lagging', // Lagging exams
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
          latestAttendancePercentage: 82.0,
          weeklyAttendancePercentage: 81.0,
          monthlyAttendancePercentage: 80.0,
          feeSubmissionRate: 75.0,
          feesCollected: 375000.0,
          feesPending: 125000.0,
          examStatus: 'On track',
          feedbackStatus: 'good',
        ),
      ];
    });

    test('Needs Attention filter isolates all high-risk schools', () {
      final needsAttention = testSchools.where((s) {
        final isCriticalAtt = s.latestAttendancePercentage < 70.0;
        final isLaggingExam = s.examStatus.toLowerCase() == 'lagging';
        final isLowFee = s.feeSubmissionRate < 50.0 && s.feesPending > 0;
        return isCriticalAtt || isLaggingExam || isLowFee;
      }).toList();

      expect(needsAttention.length, 1);
      expect(needsAttention.first.school.schoolId, 'SCH002');
    });

    test('Critical attendance triage identifies schools below 70%', () {
      final critical = testSchools
          .where((s) => s.latestAttendancePercentage < 70.0)
          .toList();
      expect(critical.length, 1);
      expect(critical.first.school.name, 'Bright Future Public School');
    });

    test('Lagging exams triage identifies schools behind schedule', () {
      final lagging = testSchools
          .where((s) => s.examStatus.toLowerCase() == 'lagging')
          .toList();
      expect(lagging.length, 1);
      expect(lagging.first.school.schoolId, 'SCH002');
    });

    test('Priority Risk sorting always places schools needing attention first', () {
      final sorted = List<SchoolDashboardData>.from(testSchools)
        ..sort((a, b) {
          final aNeeds = a.latestAttendancePercentage < 70.0 ||
              a.examStatus.toLowerCase() == 'lagging' ||
              (a.feeSubmissionRate < 50.0 && a.feesPending > 0);
          final bNeeds = b.latestAttendancePercentage < 70.0 ||
              b.examStatus.toLowerCase() == 'lagging' ||
              (b.feeSubmissionRate < 50.0 && b.feesPending > 0);
          if (aNeeds && !bNeeds) return -1;
          if (!aNeeds && bNeeds) return 1;
          return a.latestAttendancePercentage.compareTo(b.latestAttendancePercentage);
        });

      // SCH002 must be first because it needs attention
      expect(sorted.first.school.schoolId, 'SCH002');
    });

    test('On Track triage filter returns only healthy schools', () {
      final onTrackSchools = testSchools.where((s) {
        final isCriticalAtt = s.latestAttendancePercentage < 70.0;
        final isLaggingExam = s.examStatus.toLowerCase() == 'lagging';
        final isLowFee = s.feeSubmissionRate < 50.0 && s.feesPending > 0;
        return !(isCriticalAtt || isLaggingExam || isLowFee);
      }).toList();

      expect(onTrackSchools.length, 2);
      expect(onTrackSchools.map((s) => s.school.schoolId), containsAll(['SCH001', 'SCH003']));
    });
  });
}
