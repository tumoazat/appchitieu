import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/services/crash_reporting_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (.env file)
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase may already be initialized or network issues on web
    debugPrint('⚠️ Firebase init: $e');
  }

  // Khởi tạo Crashlytics để theo dõi lỗi
  await CrashReportingService.initialize();

  runApp(
    const ProviderScope(
      child: SmartExpenseApp(),
    ),
  );
}