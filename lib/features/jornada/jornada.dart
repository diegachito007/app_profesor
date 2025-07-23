import 'package:flutter/material.dart';
import 'asistencia.dart';
// import 'notas.dart';
// import 'actividades.dart';
// import 'evaluaciones.dart';

class JornadaPage extends StatefulWidget {
  final int cursoId;
  final String curso;
  final String materia;
  final String dia;
  final String hora;
  final String bloqueId;

  const JornadaPage({
    super.key,
    required this.cursoId,
    required this.curso,
    required this.materia,
    required this.dia,
    required this.hora,
    required this.bloqueId,
  });

  @override
  State<JornadaPage> createState() => _JornadaPageState();
}

class _JornadaPageState extends State<JornadaPage> {
  int _index = 0;

  final List<String> _titulos = [
    'Asistencia',
    'Notas',
    'Actividades',
    'Evaluaciones',
  ];

  @override
  Widget build(BuildContext context) {
    // 🧠 Extraer materiaCursoId y materiaId desde bloqueId
    final partes = widget.bloqueId.split('-');
    final materiaCursoId = partes.length >= 2
        ? int.tryParse(partes[1]) ?? 0
        : 0;
    final materiaId = partes.length >= 2 ? int.tryParse(partes[1]) ?? 0 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_index]),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EncabezadoJornada(
                curso: widget.curso,
                materia: widget.materia,
                dia: widget.dia,
                hora: widget.hora,
                cursoId: widget.cursoId,
                materiaId: materiaId,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: IndexedStack(
                  index: _index,
                  children: [
                    AsistenciaSection(
                      cursoId: widget.cursoId,
                      materiaCursoId: materiaCursoId,
                      hora: int.parse(widget.hora),
                    ),
                    const Center(child: Text('Notas (en construcción)')),
                    const Center(child: Text('Actividades (en construcción)')),
                    const Center(child: Text('Evaluaciones (en construcción)')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.black45,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Asistencia',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Notas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Evaluaciones',
          ),
        ],
      ),
    );
  }
}

class EncabezadoJornada extends StatelessWidget {
  final String curso;
  final String materia;
  final String dia;
  final String hora;
  final int cursoId;
  final int materiaId;

  const EncabezadoJornada({
    super.key,
    required this.curso,
    required this.materia,
    required this.dia,
    required this.hora,
    required this.cursoId,
    required this.materiaId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$curso ($cursoId)',
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$materia ($materiaId)',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.schedule_outlined,
              color: Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Día: $dia · Hora: $hora',
              style: const TextStyle(fontSize: 13.5, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }
}
