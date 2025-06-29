import 'package:flutter/material.dart';

import '../features/home/home.dart';
import '../features/license/license.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/pages/periodos_page.dart';
import '../features/pages/cursos_page.dart'; // Ajusta la ruta si es diferente

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
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        );
    }
  }
}
