import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'services/financial_service.dart';
import 'services/hive_service.dart';
import 'services/theme_service.dart';

// TAMBAHKAN BARIS INI DI SINI
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Hive
  await HiveService.init();

  // Load semua data FinancialService
  await FinancialService.init();

  // Theme
  await ThemeService.loadTheme();

  runApp(const ArtaApp());
}
