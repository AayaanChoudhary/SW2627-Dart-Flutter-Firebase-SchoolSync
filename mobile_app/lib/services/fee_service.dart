import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fee_period_model.dart';

class FeeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches fee periods/dues for a specific school strictly from Cloud Firestore.
  Future<List<FeePeriodModel>> getSchoolFeePeriods(String schoolId) async {
    try {
      final snap = await _db
          .collection('schools')
          .doc(schoolId)
          .collection('feePeriods')
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 8));

      return snap.docs.map((d) => FeePeriodModel.fromFirestore(d)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
