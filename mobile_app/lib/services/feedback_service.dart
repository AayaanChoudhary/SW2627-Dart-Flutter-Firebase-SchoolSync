import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';
import '../models/seeddata.dart';

class FeedbackService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  /// Fetches feedback records for a specific school (latest first).
  Future<List<FeedbackModel>> getSchoolFeedback(String schoolId) async {
    try {
      final snap = await _db
          .collection('schools')
          .doc(schoolId)
          .collection('feedback')
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 4));

      if (snap.docs.isEmpty) {
        return _getFallbackFeedback(schoolId);
      }
      return snap.docs.map((d) => FeedbackModel.fromFirestore(d)).toList();
    } catch (e) {
      return _getFallbackFeedback(schoolId);
    }
  }

  List<FeedbackModel> _getFallbackFeedback(String schoolId) {
    final logs = seedFeedback.where((log) => log['schoolId'] == schoolId).toList();
    final List<FeedbackModel> list = logs.map((log) {
      return FeedbackModel(
        feedbackId: log['feedbackId'] ?? '',
        text: log['text'] ?? '',
        symbol: log['symbol'] ?? 'good',
        createdBy: log['createdBy'] ?? '',
        createdAt: DateTime.parse(log['createdAt'] ?? DateTime.now().toIso8601String()),
      );
    }).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
}
