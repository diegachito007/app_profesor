import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../data/providers/periodo_activo_provider.dart';

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
        appBar: AppBar(title: const Text("Dashboard")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bienvenido",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 20),
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
      {"icon": Icons.class_, "title": "Cursos"},
      {"icon": Icons.menu_book, "title": "Materias"},
      {"icon": Icons.book_outlined, "title": "Mis materias"},
      {"icon": Icons.group, "title": "Estudiantes"},
      {"icon": Icons.grade, "title": "Notas"},
      {"icon": Icons.checklist, "title": "Asistencia"},
      {"icon": Icons.insert_chart, "title": "Reportes"},
      {"icon": Icons.calendar_today, "title": "Mi horario"}, // Nuevo ítem
    ];

    final colorMap = {
      "Cursos": Colors.teal.shade300,
      "Materias": Colors.deepPurple.shade300,
      "Mis materias": Colors.blueGrey.shade400,
      "Estudiantes": Colors.indigo.shade300,
      "Notas": Colors.orange.shade300,
      "Asistencia": Colors.pink.shade300,
      "Reportes": Colors.green.shade400,
      "Mi horario": Colors.blue.shade300, // Color para el nuevo ítem
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
                case "Cursos":
                  Navigator.pushNamed(context, '/cursos');
                  break;
                case "Materias":
                  Navigator.pushNamed(context, '/materias');
                  break;
                case "Mis materias":
                  Navigator.pushNamed(context, '/materias-curso');
                  break;
                case "Estudiantes":
                  Navigator.pushNamed(context, '/estudiantes');
                  break;
                case "Mi horario":
                  Navigator.pushNamed(context, '/horario');
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar salida"),
        content: const Text("¿Seguro que deseas salir de la aplicación?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop();
            },
            child: const Text("Sí"),
          ),
        ],
      ),
    );
  }
}
