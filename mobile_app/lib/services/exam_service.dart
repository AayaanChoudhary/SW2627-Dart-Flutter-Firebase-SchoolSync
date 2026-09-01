import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exam_model.dart';

class ExamService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches scheduled exams for a specific school strictly from Cloud Firestore.
  Future<List<ExamModel>> getSchoolExams(String schoolId) async {
    try {
      final snap = await _db
          .collection('schools')
          .doc(schoolId)
          .collection('exams')
          .orderBy('scheduledDate', descending: false)
          .get()
          .timeout(const Duration(seconds: 8));

      return snap.docs.map((d) => ExamModel.fromFirestore(d)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
