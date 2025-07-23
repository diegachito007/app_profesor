import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../data/providers/periodo_activo_provider.dart';
import '../../data/providers/license_provider.dart';
import '../../features/license/license_storage.dart';
import '../../shared/utils/texto_normalizado.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _mostrarDialogoSalida(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final nombreAsync = ref.watch(nombrePropietarioProvider);

                  return nombreAsync.when(
                    data: (nombreRaw) {
                      final nombre = capitalizarTituloConTildes(
                        nombreRaw ?? 'Usuario',
                      );

                      return Column(
                        children: [
                          Text(
                            'Bienvenido',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            nombre,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => const Text('Error al cargar nombre'),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildPeriodosCard(context),
              const SizedBox(height: 10),
              Expanded(child: _buildGridMenu(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodosCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/periodos'),
      child: Consumer(
        builder: (context, ref, _) {
          final periodoActivo = ref.watch(periodoActivoProvider);
          final tieneActivo = periodoActivo != null;

          final cardColor = tieneActivo
              ? Colors.green.shade400
              : Colors.cyan.shade400;

          final subtitleText = tieneActivo
              ? 'Activo: ${periodoActivo.nombre}'
              : 'Gestiona los períodos activos';

          return Card(
            elevation: 8,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.date_range,
                color: Colors.white,
                size: 40,
              ),
              title: const Text(
                "Períodos Académicos",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                subtitleText,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context) {
    final items = [
      {"icon": Icons.class_, "title": "Mis Cursos"},
      {"icon": Icons.calendar_today, "title": "Mi horario"},
      {"icon": Icons.menu_book, "title": "Materias"},
      {"icon": Icons.grade, "title": "Notas"},
      {"icon": Icons.checklist, "title": "Asistencia"},
      {"icon": Icons.insert_chart, "title": "Reportes"},
    ];

    final colorMap = {
      "Mis Cursos": Colors.teal.shade300,
      "Materias": Colors.deepPurple.shade300,
      "Mis materias": Colors.blueGrey.shade400,
      "Mis Estudiantes": Colors.indigo.shade300,
      "Notas": Colors.orange.shade300,
      "Asistencia": Colors.pink.shade300,
      "Reportes": Colors.green.shade400,
      "Mi horario": Colors.blue.shade300,
    };

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final title = item["title"] as String;
        final icon = item["icon"] as IconData;
        final backgroundColor = colorMap[title] ?? Colors.blue.shade300;

        return Card(
          elevation: 8,
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () {
              switch (title) {
                case "Mis Cursos":
                  Navigator.pushNamed(context, '/cursos');
                  break;
                case "Mi horario":
                  Navigator.pushNamed(context, '/horario');
                  break;
                case "Materias":
                  Navigator.pushNamed(context, '/materias');
                  break;
                default:
                  _mostrarMensaje(context, title);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarMensaje(BuildContext context, String titulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Seleccionaste: $titulo"),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  void _mostrarDialogoSalida(BuildContext context) {
    ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    LicenseStorage.getNombreUsuario().then((nombre) {
      final nombreElegante = capitalizarTituloConTildes(nombre ?? 'Usuario');

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Confirmación',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estás a punto de cerrar la aplicación.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                '👋 ¡Hasta pronto, $nombreElegante!',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                navigator.pop();
                SystemNavigator.pop();
              },
              child: const Text('Salir'),
            ),
          ],
        ),
      );
    });
  }
}
