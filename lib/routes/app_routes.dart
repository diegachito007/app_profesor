import 'package:flutter/material.dart';
import '../features/home/home_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/licencia/licencia_page.dart';
import '../features/periodos/periodos_page.dart'; // ✅ Agrega la importación

final Map<String, WidgetBuilder> appRoutes = {
  '/home': (context) => const HomePage(),
  '/dashboard': (context) => const DashboardPage(),
  '/licencia': (context) => const LicenciaPage(),
  '/periodos': (context) =>
      const PeriodosPage(), // ✅ Agrega la ruta de períodos
};
