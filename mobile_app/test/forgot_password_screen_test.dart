import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:mobile_app/screens/forgot_password_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  Widget createWidgetForTesting({String? initialEmail}) {
    return MaterialApp(
      home: ForgotPasswordScreen(initialEmail: initialEmail),
    );
  }

  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('renders all UI components correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetForTesting());

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('EMAIL ADDRESS'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
      expect(find.text('Remember password? '), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('pre-fills email when initialEmail is provided', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetForTesting(initialEmail: 'test@example.com'));

      final textFormFieldFinder = find.byType(TextFormField);
      final textFormField = tester.widget<TextFormField>(textFormFieldFinder);
      expect(textFormField.controller?.text, 'test@example.com');
    });

    testWidgets('shows validation error when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetForTesting(initialEmail: ''));

      // Tap the send link button
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      expect(find.text('Email is required.'), findsOneWidget);
    });

    testWidgets('shows validation error when email format is invalid', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetForTesting(initialEmail: 'invalid-email'));

      // Tap the send link button
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });
  });
}
