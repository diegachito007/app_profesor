import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'validacion_profeshor.dart';
import 'license/license_storage.dart';
import 'package:app_profesor/data/providers/database_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _validando = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inicio'),
          actions: [
            IconButton(
              icon: const Icon(Icons.vpn_key_off),
              tooltip: 'Borrar licencia',
              onPressed: () => _confirmarBorradoLicencia(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Borrar base de datos',
              onPressed: () => _confirmarBorradoDB(context),
            ),
            IconButton(
              icon: const Icon(Icons.upload_file),
              tooltip: 'Compartir base de datos',
              onPressed: () => _compartirBaseDeDatos(context),
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
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: ElevatedButton.icon(
                    label: const Text('Iniciar'),
                    icon: const Icon(Icons.login),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    onPressed: _validando
                        ? null
                        : () async {
                            setState(() => _validando = true);
                            await iniciarValidacionProfeshor(context, ref);
                            if (mounted) setState(() => _validando = false);
                          },
                  ),
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

              try {
                final db = await ref.read(databaseProvider.future);
                await db.close();
                debugPrint('📦 Base de datos cerrada correctamente');

                final dir = await getApplicationDocumentsDirectory();
                final path = p.join(dir.path, 'profeshor.db');
                final dbFile = File(path);

                if (await dbFile.exists()) {
                  await dbFile.delete();
                  debugPrint('🗑️ Archivo de base de datos eliminado');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Base de datos eliminada. Reinicia la app para continuar.',
                        ),
                        backgroundColor: Colors.redAccent,
                        action: SnackBarAction(
                          label: 'Cerrar app',
                          textColor: Colors.white,
                          onPressed: () => SystemNavigator.pop(),
                        ),
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
              } catch (e) {
                debugPrint('⚠️ Error al borrar la base de datos: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al borrar la base de datos:\n$e'),
                      backgroundColor: Colors.orange,
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

  void _confirmarBorradoLicencia(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Borrar licencia'),
        content: const Text(
          '¿Deseas borrar la licencia almacenada?\nEsto reiniciará el flujo de validación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await LicenseStorage.borrarLicencia();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Licencia eliminada. Reinicia el flujo.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _compartirBaseDeDatos(BuildContext context) async {
    try {
      final origen = await getApplicationDocumentsDirectory();
      final origenPath = p.join(origen.path, 'profeshor.db');
      final origenFile = File(origenPath);

      if (!await origenFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró la base de datos')),
          );
        }
        return;
      }

      await Share.shareXFiles([
        XFile(origenPath),
      ], text: 'Aquí está la base de datos de Profeshor.');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Archivo preparado para compartir.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('⚠️ Error al compartir la base de datos: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir la base de datos:\n$e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
