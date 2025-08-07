import 'package:flutter/material.dart';
import '../../../../data/models/curso_model.dart';
import 'materias_tab.dart';
import 'estudiantes_tab.dart';
import 'registros_tab.dart';

class DashboardCursoPage extends StatefulWidget {
  final Curso curso;

  const DashboardCursoPage({super.key, required this.curso});

  @override
  State<DashboardCursoPage> createState() => _DashboardCursoPageState();
}

class _DashboardCursoPageState extends State<DashboardCursoPage> {
  int _index = 0;
  String _tituloPorIndex(int index) {
    final base = widget.curso.nombreCompleto;
    switch (index) {
      case 0:
        return '$base : Materias';
      case 1:
        return '$base : Estudiantes';
      case 2:
        return '$base : Registros';
      default:
        return base;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      MateriasTab(
        cursoId: widget.curso.id,
        nombreCurso: widget.curso.nombreCompleto,
      ),
      EstudiantesTab(
        cursoId: widget.curso.id,
        nombreCurso: widget.curso.nombreCompleto,
      ),
      RegistroTab(cursoId: widget.curso.id),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        centerTitle: true,
        title: Text(
          _tituloPorIndex(_index),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: tabs[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Materias'),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Estudiantes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Registros',
          ),
        ],
      ),
    );
  }
}
