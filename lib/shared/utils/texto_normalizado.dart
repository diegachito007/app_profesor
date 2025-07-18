import 'package:flutter/services.dart';

/// 🔠 Formatter que fuerza entrada en mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// 🧼 Normaliza texto eliminando tildes, símbolos y convirtiendo a minúsculas
String normalizar(String texto) {
  return texto
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâã]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöôõ]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .trim();
}

/// 👁️ Capitaliza texto respetando tildes y estructura original
String capitalizarConTildes(String texto) {
  final palabras = texto.toLowerCase().split(' ');
  return palabras
      .map((p) {
        if (p.isEmpty) return '';
        return p[0].toUpperCase() + p.substring(1);
      })
      .join(' ');
}

/// 🧠 Capitaliza títulos respetando preposiciones y conjunciones
String capitalizarTituloConTildes(String texto) {
  final excepciones = {
    'a',
    'de',
    'del',
    'en',
    'y',
    'o',
    'u',
    'con',
    'sin',
    'para',
    'por',
    'el',
    'la',
    'los',
    'las',
  };

  final palabras = texto.toLowerCase().split(' ');
  return palabras
      .asMap()
      .entries
      .map((entry) {
        final i = entry.key;
        final palabra = entry.value;
        if (palabra.isEmpty) return '';
        if (i == 0 || !excepciones.contains(palabra)) {
          return palabra[0].toUpperCase() + palabra.substring(1);
        } else {
          return palabra;
        }
      })
      .join(' ');
}
