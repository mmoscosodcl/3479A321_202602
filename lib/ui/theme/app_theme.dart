import 'package:flutter/material.dart';

class AppTheme {
  static const Color primarySeed = Color.fromARGB(255, 12, 80, 157); // Nogal Clásico
  static const Color boardBaseColor = Color(0xFFD7CCC8);
  static const Color emptyHoleColor = Color(0xFF3E2723);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeed,
        brightness: Brightness.light,
        surfaceContainerHighest: const Color(0xFFEFEBE9),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F2EB),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primarySeed,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'TacoCrispy',
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}