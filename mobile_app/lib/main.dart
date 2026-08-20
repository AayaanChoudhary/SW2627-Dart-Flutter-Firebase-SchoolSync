import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'models/seeddata.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Auto-seed asynchronously on startup
    Future.microtask(() async {
      try {
        debugPrint('🌱 Overwriting Firestore with updated seeded data...');
        await seedFirestore();
        debugPrint('🌱 Firestore seeded successfully!');
      } catch (e) {
        debugPrint('⚠️ Auto-seeding check failed: $e');
      }
    });

    debugPrint('🔥 Firebase initialized successfully');

    runApp(const MyApp());
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Firebase initialization failed:\n\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SchoolSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A80F0),
          brightness: Brightness.dark,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF0F1B2D),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF4A80F0)),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const DashboardScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
