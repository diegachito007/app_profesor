import 'package:flutter/material.dart';

class AppTheme {
  static const Color fondoProfeshor = Colors.white;
  static const Color colorPrimario = Color(0xFF00589D); // Azul del logo

  static final ThemeData temaProfeshor = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: fondoProfeshor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colorPrimario,
      surface: fondoProfeshor,
    ),

    // ✅ Estilo global para AlertDialog
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: colorPrimario,
      ),
      contentTextStyle: const TextStyle(fontSize: 16, color: Colors.black87),
    ),

    // ✅ Estilo global para TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorPrimario,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),

    // ✅ Estilo global para ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // ✅ Estilo global para SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorPrimario,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
