import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exam_model.dart';
import '../models/seeddata.dart';

class ExamService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches scheduled exams for a specific school.
  Future<List<ExamModel>> getSchoolExams(String schoolId) async {
    try {
      final snap = await _db
          .collection('schools')
          .doc(schoolId)
          .collection('exams')
          .orderBy('scheduledDate', descending: false)
          .get()
          .timeout(const Duration(seconds: 4));

      if (snap.docs.isEmpty) {
        return _getFallbackExams(schoolId);
      }
      return snap.docs.map((d) => ExamModel.fromFirestore(d)).toList();
    } catch (e) {
      return _getFallbackExams(schoolId);
    }
  }

  List<ExamModel> _getFallbackExams(String schoolId) {
    final logs = seedExams.where((log) => log['schoolId'] == schoolId).toList();
    final List<ExamModel> list = logs.map((log) {
      return ExamModel(
        examId: log['examId'] ?? '',
        examName: log['examName'] ?? 'Exam',
        subject: log['subject'] ?? '',
        classNumber: log['classNumber'] is int
            ? log['classNumber']
            : int.tryParse(log['classNumber']?.toString() ?? '') ?? 0,
        scheduledDate: DateTime.parse(log['scheduledDate'] ?? DateTime.now().toIso8601String()),
        status: log['status'] ?? 'scheduled',
        completedAt: log['completedAt'] == null ? null : DateTime.parse(log['completedAt']!),
        createdAt: DateTime.parse(log['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(log['updatedAt'] ?? DateTime.now().toIso8601String()),
      );
    }).toList();
    list.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return list;
  }
}
