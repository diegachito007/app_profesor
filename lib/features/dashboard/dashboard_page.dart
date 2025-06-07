import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para cerrar la app

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Evita que el usuario salga directamente
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _mostrarDialogoSalida(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Dashboard")), // ✅ Título visible aquí
        body: const Center(child: Text("Bienvenido al Dashboard")),
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop(); // ✅ Cierra la aplicación
            },
            child: const Text("Sí"),
          ),
        ],
      ),
    );
  }
}
