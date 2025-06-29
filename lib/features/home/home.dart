import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/utils/arranque.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _yaEjecutado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_yaEjecutado) {
      _yaEjecutado = true;

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          iniciarValidacionProfeshor(context, ref);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', width: 120),
                const SizedBox(height: 40),
                const Text(
                  'Bienvenido a Profeshor',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
