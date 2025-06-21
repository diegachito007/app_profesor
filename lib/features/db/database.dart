import 'package:flutter/material.dart';
import '../../data/database/sqlite_service.dart';

class DatabaseHelper {
  /// Inicializa la base de datos mostrando un diálogo de carga.
  /// Si hay éxito, redirige al dashboard. Si hay error, muestra una alerta.
  static Future<void> inicializar(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DialogCreandoBase(),
    );

    try {
      await SQLiteService.inicializarBaseDeDatos();

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Cierra el diálogo
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      debugPrint('💥 Error al crear la base de datos: $e');

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Cierra el diálogo

        // Muestra alerta de error
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error al crear la base de datos'),
            content: Text(
              'Hubo un problema al inicializar la base local.\n\nDetalles:\n$e',
              style: const TextStyle(color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    }
  }
}

class _DialogCreandoBase extends StatelessWidget {
  const _DialogCreandoBase();

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Espere'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Creando base de datos...'),
        ],
      ),
    );
  }
}
