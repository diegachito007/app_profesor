import 'package:flutter/material.dart';

// Páginas principales
import '../data/models/curso_model.dart';
import '../features/home/home.dart';
import '../features/license/license.dart';
import '../features/dashboard/dashboard_page.dart';

// Páginas de gestión
import '../features/pages/periodos_page.dart';
import '../features/pages/cursos/cursos_page.dart';
import '../features/pages/materias_page.dart';
import '../features/pages/materias_curso/materias_curso_page.dart';
import '../features/pages/estudiantes/estudiantes_page.dart';
import '../features/pages/estudiantes/importar_estudiantes_page.dart'; // 👈 Nueva importación

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());

      case '/licencia':
        return MaterialPageRoute(builder: (_) => const LicenciaPage());

      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardPage());

      case '/periodos':
        return MaterialPageRoute(builder: (_) => const PeriodosPage());

      case '/cursos':
        return MaterialPageRoute(builder: (_) => const CursosPage());

      case '/materias':
        return MaterialPageRoute(builder: (_) => const MateriasPage());

      case '/materias-curso':
        return MaterialPageRoute(builder: (_) => const MateriasCursoPage());

      case '/estudiantes':
        return MaterialPageRoute(builder: (_) => const EstudiantesPage());

      case '/importar-estudiantes':
        final curso = settings.arguments as Curso;
        return MaterialPageRoute(
          builder: (_) => ImportarEstudiantesPage(curso: curso),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        );
    }
  }
}
