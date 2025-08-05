import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'asistencias.dart';
import 'notas.dart';
import '../../../shared/utils/texto_normalizado.dart';

class JornadasPage extends ConsumerStatefulWidget {
  final int cursoId;
  final String curso;
  final String materia;
  final String dia;
  final String hora;
  final int materiaCursoId;
  final DateTime fechaReal;

  const JornadasPage({
    super.key,
    required this.cursoId,
    required this.curso,
    required this.materia,
    required this.dia,
    required this.hora,
    required this.materiaCursoId,
    required this.fechaReal,
  });

  @override
  ConsumerState<JornadasPage> createState() => _JornadasPageState();
}

class _JornadasPageState extends ConsumerState<JornadasPage> {
  int _index = 0;
  final List<String> _titulos = ['Asistencia', 'Notas', 'Faltas', 'Resumen'];

  @override
  Widget build(BuildContext context) {
    final fechaTexto = DateFormat('yyyy-MM-dd').format(widget.fechaReal);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        centerTitle: true,
        title: Text(
          _titulos[_index],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: null,
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
                fecha: fechaTexto,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: IndexedStack(
                  index: _index,
                  children: [
                    AsistenciasSection(
                      cursoId: widget.cursoId,
                      materiaCursoId: widget.materiaCursoId,
                      hora: int.parse(widget.hora),
                      materia: widget.materia,
                      dia: widget.dia,
                      fecha: widget.fechaReal,
                    ),
                    NotasSection(
                      cursoId: widget.cursoId,
                      materiaCursoId: widget.materiaCursoId,
                      hora: int.parse(widget.hora),
                      fecha: widget.fechaReal,
                    ),
                    const Center(child: Text('Faltas (en construcción)')),
                    const Center(child: Text('Resumen (en construcción)')),
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
            icon: Icon(Icons.event_busy),
            label: 'Faltas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Resumen',
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
  final String fecha;

  const EncabezadoJornada({
    super.key,
    required this.curso,
    required this.materia,
    required this.dia,
    required this.hora,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          curso,
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        Text(
          capitalizarTituloConTildes(materia),
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
              'Día: $dia · Hora: $hora · Fecha: $fecha',
              style: const TextStyle(fontSize: 13.5, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }
}
