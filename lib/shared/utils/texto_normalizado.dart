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

/// 🔡 Formatter que convierte texto en mayúsculas y elimina tildes
class UpperCaseSinTildesFormatter extends TextInputFormatter {
  static const _tildes = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'Á': 'A',
    'É': 'E',
    'Í': 'I',
    'Ó': 'O',
    'Ú': 'U',
    'ñ': 'Ñ',
    'Ñ': 'Ñ',
  };

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String texto = newValue.text;
    _tildes.forEach((original, reemplazo) {
      texto = texto.replaceAll(original, reemplazo);
    });
    texto = texto.toUpperCase();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
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

/// 👤 Capitaliza nombre completo en formato "Apellidos Nombres"
String capitalizarNombreCompleto(String nombre, String apellido) {
  final texto = '${apellido.trim()} ${nombre.trim()}';
  return capitalizarConTildes(texto);
}

String limpiarNombre(String texto) {
  final limpio = texto
      .replaceAll(RegExp(r'\s+'), ' ') // Elimina espacios duplicados
      .trim(); // Elimina espacios al inicio y final
  return capitalizarConTildes(limpio);
}
