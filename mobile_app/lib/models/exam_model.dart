import 'package:cloud_firestore/cloud_firestore.dart';

class ExamModel {
  final String examId;
  final String examName;
  final String subject;
  final int classNumber;
  final DateTime scheduledDate;
  final String status; // scheduled, completed, cancelled
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExamModel({
    required this.examId,
    required this.examName,
    required this.subject,
    required this.classNumber,
    required this.scheduledDate,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isOverdue => status == 'scheduled' && scheduledDate.isBefore(DateTime.now());

  factory ExamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ExamModel(
      examId: doc.id,
      examName: data['examName'] ?? 'Exam',
      subject: data['subject'] ?? '',
      classNumber: data['classNumber'] is int
          ? data['classNumber']
          : int.tryParse(data['classNumber']?.toString() ?? '') ?? 0,
      scheduledDate: (data['scheduledDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'scheduled',
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'examName': examName,
      'subject': subject,
      'classNumber': classNumber,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'status': status,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
