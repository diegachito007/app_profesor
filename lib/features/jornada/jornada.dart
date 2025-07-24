import 'package:flutter/material.dart';
import 'asistencias.dart';
import '../../../shared/utils/texto_normalizado.dart';

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
  bool _vistaHorizontal = false;

  final List<String> _titulos = ['Asistencias', 'Notas', 'Faltas', 'Resumen'];

  @override
  Widget build(BuildContext context) {
    final partes = widget.bloqueId.split('-');
    final materiaCursoId = partes.length >= 2
        ? int.tryParse(partes[1]) ?? 0
        : 0;

    final mostrarBotonGuardar = _index == 0;
    final botonGuardar = mostrarBotonGuardar
        ? ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Asistencia guardada')),
              );
            },
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Guardar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              textStyle: const TextStyle(fontSize: 13),
              backgroundColor: Colors.blueAccent,
            ),
          )
        : null;

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
        actions: _index == 0
            ? [
                IconButton(
                  icon: Icon(
                    _vistaHorizontal ? Icons.view_agenda : Icons.view_carousel,
                    color: Colors.white,
                  ),
                  tooltip: _vistaHorizontal
                      ? 'Vista vertical'
                      : 'Vista horizontal',
                  onPressed: () =>
                      setState(() => _vistaHorizontal = !_vistaHorizontal),
                ),
              ]
            : null,
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
                botonAccion: botonGuardar, // ✅ aquí va el botón
              ),
              const SizedBox(height: 24),
              Expanded(
                child: IndexedStack(
                  index: _index,
                  children: [
                    AsistenciasSection(
                      cursoId: widget.cursoId,
                      materiaCursoId: materiaCursoId,
                      hora: int.parse(widget.hora),
                      materia: widget.materia,
                      dia: widget.dia,
                      vistaHorizontal: _vistaHorizontal,
                    ),
                    const Center(child: Text('Notas (en construcción)')),
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
  final Widget? botonAccion;

  const EncabezadoJornada({
    super.key,
    required this.curso,
    required this.materia,
    required this.dia,
    required this.hora,
    this.botonAccion,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            if (botonAccion != null) botonAccion!,
          ],
        ),
      ],
    );
  }
}
