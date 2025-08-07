import 'package:flutter/material.dart';

/// Genera un color único por nombre de curso usando hashCode.
/// Se usa como base para diferenciar visualmente cada curso.
Color colorPorCurso(String nombreCurso) {
  final hash = nombreCurso.hashCode;
  final r = (hash & 0xFF0000) >> 16;
  final g = (hash & 0x00FF00) >> 8;
  final b = (hash & 0x0000FF);
  return Color.fromARGB((0.85 * 255).round(), r, g, b);
}

/// Ajusta el color base del curso según el nombre de la materia.
/// Útil para diferenciar bloques dentro del mismo curso.
Color colorPorCursoMateria(String nombreCurso, String nombreMateria) {
  final base = colorPorCurso(nombreCurso);
  final materiaHash = nombreMateria.hashCode;
  final delta = (materiaHash % 30) - 15;

  int adjust(double channel) =>
      ((channel * 255.0).round() + delta).clamp(0, 255);
  final alpha = (base.a * 255.0).round() & 0xff;

  return Color.fromARGB(alpha, adjust(base.r), adjust(base.g), adjust(base.b));
}

/// Suaviza el color generado para usar como fondo o borde.
/// Ideal para tarjetas, bloques o indicadores visuales.
Color colorSuavizadoPorCursoMateria(
  String curso,
  String materia, {
  bool esActivo = true,
}) {
  final base = colorPorCursoMateria(curso, materia);
  final factor = esActivo ? 0.12 : 0.05;
  return Color.lerp(Colors.white, base, factor)!;
}

/// Suaviza el color base del curso para usar como fondo en tarjetas.
/// Útil cuando no hay materias involucradas (como en cursos_page).
Color colorSuavizadoPorCurso(String nombreCurso, {double factor = 0.08}) {
  final base = colorPorCurso(nombreCurso);
  return Color.lerp(Colors.white, base, factor)!;
}

Color colorSuavizadoPorMateria(String nombreCurso, {double factor = 0.08}) {
  final base = colorPorCurso(nombreCurso);
  return Color.lerp(Colors.white, base, factor)!;
}
