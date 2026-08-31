import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Files a feedback report for a specific school in Cloud Firestore.
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

  /// Fetches feedback records for a specific school (latest first) strictly from Cloud Firestore.
  Future<List<FeedbackModel>> getSchoolFeedback(String schoolId) async {
    try {
      final snap = await _db
          .collection('schools')
          .doc(schoolId)
          .collection('feedback')
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 8));

      return snap.docs.map((d) => FeedbackModel.fromFirestore(d)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
