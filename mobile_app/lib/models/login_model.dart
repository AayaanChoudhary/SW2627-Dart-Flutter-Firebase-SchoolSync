/// Model representing a user's login credentials.
///
/// The [emailIdentifier] getter is the public method used by backend
/// services to locate/search the user account by their email address.
class LoginModel {
  final String email;
  final String password;
  final String district;

  const LoginModel({
    required this.email,
    required this.password,
    this.district = '',
  });

  /// Public identifier used for backend searching/lookup.
  /// Firebase Auth (and any future backend) resolves the account
  /// by this value — the user's email address.
  String get emailIdentifier => email.trim().toLowerCase();

  Map<String, dynamic> toMap() {
    return {
      'email': emailIdentifier,
      'district': district.trim(),
    };
  }

  /// Basic client-side validation before hitting the backend.
  String? validate() {
    if (email.trim().isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email.trim())) return 'Enter a valid email address.';
    if (password.isEmpty) return 'Password is required.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    return null; // null means valid
  }
}
