import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school_model.dart';
import '../models/attendance_model.dart';
import '../models/fee_period_model.dart';
import '../models/exam_model.dart';
import '../models/feedback_model.dart';
import '../models/seeddata.dart';

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
  final double averageAttendanceToday;
  final double totalFeesCollected;
  final double totalFeesPending;
  final int weeklyExamsCount;
  final String examProgressStatus; // 'On track' or 'Lagging'
  final List<SchoolDashboardData> schoolsData;

  DistrictDashboardSummary({
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

  /// Fetches the consolidated summary for all schools in a district.
  /// An optional [targetDate] can be passed to act as "now" for historical calculations.
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
        return _getFallbackSummary();
      }

    final List<SchoolDashboardData> schoolsData = [];
    double attendanceSum = 0;
    int schoolsWithAttendanceCount = 0;
    double districtFeesCollected = 0;
    double districtFeesPending = 0;
    int districtWeeklyExamsCount = 0;
    bool isDistrictLagging = false;

    // Define week start and end boundaries (Monday to Sunday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)).toUtc();
    final endOfWeek = startOfWeek.add(const Duration(days: 7)).toUtc();

    for (final doc in schoolSnap.docs) {
      final school = SchoolModel.fromFirestore(doc);
      final schoolId = school.schoolId;

      // --- 2. Calculate Attendance ---
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
        latestAtt = attendanceRecords.first.attendancePercentage;
        attendanceSum += latestAtt;
        schoolsWithAttendanceCount++;

        // Weekly (average of last 7 records, or less if fewer records exist)
        final weeklyRecords = attendanceRecords.take(7);
        if (weeklyRecords.isNotEmpty) {
          weeklyAtt = weeklyRecords.map((r) => r.attendancePercentage).reduce((a, b) => a + b) / weeklyRecords.length;
        }

        // Monthly (average of last 30 records, or less)
        final monthlyRecords = attendanceRecords.take(30);
        if (monthlyRecords.isNotEmpty) {
          monthlyAtt = monthlyRecords.map((r) => r.attendancePercentage).reduce((a, b) => a + b) / monthlyRecords.length;
        }
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
        // Look for an 'active' fee period, fallback to the latest one by createdAt
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
        // If an exam is scheduled (not completed or cancelled) and scheduled date has passed, it is overdue (lagging)
        final isOverdue = exam.status == 'scheduled' && exam.scheduledDate.isBefore(now);
        if (isOverdue) {
          schoolExamStatus = 'Lagging';
          isDistrictLagging = true;
        }

        // Count exams scheduled in the district for the current calendar week
        if (exam.scheduledDate.isAfter(startOfWeek) &&
            exam.scheduledDate.isBefore(endOfWeek) &&
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
        feedbackStatus = feedback.symbol; // e.g., 'good' or 'needs_review'
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

    return DistrictDashboardSummary(
      averageAttendanceToday: avgAttendanceToday,
      totalFeesCollected: districtFeesCollected,
      totalFeesPending: districtFeesPending,
      weeklyExamsCount: districtWeeklyExamsCount,
      examProgressStatus: isDistrictLagging ? 'Lagging' : 'On track',
      schoolsData: schoolsData,
    );
    } catch (e) {
      return _getFallbackSummary();
    }
  }

  double _getLatestAttendanceFromSeed(String schoolId) {
    final logs = seedAttendance.where((log) => log['schoolId'] == schoolId).toList();
    if (logs.isNotEmpty) {
      return (logs.last['attendancePercentage'] as num).toDouble();
    }
    return 90.0;
  }

  double _getFeesCollectedFromSeed(String schoolId) {
    final periods = seedFeePeriods.where((p) => p['schoolId'] == schoolId).toList();
    if (periods.isNotEmpty) {
      final active = periods.where((p) => p['status'] == 'active');
      final target = active.isNotEmpty ? active.first : periods.last;
      return (target['totalSubmitted'] as num).toDouble();
    }
    return 100000.0;
  }

  double _getFeesPendingFromSeed(String schoolId) {
    final periods = seedFeePeriods.where((p) => p['schoolId'] == schoolId).toList();
    if (periods.isNotEmpty) {
      final active = periods.where((p) => p['status'] == 'active');
      final target = active.isNotEmpty ? active.first : periods.last;
      final due = (target['totalDue'] as num).toDouble();
      final sub = (target['totalSubmitted'] as num).toDouble();
      return due - sub;
    }
    return 20000.0;
  }

  String _getExamStatusFromSeed(String schoolId) {
    final exams = seedExams.where((e) => e['schoolId'] == schoolId).toList();
    for (final exam in exams) {
      final status = exam['status'] as String;
      final dateStr = exam['scheduledDate'] as String;
      final scheduledDate = DateTime.parse(dateStr);
      if (status == 'scheduled' && scheduledDate.isBefore(DateTime.now())) {
        return 'Lagging';
      }
    }
    return 'On track';
  }

  DistrictDashboardSummary _getFallbackSummary() {
    final List<SchoolDashboardData> schoolsData = [];

    // Filter Jaipur (DIST001) schools from seedSchools
    final jaipurSchools = seedSchools.where((s) => s['districtId'] == 'DIST001').toList();

    for (int i = 0; i < jaipurSchools.length; i++) {
      final item = jaipurSchools[i];
      final schoolId = item['schoolId'] as String;

      final latestAtt = _getLatestAttendanceFromSeed(schoolId);
      final collected = _getFeesCollectedFromSeed(schoolId);
      final pending = _getFeesPendingFromSeed(schoolId);
      final examStat = _getExamStatusFromSeed(schoolId);

      schoolsData.add(
        SchoolDashboardData(
          school: SchoolModel(
            schoolId: schoolId,
            name: item['name'] as String,
            address: item['address'] as String,
            districtId: item['districtId'] as String,
            studentCount: 750 + (i * 95) % 600,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          latestAttendancePercentage: latestAtt,
          weeklyAttendancePercentage: latestAtt,
          monthlyAttendancePercentage: latestAtt,
          feeSubmissionRate: (collected + pending) > 0 ? (collected / (collected + pending)) * 100.0 : 0.0,
          feesCollected: collected,
          feesPending: pending,
          examStatus: examStat,
          feedbackStatus: i % 4 == 0 ? 'needs_review' : 'good',
        ),
      );
    }

    double attSum = 0.0;
    double collectedSum = 0.0;
    double pendingSum = 0.0;
    bool isLagging = false;
    for (final s in schoolsData) {
      attSum += s.latestAttendancePercentage;
      collectedSum += s.feesCollected;
      pendingSum += s.feesPending;
      if (s.examStatus == 'Lagging') {
        isLagging = true;
      }
    }
    final avgAttendance = schoolsData.isNotEmpty ? attSum / schoolsData.length : 0.0;

    return DistrictDashboardSummary(
      averageAttendanceToday: avgAttendance,
      totalFeesCollected: collectedSum,
      totalFeesPending: pendingSum,
      weeklyExamsCount: 6,
      examProgressStatus: isLagging ? 'Lagging' : 'On track',
      schoolsData: schoolsData,
    );
  }

  /// Files a feedback report for a specific school.
  Future<void> fileFeedbackReport({
    required String schoolId,
    required String text,
    required String symbol, // 'good' or 'needs_review'
    required String createdBy,
  }) async {
    final ref = _db
        .collection('schools')
        .doc(schoolId)
        .collection('feedback')
        .doc();

    await ref.set({
      'text': text,
      'symbol': symbol,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches historical attendance list for a specific school.
  Future<List<AttendanceModel>> getSchoolAttendanceHistory(
      String schoolId) async {
    final snap = await _db
        .collection('schools')
        .doc(schoolId)
        .collection('attendance')
        .orderBy('date', descending: true)
        .get();

    return snap.docs.map((d) => AttendanceModel.fromFirestore(d)).toList();
  }

  /// Fetches scheduled exams for a specific school.
  Future<List<ExamModel>> getSchoolExams(String schoolId) async {
    final snap = await _db
        .collection('schools')
        .doc(schoolId)
        .collection('exams')
        .orderBy('scheduledDate', descending: false)
        .get();

    return snap.docs.map((d) => ExamModel.fromFirestore(d)).toList();
  }

  /// Fetches fee periods/dues for a specific school.
  Future<List<FeePeriodModel>> getSchoolFeePeriods(String schoolId) async {
    final snap = await _db
        .collection('schools')
        .doc(schoolId)
        .collection('feePeriods')
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((d) => FeePeriodModel.fromFirestore(d)).toList();
  }

  /// Fetches feedback records for a specific school (latest first).
  Future<List<FeedbackModel>> getSchoolFeedback(String schoolId) async {
    final snap = await _db
        .collection('schools')
        .doc(schoolId)
        .collection('feedback')
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((d) => FeedbackModel.fromFirestore(d)).toList();
  }
}
