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

  /// Signs in an existing user using [LoginModel.EmailIdentifier] as the
  /// backend search key — Firebase resolves the account by this email.
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