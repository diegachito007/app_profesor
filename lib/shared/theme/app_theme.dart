import 'package:flutter/material.dart';

class AppTheme {
  static const Color fondoProfeshor = Color.fromRGBO(251, 250, 249, 1);
  static const Color colorPrimario = Color(0xFF00589D); // Azul del logo

  static final ThemeData temaProfeshor = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: fondoProfeshor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colorPrimario,
      surface: fondoProfeshor,
    ),
  );
}
