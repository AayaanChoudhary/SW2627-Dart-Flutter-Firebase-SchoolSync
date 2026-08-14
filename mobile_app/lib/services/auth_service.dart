import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up with Email, Password, and Full Name
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // 1. Create the user credential in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // 2. Set the display name to the user's Full Name
        await user.updateDisplayName(fullName);
        await user.reload(); // Refresh the cached user state
        return _auth.currentUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Throw a user-friendly error string translated from the Firebase Auth exception
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Translate Firebase codes into readable messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak (minimum 6 characters).';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'operation-not-allowed':
        return 'Email/Password auth is not enabled in Firebase Console.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Sign Out helper
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
