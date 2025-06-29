import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para cerrar la app

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
      child: Card(
        elevation: 6,
        color: Colors.blue.shade300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(
            Icons.date_range,
            color: Colors.blue.shade900,
            size: 40,
          ),
          title: const Text(
            "Períodos Académicos",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            "Gestiona los períodos activos",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context) {
    final items = [
      {"icon": Icons.class_, "title": "Cursos"},
      {"icon": Icons.menu_book, "title": "Materias"},
      {"icon": Icons.group, "title": "Estudiantes"},
      {"icon": Icons.grade, "title": "Notas"},
      {"icon": Icons.checklist, "title": "Asistencia"},
      {"icon": Icons.insert_chart, "title": "Reportes"},
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final title = item["title"] as String;

        return Card(
          elevation: 6,
          color: Colors.blue.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () {
              if (title == "Cursos") {
                Navigator.pushNamed(context, '/cursos');
              } else {
                _mostrarMensaje(context, title);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item["icon"] as IconData,
                  color: Colors.blue.shade900,
                  size: 40,
                ),
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
