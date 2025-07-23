import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../license/license_storage.dart';
import '../../data/providers/database_provider.dart';

Future<void> iniciarValidacionProfeshor(
  BuildContext context,
  WidgetRef ref,
) async {
  // Mostrar diálogo de carga inicial
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
    useRootNavigator: true,
  );

  try {
    final licenciaValida = await LicenseStorage.esLicenciaValida();

    if (!licenciaValida) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Cierra loader

      // Mostrar alerta y esperar confirmación
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Licencia inválida'),
          content: const Text('Por favor ingresa una licencia válida.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );

      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/licencia');
      return;
    }

    // Inicializar base de datos desde el provider
    final db = await ref.read(databaseProvider.future);
    if (db.isOpen) {
      debugPrint('📦 Base de datos abierta correctamente');
    }

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Cierra loader

    // Mostrar bienvenida con progreso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text('Bienvenido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cargando Profeshor...'),
            SizedBox(height: 16),
            LinearProgressIndicator(),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Cierra bienvenida
    Navigator.pushReplacementNamed(context, '/dashboard');
  } catch (e) {
    if (!context.mounted) return;
    Navigator.of(
      context,
      rootNavigator: true,
    ).pop(); // Cierra cualquier diálogo

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text('Ocurrió un problema inesperado:\n\n${e.toString()}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
