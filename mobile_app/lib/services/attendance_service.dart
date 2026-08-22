import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import '../models/seeddata.dart';

class AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches historical attendance list for a specific school.
  Future<List<AttendanceModel>> getSchoolAttendanceHistory(
      String schoolId) async {
    try {
      final snap = await _db
          .collection('schools')
          .doc(schoolId)
          .collection('attendance')
          .orderBy('date', descending: true)
          .get()
          .timeout(const Duration(seconds: 4));

      if (snap.docs.isEmpty) {
        return _getFallbackHistory(schoolId);
      }
      return snap.docs.map((d) => AttendanceModel.fromFirestore(d)).toList();
    } catch (e) {
      return _getFallbackHistory(schoolId);
    }
  }

  List<AttendanceModel> _getFallbackHistory(String schoolId) {
    final logs = seedAttendance.where((log) => log['schoolId'] == schoolId).toList();
    final List<AttendanceModel> list = logs.map((log) {
      return AttendanceModel(
        documentId: log['documentId'] ?? log['date'] ?? '',
        attendancePercentage: (log['attendancePercentage'] as num).toDouble(),
        date: log['date'] ?? '',
        status: log['status'] ?? 'submitted',
        submittedBy: log['submittedBy'] ?? '',
        createdAt: DateTime.parse(log['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(log['updatedAt'] ?? DateTime.now().toIso8601String()),
      );
    }).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}
