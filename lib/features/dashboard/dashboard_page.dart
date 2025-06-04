import 'package:flutter/material.dart';
import 'dart:io'; // Importar para cerrar la app

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profeshor1.0 - Panel Principal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildButton(
                    context,
                    "Periodos",
                    Icons.calendar_today,
                    '/periodos',
                  ),
                  _buildButton(context, "Clases", Icons.school, '/clases'),
                  _buildButton(context, "Materias", Icons.book, '/materias'),
                  _buildButton(
                    context,
                    "Evaluaciones",
                    Icons.assignment,
                    '/evaluaciones',
                  ),
                  _buildButton(
                    context,
                    "Asistencia",
                    Icons.check_circle,
                    '/asistencia',
                  ),
                  _buildButton(
                    context,
                    "Reportes",
                    Icons.bar_chart,
                    '/reportes',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => exit(0), // 🔹 Cierra la app
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.red,
              ),
              child: const Text(
                "Salir",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
