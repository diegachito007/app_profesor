import 'package:flutter/material.dart';

// Páginas principales
import '../features/home/home.dart';
import '../features/license/license.dart';
import '../features/dashboard/dashboard_page.dart';

// Páginas de gestión
import '../features/pages/periodos_page.dart';
import '../features/pages/cursos/cursos_page.dart';
import '../features/pages/materias_page.dart';
import '../features/pages/materias_curso/materias_curso_page.dart';
import '../features/pages/estudiantes/estudiantes_page.dart'; // 👈 Nueva importación

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

      case '/estudiantes': // 👈 Nueva ruta registrada
        return MaterialPageRoute(builder: (_) => const EstudiantesPage());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        );
    }
  }
}
