import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'screens/config_missing_screen.dart';
import 'services/notification_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  String? startupError;

  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    final looksLikePlaceholder = options.apiKey.startsWith('YOUR_') ||
        options.projectId == 'YOUR_PROJECT_ID';

    if (looksLikePlaceholder) {
      startupError =
          'Firebase is not configured yet. Run flutterfire configure first.';
    } else {
      await Firebase.initializeApp(options: options);
      firebaseReady = true;
      await NotificationService.instance.init();
    }
  } catch (error) {
    startupError = error.toString();
  }

  runApp(
    StudyPlannerApp(
      firebaseReady: firebaseReady,
      startupError: startupError,
    ),
  );
}

class StudyPlannerApp extends StatelessWidget {
  final bool firebaseReady;
  final String? startupError;

  const StudyPlannerApp({
    super.key,
    required this.firebaseReady,
    this.startupError,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Academic Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: firebaseReady
          ? const AuthGate()
          : ConfigMissingScreen(errorMessage: startupError),
    );
  }
}
