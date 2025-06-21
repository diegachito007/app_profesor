import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'shared/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProfeshorApp());
}

class ProfeshorApp extends StatelessWidget {
  const ProfeshorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profeshor',
      theme: AppTheme.temaProfeshor,
      initialRoute: '/home',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
