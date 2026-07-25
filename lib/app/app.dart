import 'package:arta/features/main/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:arta/services/theme_service.dart';

import 'theme.dart';
import 'package:arta/main.dart';
import '../features/auth/auth_page.dart';

class ArtaApp extends StatelessWidget {
  const ArtaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          title: 'ARTA Personal Finance',

          theme: AppTheme.light,
          darkTheme: AppTheme.dark,

          themeMode: themeMode,

          // MENGGUNAKAN STREAMBUILDER DARI FIREBASE AUTH
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // 1. Saat Firebase sedang mengecek sesi di awal aplikasi dibuka
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // 2. Jika user sudah login (data snapshot tidak null)
              if (snapshot.hasData) {
                return const MainPage();
              }

              // 3. Jika user belum login / sudah logout
              return const AuthPage();
            },
          ),
        );
      },
    );
  }
}
