import 'package:flutter/material.dart';
import '../../features/license/license_storage.dart';
import '../../data/database/sqlite_service.dart';

Future<void> iniciarValidacionProfeshor(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final licenciaValida = await LicenseStorage.esLicenciaValida();
    if (!licenciaValida) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Licencia inválida'),
          content: Text('Por favor ingresa una licencia válida.'),
        ),
      );
      return;
    }

    final bdExiste = await SQLiteService.databaseExists();
    if (!bdExiste) {
      final ok = await _crearBaseDeDatos(); // sin usar context
      if (!ok) {
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Error'),
            content: Text('No se pudo crear la base de datos.'),
          ),
        );
        return;
      }
    }

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

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
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pushReplacementNamed(context, '/dashboard');
  } catch (e) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text('Ocurrió un problema inesperado:\n\n$e'),
      ),
    );
  }
}

Future<bool> _crearBaseDeDatos() async {
  try {
    await SQLiteService.inicializarBaseDeDatos();
    return true;
  } catch (e) {
    debugPrint('💥 Error al crear la base de datos: $e');
    return false;
  }
}
