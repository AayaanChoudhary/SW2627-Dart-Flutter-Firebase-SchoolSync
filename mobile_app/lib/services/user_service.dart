import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches the user profile from Cloud Firestore `users/{uid}`.
  /// If the profile document doesn't exist yet, it automatically creates a fallback
  /// `district_admin` profile with `districtId = 'DIST001'` to maintain smooth migration.
  Future<UserModel> getUserProfile(
    String uid, {
    String? defaultEmail,
    String? defaultName,
    String? defaultDistrictId,
  }) async {
    try {
      final docSnap = await _db.collection('users').doc(uid).get();

      if (docSnap.exists && docSnap.data() != null) {
        return UserModel.fromFirestore(docSnap);
      }

      // Create fallback profile document if missing
      final fallbackProfile = UserModel(
        uid: uid,
        email: defaultEmail ?? '',
        name: defaultName ?? 'District Admin',
        role: 'district_admin',
        districtId: defaultDistrictId ?? 'DIST001',
      );

      await saveUserProfile(fallbackProfile);
      return fallbackProfile;
    } catch (e) {
      debugPrint('⚠️ [UserService] Error fetching user profile for $uid: $e');
      // Return safe in-memory fallback if network/permissions prevent fetch
      return UserModel(
        uid: uid,
        email: defaultEmail ?? '',
        name: defaultName ?? 'District Admin',
        role: 'district_admin',
        districtId: defaultDistrictId ?? 'DIST001',
      );
    }
  }

  /// Writes or updates a user profile document in `users/{uid}`.
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('✅ [UserService] Profile saved successfully for ${user.uid}');
    } catch (e) {
      debugPrint('❌ [UserService] Failed to save user profile: $e');
      rethrow;
    }
  }
}
