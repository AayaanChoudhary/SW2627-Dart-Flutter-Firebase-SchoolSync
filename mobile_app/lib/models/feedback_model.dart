import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String feedbackId;
  final String text;
  final String symbol; // good, needs_review
  final String createdBy;
  final DateTime createdAt;

  FeedbackModel({
    required this.feedbackId,
    required this.text,
    required this.symbol,
    required this.createdBy,
    required this.createdAt,
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FeedbackModel(
      feedbackId: doc.id,
      text: data['text'] ?? '',
      symbol: data['symbol'] ?? 'good',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'symbol': symbol,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
