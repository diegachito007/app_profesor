import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './features/license/config.dart';
import 'routes/app_routes.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );

  debugPrint('✅ Supabase inicializado correctamente');

  runApp(const ProviderScope(child: ProfeshorApp()));
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
