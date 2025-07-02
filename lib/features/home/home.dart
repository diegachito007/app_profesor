import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../shared/utils/arranque.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inicio'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Borrar base de datos',
              onPressed: () => _confirmarBorradoDB(context),
            ),
          ],
        ),
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
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  label: const Text('Iniciar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () => iniciarValidacionProfeshor(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmarBorradoDB(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar borrado'),
        content: const Text(
          '¿Deseas borrar la base de datos local?\nEsta acción es irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final dir = await getApplicationDocumentsDirectory();
              final path = p.join(dir.path, 'profeshor.db');
              final dbFile = File(path);

              if (await dbFile.exists()) {
                await dbFile.delete();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Base de datos eliminada. Reinicia la app.',
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se encontró la base de datos.'),
                    ),
                  );
                }
              }
            },
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }
}
