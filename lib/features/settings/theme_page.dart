import 'package:flutter/material.dart';
import 'package:arta/services/theme_service.dart';

enum AppTheme { system, light, dark }

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  AppTheme selectedTheme = AppTheme.system;

  @override
  void initState() {
    super.initState();

    // Sinkronisasi status awal tombol radio dengan tema yang aktif saat ini
    switch (ThemeService.theme) {
      case ThemeMode.light:
        selectedTheme = AppTheme.light;
        break;
      case ThemeMode.dark:
        selectedTheme = AppTheme.dark;
        break;
      case ThemeMode.system:
        selectedTheme = AppTheme.system;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tema")),
      body: Column(
        children: [
          RadioListTile<AppTheme>(
            value: AppTheme.system,
            groupValue: selectedTheme,
            title: const Text("System"),
            subtitle: const Text("Ikuti tema perangkat"),
            secondary: const Icon(Icons.phone_android),
            onChanged: (value) async {
              setState(() {
                selectedTheme = value!;
              });

              await ThemeService.changeTheme(ThemeMode.system);

              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<AppTheme>(
            value: AppTheme.light,
            groupValue: selectedTheme,
            title: const Text("Light"),
            subtitle: const Text("Tema terang"),
            secondary: const Icon(Icons.light_mode),
            onChanged: (value) async {
              setState(() {
                selectedTheme = value!;
              });

              await ThemeService.changeTheme(ThemeMode.light);

              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<AppTheme>(
            value: AppTheme.dark,
            groupValue: selectedTheme,
            title: const Text("Dark"),
            subtitle: const Text("Tema gelap"),
            secondary: const Icon(Icons.dark_mode),
            onChanged: (value) async {
              setState(() {
                selectedTheme = value!;
              });

              await ThemeService.changeTheme(ThemeMode.dark);

              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
