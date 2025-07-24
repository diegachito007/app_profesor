import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/texto_normalizado.dart';
import '../../data/models/estudiante_model.dart';
import '../../data/controllers/estudiantes_controller.dart';

class AsistenciasSection extends ConsumerStatefulWidget {
  final int cursoId;
  final int materiaCursoId;
  final int hora;
  final String materia;
  final String dia;
  final bool vistaHorizontal;

  const AsistenciasSection({
    super.key,
    required this.cursoId,
    required this.materiaCursoId,
    required this.hora,
    required this.materia,
    required this.dia,
    required this.vistaHorizontal,
  });

  @override
  ConsumerState<AsistenciasSection> createState() => _AsistenciasSectionState();
}

class _AsistenciasSectionState extends ConsumerState<AsistenciasSection> {
  bool _bloqueado = false;
  bool _modoConsulta = false;

  late final DateTime _fechaHorario;

  @override
  void initState() {
    super.initState();
    _fechaHorario = _obtenerFechaDesdeDia(widget.dia);
    _validarFecha();
  }

  void _validarFecha() {
    final hoy = DateTime.now();
    if (hoy.isBefore(_fechaHorario)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('Acceso restringido'),
              content: Text(
                'Hoy es ${_nombreDia(hoy.weekday)}.\n\nNo puedes registrar asistencia para ${widget.dia}.',
                style: const TextStyle(fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    Navigator.of(context).pop(); // Cierra la página
                  },
                  child: const Text('Volver al horario'),
                ),
              ],
            ),
          ),
        );
        setState(() => _bloqueado = true);
      });
    } else if (hoy.isAfter(_fechaHorario)) {
      setState(() => _modoConsulta = true);
    }
  }

  DateTime _obtenerFechaDesdeDia(String dia) {
    final hoy = DateTime.now();
    final dias = {
      'Lunes': 1,
      'Martes': 2,
      'Miércoles': 3,
      'Jueves': 4,
      'Viernes': 5,
      'Sábado': 6,
      'Domingo': 7,
    };
    final targetWeekday = dias[dia]!;
    final diferencia = targetWeekday - hoy.weekday;
    return hoy.add(Duration(days: diferencia));
  }

  String _nombreDia(int weekday) {
    const dias = {
      1: 'Lunes',
      2: 'Martes',
      3: 'Miércoles',
      4: 'Jueves',
      5: 'Viernes',
      6: 'Sábado',
      7: 'Domingo',
    };
    return dias[weekday]!;
  }

  @override
  Widget build(BuildContext context) {
    if (_bloqueado) return const SizedBox();

    final estudiantesAsync = ref.watch(
      estudiantesControllerProvider(widget.cursoId),
    );

    return estudiantesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error al cargar estudiantes: $e')),
      data: (estudiantes) {
        final conteo = {
          'Presente': 0,
          'Ausente': estudiantes.length,
          'Justificado': 0,
        };

        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _ContadorHeaderDelegate(conteo: conteo),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            widget.vistaHorizontal
                ? SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: PageView.builder(
                        itemCount: (estudiantes.length / 4).ceil(),
                        controller: PageController(viewportFraction: 0.95),
                        itemBuilder: (_, pageIndex) {
                          final inicio = pageIndex * 4;
                          final fin = (inicio + 4).clamp(0, estudiantes.length);
                          final grupo = estudiantes.sublist(inicio, fin);

                          return Column(
                            children: grupo
                                .map((e) => _buildCardEstudiante(e))
                                .toList(),
                          );
                        },
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _buildCardEstudiante(estudiantes[i]),
                      childCount: estudiantes.length,
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildCardEstudiante(Estudiante est) {
    const estado = 'Ausente'; // Estado inicial
    const switchValue = false;
    final switchEnabled = !_modoConsulta;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizarConTildes(est.apellido),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  capitalizarConTildes(est.nombre),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  estado,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IgnorePointer(
            ignoring: !switchEnabled,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (_) {},
              onTapDown: (_) {},
              child: Switch(
                value: switchValue,
                onChanged: switchEnabled
                    ? (value) {
                        // Aquí luego conectarás con AsistenciasController
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContadorHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Map<String, int> conteo;

  _ContadorHeaderDelegate({required this.conteo});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _contadorChip('Presente', conteo['Presente']!, Colors.green),
          ),
          Expanded(
            child: _contadorChip(
              'Ausente',
              conteo['Ausente']!,
              Colors.redAccent,
            ),
          ),
          Expanded(
            child: _contadorChip(
              'Justificado',
              conteo['Justificado']!,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contadorChip(String label, int count, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
