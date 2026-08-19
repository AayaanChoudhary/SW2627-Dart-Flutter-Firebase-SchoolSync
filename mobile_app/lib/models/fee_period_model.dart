import 'package:cloud_firestore/cloud_firestore.dart';

class FeePeriodModel {
  final String periodId;
  final double totalDue;
  final double totalSubmitted;
  final String status;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeePeriodModel({
    required this.periodId,
    required this.totalDue,
    required this.totalSubmitted,
    required this.status,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  double get pendingAmount => totalDue - totalSubmitted;
  double get submissionRate => totalDue > 0 ? (totalSubmitted / totalDue) * 100 : 0.0;

  factory FeePeriodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FeePeriodModel(
      periodId: doc.id,
      totalDue: (data['totalDue'] as num?)?.toDouble() ?? 0.0,
      totalSubmitted: (data['totalSubmitted'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'due',
      updatedBy: data['updatedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalDue': totalDue,
      'totalSubmitted': totalSubmitted,
      'status': status,
      'updatedBy': updatedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
