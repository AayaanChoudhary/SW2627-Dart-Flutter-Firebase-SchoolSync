import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/school_model.dart';
import '../models/attendance_model.dart';
import '../models/fee_period_model.dart';
import '../models/exam_model.dart';
import '../models/feedback_model.dart';
import '../utils/attendance_calculator.dart';

/// Aggregated dashboard data for a single school.
class SchoolDashboardData {
  final SchoolModel school;
  final double latestAttendancePercentage;
  final double weeklyAttendancePercentage;
  final double monthlyAttendancePercentage;
  final double feeSubmissionRate;
  final double feesCollected;
  final double feesPending;
  final String examStatus; // 'On track' or 'Lagging'
  final String feedbackStatus; // 'good' or 'needs_review'

  SchoolDashboardData({
    required this.school,
    required this.latestAttendancePercentage,
    required this.weeklyAttendancePercentage,
    required this.monthlyAttendancePercentage,
    required this.feeSubmissionRate,
    required this.feesCollected,
    required this.feesPending,
    required this.examStatus,
    required this.feedbackStatus,
  });
}

/// Consolidated district overview metrics.
class DistrictDashboardSummary {
  final String districtId;
  final double averageAttendanceToday;
  final double totalFeesCollected;
  final double totalFeesPending;
  final int weeklyExamsCount;
  final String examProgressStatus; // 'On track' or 'Lagging'
  final List<SchoolDashboardData> schoolsData;

  DistrictDashboardSummary({
    this.districtId = '',
    required this.averageAttendanceToday,
    required this.totalFeesCollected,
    required this.totalFeesPending,
    required this.weeklyExamsCount,
    required this.examProgressStatus,
    required this.schoolsData,
  });
}

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches the consolidated summary for all schools in a district strictly from Cloud Firestore.
  Future<DistrictDashboardSummary> getDistrictSummary(
    String districtId, {
    DateTime? targetDate,
  }) async {
    final now = targetDate ?? DateTime.now();

    try {
      // 1. Fetch all schools in this district from Firestore
      final schoolSnap = await _db
          .collection('schools')
          .where('districtId', isEqualTo: districtId)
          .get();

      if (schoolSnap.docs.isEmpty) {
        throw Exception(
          'No schools found in Cloud Firestore for district "$districtId". '
          'Please ensure data has been seeded to your database.',
        );
      }

      final List<SchoolDashboardData> schoolsData = [];
      double attendanceSum = 0;
      int schoolsWithAttendanceCount = 0;
      double districtFeesCollected = 0;
      double districtFeesPending = 0;
      int districtWeeklyExamsCount = 0;
      bool isDistrictLagging = false;

      // Define week start and end boundaries (Monday 00:00 to Sunday 23:59)
      final weekRange = AttendanceCalculator.getWeekDateRange(now);

      for (final doc in schoolSnap.docs) {
        final school = SchoolModel.fromFirestore(doc);
        final schoolId = school.schoolId;

        // --- 2. Calculate Attendance with Strict Date Boundaries ---
        final attendanceSnap = await _db
            .collection('schools')
            .doc(schoolId)
            .collection('attendance')
            .orderBy('date', descending: true)
            .get();

        final List<AttendanceModel> attendanceRecords = attendanceSnap.docs
            .map((d) => AttendanceModel.fromFirestore(d))
            .toList();

        double latestAtt = 0.0;
        double weeklyAtt = 0.0;
        double monthlyAtt = 0.0;

        if (attendanceRecords.isNotEmpty) {
          latestAtt = AttendanceCalculator.getDailyAttendance(
            attendanceRecords,
            targetDate: now,
          );
          attendanceSum += latestAtt;
          schoolsWithAttendanceCount++;

          // Weekly: strictly Monday 00:00:00 to Sunday 23:59:59
          weeklyAtt = AttendanceCalculator.calculateWeeklyAttendance(
            attendanceRecords,
            targetDate: now,
          );

          // Monthly: strictly 1st day 00:00:00 to last day 23:59:59
          monthlyAtt = AttendanceCalculator.calculateMonthlyAttendance(
            attendanceRecords,
            targetDate: now,
          );
        }

        // --- 3. Calculate Fees ---
        final feesSnap = await _db
            .collection('schools')
            .doc(schoolId)
            .collection('feePeriods')
            .get();

        final List<FeePeriodModel> feePeriods =
            feesSnap.docs.map((d) => FeePeriodModel.fromFirestore(d)).toList();

        double collected = 0.0;
        double pending = 0.0;
        double rate = 0.0;

        if (feePeriods.isNotEmpty) {
          FeePeriodModel activePeriod = feePeriods.first;
          final activeList = feePeriods.where((p) => p.status == 'active');
          if (activeList.isNotEmpty) {
            activePeriod = activeList.first;
          } else {
            feePeriods.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            activePeriod = feePeriods.first;
          }

          collected = activePeriod.totalSubmitted;
          pending = activePeriod.pendingAmount;
          rate = activePeriod.submissionRate;
        }

        districtFeesCollected += collected;
        districtFeesPending += pending;

        // --- 4. Calculate Exams Status ---
        final examsSnap = await _db
            .collection('schools')
            .doc(schoolId)
            .collection('exams')
            .get();

        final List<ExamModel> exams =
            examsSnap.docs.map((d) => ExamModel.fromFirestore(d)).toList();

        String schoolExamStatus = 'On track';
        for (final exam in exams) {
          final isOverdue = exam.status == 'scheduled' && exam.scheduledDate.isBefore(now);
          if (isOverdue) {
            schoolExamStatus = 'Lagging';
            isDistrictLagging = true;
          }

          if ((exam.scheduledDate.isAfter(weekRange.start) || exam.scheduledDate.isAtSameMomentAs(weekRange.start)) &&
              (exam.scheduledDate.isBefore(weekRange.end) || exam.scheduledDate.isAtSameMomentAs(weekRange.end)) &&
              exam.status != 'cancelled') {
            districtWeeklyExamsCount++;
          }
        }

        // --- 5. Fetch Feedback Status ---
        final feedbackSnap = await _db
            .collection('schools')
            .doc(schoolId)
            .collection('feedback')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        String feedbackStatus = 'good';
        if (feedbackSnap.docs.isNotEmpty) {
          final feedback = FeedbackModel.fromFirestore(feedbackSnap.docs.first);
          feedbackStatus = feedback.symbol;
        }

        schoolsData.add(
          SchoolDashboardData(
            school: school,
            latestAttendancePercentage: latestAtt,
            weeklyAttendancePercentage: weeklyAtt,
            monthlyAttendancePercentage: monthlyAtt,
            feeSubmissionRate: rate,
            feesCollected: collected,
            feesPending: pending,
            examStatus: schoolExamStatus,
            feedbackStatus: feedbackStatus,
          ),
        );
      }

      final double avgAttendanceToday = schoolsWithAttendanceCount > 0
          ? attendanceSum / schoolsWithAttendanceCount
          : 0.0;

      debugPrint('📊 [DashboardService] Successfully fetched ${schoolsData.length} schools live from Cloud Firestore for district "$districtId"!');
      return DistrictDashboardSummary(
        districtId: districtId,
        averageAttendanceToday: avgAttendanceToday,
        totalFeesCollected: districtFeesCollected,
        totalFeesPending: districtFeesPending,
        weeklyExamsCount: districtWeeklyExamsCount,
        examProgressStatus: isDistrictLagging ? 'Lagging' : 'On track',
        schoolsData: schoolsData,
      );
    } catch (e) {
      debugPrint('❌ [DashboardService] Firestore fetch failed: $e');
      rethrow;
    }
  }
}
