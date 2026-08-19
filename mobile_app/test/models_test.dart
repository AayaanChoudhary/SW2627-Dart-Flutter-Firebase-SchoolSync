import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/school_model.dart';
import 'package:mobile_app/models/attendance_model.dart';
import 'package:mobile_app/models/fee_period_model.dart';
import 'package:mobile_app/models/exam_model.dart';
import 'package:mobile_app/models/feedback_model.dart';

// A simple fake DocumentSnapshot for unit testing the models
class FakeDocumentSnapshot implements DocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;

  FakeDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Object? operator [](Object key) => _data[key];

  @override
  Map<String, dynamic> data() => _data;

  @override
  bool get exists => true;

  @override
  DocumentReference get reference => throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SchoolSync Dashboard Backend Models Tests', () {
    
    test('SchoolModel - Parsing and synthetic studentCount fallback', () {
      final doc1 = FakeDocumentSnapshot('SCH001', {
        'name': 'Greenwood Public School',
        'address': 'Jaipur',
        'districtId': 'DIST001',
        'createdAt': Timestamp.fromDate(DateTime(2026, 5, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 8, 18)),
      });

      final school1 = SchoolModel.fromFirestore(doc1);
      expect(school1.schoolId, 'SCH001');
      expect(school1.name, 'Greenwood Public School');
      expect(school1.studentCount, isNotNull);
      // Check that it generates a deterministic mock count between 800 and 1600
      expect(school1.studentCount, greaterThanOrEqualTo(800));
      expect(school1.studentCount, lessThanOrEqualTo(1600));

      final doc2 = FakeDocumentSnapshot('SCH001', {
        'name': 'Greenwood Public School',
        'studentCount': 1240,
      });
      final school2 = SchoolModel.fromFirestore(doc2);
      expect(school2.studentCount, 1240); // Reads directly if present
    });

    test('AttendanceModel - Parsing attendance percentages', () {
      final doc = FakeDocumentSnapshot('2026-08-18', {
        'attendancePercentage': 94.5,
        'date': '2026-08-18',
        'status': 'submitted',
        'submittedBy': 'USR_001',
      });

      final att = AttendanceModel.fromFirestore(doc);
      expect(att.documentId, '2026-08-18');
      expect(att.attendancePercentage, 94.5);
      expect(att.date, '2026-08-18');
    });

    test('FeePeriodModel - Dues calculation and submission rate', () {
      final doc = FakeDocumentSnapshot('2026_TERM_1', {
        'totalDue': 1000000.0,
        'totalSubmitted': 800000.0,
        'status': 'active',
        'updatedBy': 'USR_001',
      });

      final fee = FeePeriodModel.fromFirestore(doc);
      expect(fee.periodId, '2026_TERM_1');
      expect(fee.pendingAmount, 200000.0); // 1,000,000 - 800,000 = 200,000
      expect(fee.submissionRate, 80.0); // (800,000 / 1,000,000) * 100 = 80%
    });

    test('ExamModel - Overdue and completed status calculation', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final futureDate = DateTime.now().add(const Duration(days: 2));

      final overdueDoc = FakeDocumentSnapshot('EXAM001', {
        'examName': 'Math Term 1',
        'status': 'scheduled',
        'scheduledDate': Timestamp.fromDate(pastDate),
      });

      final overdueExam = ExamModel.fromFirestore(overdueDoc);
      expect(overdueExam.isOverdue, isTrue);
      expect(overdueExam.isCompleted, isFalse);

      final completedDoc = FakeDocumentSnapshot('EXAM002', {
        'examName': 'Math Term 1',
        'status': 'completed',
        'scheduledDate': Timestamp.fromDate(pastDate),
      });

      final completedExam = ExamModel.fromFirestore(completedDoc);
      expect(completedExam.isOverdue, isFalse);
      expect(completedExam.isCompleted, isTrue);

      final futureDoc = FakeDocumentSnapshot('EXAM003', {
        'examName': 'Math Term 1',
        'status': 'scheduled',
        'scheduledDate': Timestamp.fromDate(futureDate),
      });

      final futureExam = ExamModel.fromFirestore(futureDoc);
      expect(futureExam.isOverdue, isFalse);
    });

    test('FeedbackModel - Parsing feedback metadata', () {
      final doc = FakeDocumentSnapshot('FB001', {
        'text': 'Good academic status',
        'symbol': 'good',
        'createdBy': 'DISTRICT_ADMIN_001',
        'createdAt': Timestamp.fromDate(DateTime(2026, 8, 18)),
      });

      final fb = FeedbackModel.fromFirestore(doc);
      expect(fb.feedbackId, 'FB001');
      expect(fb.symbol, 'good');
      expect(fb.text, 'Good academic status');
    });

  });
}
