import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pgfbsoainrumbscqbjvo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnZmJzb2FpbnJ1bWJzY3FianZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg4MzQ5MjYsImV4cCI6MjA2NDQxMDkyNn0.gV1W6Fs2bQpsUo2Hh2PQforhVk-7iVge3qI29465XgU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profeshor1.0', // 🔹 Se agregó el título de la app
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/home',
      routes: appRoutes,
    );
  }
}
