import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: const Color(0xffF6F8FC),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff2563EB),
      brightness: Brightness.light,
    ),

    textTheme: GoogleFonts.interTextTheme(),

    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: const Color(0xffF8FAFC),
      foregroundColor: Colors.black,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.grey.shade200,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: const Color(0xff0F172A),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff2563EB),
      brightness: Brightness.dark,
    ),

    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),

    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: const Color(0xff0F172A),
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xff1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
