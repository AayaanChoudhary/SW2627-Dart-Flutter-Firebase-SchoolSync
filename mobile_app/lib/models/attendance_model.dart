import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String documentId;
  final double attendancePercentage;
  final String date; // YYYY-MM-DD
  final String status;
  final String submittedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceModel({
    required this.documentId,
    required this.attendancePercentage,
    required this.date,
    required this.status,
    required this.submittedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AttendanceModel(
      documentId: doc.id,
      attendancePercentage: (data['attendancePercentage'] as num?)?.toDouble() ?? 0.0,
      date: data['date'] ?? doc.id,
      status: data['status'] ?? 'submitted',
      submittedBy: data['submittedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'attendancePercentage': attendancePercentage,
      'date': date,
      'status': status,
      'submittedBy': submittedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
