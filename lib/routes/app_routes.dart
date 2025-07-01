import 'package:flutter/material.dart';

import '../features/home/home.dart';
import '../features/license/license.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/pages/periodos_page.dart';
import '../features/pages/cursos_page.dart';
import '../features/pages/materias_page.dart'; // 👈 Nuevo import

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
      case '/materias': // 👈 Nueva ruta
        return MaterialPageRoute(builder: (_) => const MateriasPage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        );
    }
  }
}
