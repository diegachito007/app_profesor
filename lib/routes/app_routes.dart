import 'package:flutter/material.dart';
import '../features/home/home_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/licencia/licencia_page.dart'; // 🔹 Se añade la ruta de licencia

final Map<String, WidgetBuilder> appRoutes = {
  '/home': (context) => const HomePage(),
  '/dashboard': (context) => const DashboardPage(),
  '/licencia': (context) => const LicenciaPage(), // 🔹 Ruta agregada
};
