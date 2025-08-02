import 'package:flutter/material.dart';

// 📦 Páginas principales
import '../features/home/home.dart';
import '../features/home/license/license.dart';
import '../features/dashboard/dashboard_principal.dart';

// 📦 Páginas de gestión académica
import '../features/pages/periodos/periodos_page.dart';
import '../features/pages/cursos/cursos_page.dart';
import '../features/pages/cursos/dashboard/dashboard_cursos.dart';
import '../features/pages/materias/materias_page.dart';
import '../features/pages/materias_curso/materias_curso_page.dart';
import '../features/pages/estudiantes/estudiantes_page.dart';

// 📦 Páginas de horarios y jornada
import '../features/pages/horarios/horarios_page.dart';
import '../features/pages/horarios/asignar_bloque_horario_page.dart';
import '../features/jornada/jornadas.dart'; // ✅ actualizado

// 📦 Modelos
import '../data/models/curso_model.dart';

class AppRoutes {
  // 🔖 Rutas nombradas
  static const String home = '/home';
  static const String licencia = '/licencia';
  static const String dashboard = '/dashboard';

  static const String periodos = '/periodos';
  static const String cursos = '/cursos';
  static const String dashboardCurso = '/dashboard-curso';
  static const String materias = '/materias';
  static const String materiasCurso = '/materias-curso';
  static const String estudiantes = '/estudiantes';

  static const String horario = '/horario';
  static const String asignarHorario = '/asignar-horario';
  static const String jornada = '/jornada';

  // 🧭 Generador de rutas
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case licencia:
        return MaterialPageRoute(builder: (_) => const LicenciaPage());

      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());

      case periodos:
        return MaterialPageRoute(builder: (_) => const PeriodosPage());

      case cursos:
        return MaterialPageRoute(builder: (_) => const CursosPage());

      case dashboardCurso:
        final curso = settings.arguments as Curso;
        return MaterialPageRoute(
          builder: (_) => DashboardCursoPage(curso: curso),
        );

      case materias:
        return MaterialPageRoute(builder: (_) => const MateriasPage());

      case materiasCurso:
        return MaterialPageRoute(builder: (_) => const MateriasCursoPage());

      case estudiantes:
        return MaterialPageRoute(builder: (_) => const EstudiantesPage());

      case horario:
        return MaterialPageRoute(builder: (_) => const HorariosPage());

      case asignarHorario:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AsignarBloqueHorarioPage(
            dia: args['dia'] as String,
            hora: args['hora'] as int,
            seleccionada: args['horario'], // opcional
          ),
        );

      case jornada:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => JornadaPage(
            cursoId: args['cursoId'] as int,
            curso: args['curso'] as String,
            materia: args['materia'] as String,
            dia: args['dia'] as String,
            hora: args['hora'] as String,
            materiaCursoId: args['materiaCursoId'] as int,
            fechaReal: args['fechaReal'] as DateTime, // ✅ nuevo parámetro
          ),
        );
    }

    // 🔒 Ruta por defecto si ninguna coincide
    return MaterialPageRoute(
      builder: (_) =>
          const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
    );
  }
}
