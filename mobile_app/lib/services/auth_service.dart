import 'package:firebase_auth/firebase_auth.dart';
import '../models/signup_model.dart';
import '../models/login_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(SignupModel signupData) async {
    try {
      final UserCredential result =
          await _auth.createUserWithEmailAndPassword(
        email: signupData.email,
        password: signupData.password,
      );

      final User? user = result.user;

      if (user != null) {
        await user.updateDisplayName(signupData.name);
        await user.reload();

        return _auth.currentUser;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<User?> signIn(LoginModel loginData) async {
    try {
      final UserCredential result =
          await _auth.signInWithEmailAndPassword(
        // EmailIdentifier is the public getter that normalises the email
        // for consistent backend searching/lookup.
        email: loginData.EmailIdentifier,
        password: loginData.password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Sign In with Email and Password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
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
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';

      case 'operation-not-allowed':
        return 'Email/Password auth is not enabled in Firebase Console.';

      // Login-specific codes
      case 'user-not-found':
        return 'No account found for that email address.';

      case 'wrong-password':
        return 'Incorrect password. Please try again.';

      case 'user-disabled':
        return 'This account has been disabled. Contact support.';

      case 'too-many-requests':
        return 'Too many failed attempts. Please wait and try again.';

      case 'invalid-credential':
        return 'Invalid email or password.';

      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}