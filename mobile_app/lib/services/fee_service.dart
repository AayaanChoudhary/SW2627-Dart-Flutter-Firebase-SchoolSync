import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fee_period_model.dart';
import '../models/seeddata.dart';

class FeeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches fee periods/dues for a specific school.
  Future<List<FeePeriodModel>> getSchoolFeePeriods(String schoolId) async {
    try {
      final snap = await _db
          .collection('schools')
          .doc(schoolId)
          .collection('feePeriods')
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 4));

      if (snap.docs.isEmpty) {
        return _getFallbackFeePeriods(schoolId);
      }
      return snap.docs.map((d) => FeePeriodModel.fromFirestore(d)).toList();
    } catch (e) {
      return _getFallbackFeePeriods(schoolId);
    }
  }

  List<FeePeriodModel> _getFallbackFeePeriods(String schoolId) {
    final logs = seedFeePeriods.where((log) => log['schoolId'] == schoolId).toList();
    final List<FeePeriodModel> list = logs.map((log) {
      return FeePeriodModel(
        periodId: log['periodId'] ?? '',
        totalDue: (log['totalDue'] as num?)?.toDouble() ?? 0.0,
        totalSubmitted: (log['totalSubmitted'] as num?)?.toDouble() ?? 0.0,
        status: log['status'] ?? 'active',
        updatedBy: log['updatedBy'] ?? '',
        createdAt: DateTime.parse(log['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(log['updatedAt'] ?? DateTime.now().toIso8601String()),
      );
    }).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
}
