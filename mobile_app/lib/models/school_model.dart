import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolModel {
  final String schoolId;
  final String name;
  final String address;
  final String districtId;
  final int studentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  SchoolModel({
    required this.schoolId,
    required this.name,
    required this.address,
    required this.districtId,
    required this.studentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SchoolModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final id = doc.id;
    
    // Synthesize a stable, deterministic student count if not present in Firestore
    int mockCount = 1000;
    if (id.startsWith('SCH')) {
      final numericPart = int.tryParse(id.substring(3)) ?? 0;
      mockCount = 800 + (numericPart * 87) % 800; // Count between 800 and 1600
    }
    
    return SchoolModel(
      schoolId: id,
      name: data['name'] ?? 'Unknown School',
      address: data['address'] ?? '',
      districtId: data['districtId'] ?? '',
      studentCount: data['studentCount'] ?? mockCount,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'districtId': districtId,
      'studentCount': studentCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
