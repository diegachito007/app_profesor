import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/controllers/horarios_controller.dart';
import '../../../data/controllers/jornadas_controller.dart';
import '../../../data/models/horario_expandido.dart';
import '../../../data/models/horario_model.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/utils/texto_normalizado.dart';
import '../../../shared/utils/fechas.dart';
import '../../../shared/utils/horas.dart';
import '../../../shared/utils/colores.dart';

class HorariosPage extends ConsumerStatefulWidget {
  const HorariosPage({super.key});

  @override
  ConsumerState<HorariosPage> createState() => _HorariosPageState();
}

class _HorariosPageState extends ConsumerState<HorariosPage> {
  final List<String> dias = const [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
  ];
  late final PageController _semanaController;
  late final List<List<DateTime>> semanas;

  late int semanaActualIndex;
  late int diaVisibleIndex;
  final Set<String> _snackBarQueue = {};

  @override
  void initState() {
    super.initState();

    semanas = List.generate(7, (i) {
      final base = obtenerLunesDeSemana(
        DateTime.now(),
      ).subtract(Duration(days: 7 * (3 - i)));
      return dias.map((dia) => obtenerFechaDelDia(dia, base)).toList();
    });

    semanaActualIndex = semanas.indexWhere(
      (semana) => semana.any((d) => esMismoDia(d, DateTime.now())),
    );
    if (semanaActualIndex == -1) semanaActualIndex = 3;

    diaVisibleIndex = obtenerDiaVisibleIndex(DateTime.now(), dias);
    _semanaController = PageController(initialPage: semanaActualIndex);
  }

  void mostrarSnackBar(String mensaje) {
    if (_snackBarQueue.contains(mensaje)) return;
    _snackBarQueue.add(mensaje);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
        onVisible: () => Future.delayed(const Duration(seconds: 2), () {
          _snackBarQueue.remove(mensaje);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semana = semanas[semanaActualIndex];
    final fechaDelDia = semana[diaVisibleIndex];
    final dia = dias[diaVisibleIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mi horario',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 48,
            color: Colors.white,
            child: PageView.builder(
              controller: _semanaController,
              itemCount: semanas.length,
              onPageChanged: (index) {
                if (esSemanaFuturaCompleta(semanas[index])) {
                  mostrarSnackBar("Semana futura no disponible");
                  _semanaController.jumpToPage(semanaActualIndex);
                } else {
                  setState(() {
                    semanaActualIndex = index;
                    diaVisibleIndex = obtenerDiaVisibleIndex(
                      DateTime.now(),
                      dias,
                    );
                  });
                }
              },
              itemBuilder: (_, index) {
                final semana = semanas[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(dias.length, (i) {
                    final fecha = semana[i];
                    final activo = i == diaVisibleIndex;
                    final esFuturo = esFechaFutura(fecha);

                    return GestureDetector(
                      onTap: !esFuturo
                          ? () => setState(() => diaVisibleIndex = i)
                          : () => mostrarSnackBar("No puedes ver días futuros"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: activo ? Colors.blue.shade50 : null,
                        ),
                        child: Text(
                          '${dias[i][0]}:${fecha.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: activo ? Colors.blue : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          Expanded(child: _buildDiaView(context, ref, dia, fechaDelDia)),
        ],
      ),
    );
  }

  Widget _buildDiaView(
    BuildContext context,
    WidgetRef ref,
    String dia,
    DateTime fechaDelDia,
  ) {
    final horariosAsync = ref.watch(horariosControllerProvider(dia));
    final esDiaFuturo = esFechaFutura(fechaDelDia) && !esFechaHoy(fechaDelDia);

    return horariosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (horarios) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          children: bloquesHorarios.map((hora) {
            final bloque = horarios.firstWhere(
              (h) => h.horario.hora == hora,
              orElse: () => HorarioExpandido(
                horario: Horario(
                  id: 0,
                  dia: dia,
                  hora: hora,
                  materiaCursoId: 0,
                ),
                materiaCurso: null,
                nombreCurso: '',
                nombreMateria: '',
              ),
            );

            final estaVacio = bloque.horario.id == 0;
            final esActivo = bloque.estaActivo;
            final curso = bloque.nombreCursoFinal;
            final materia = bloque.nombreMateriaFinal;

            final cardColor = esDiaFuturo
                ? Colors.grey.shade100
                : estaVacio
                ? Colors.grey.shade200
                : colorSuavizadoPorCursoMateria(
                    curso,
                    materia,
                    esActivo: esActivo,
                  );

            final bordeColor = colorSuavizadoPorCursoMateria(
              curso,
              materia,
              esActivo: true,
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: bordeColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    hora.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                title: estaVacio
                    ? const Text(
                        'Bloque sin asignar',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            curso,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: esActivo ? Colors.indigo : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            capitalizarTituloConTildes(materia),
                            style: TextStyle(
                              fontSize: 14,
                              color: esActivo ? Colors.black87 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                trailing: estaVacio
                    ? IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: "Asignar bloque",
                        onPressed: !esDiaFuturo
                            ? () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.asignarHorario,
                                  arguments: {
                                    'dia': dia,
                                    'hora': hora,
                                    'horario': null,
                                  },
                                );
                              }
                            : null,
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        tooltip: "Eliminar bloque",
                        onPressed: !esDiaFuturo
                            ? () async {
                                final confirmar =
                                    await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 20,
                                            ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.warning_amber_rounded,
                                              color: Colors.redAccent,
                                              size: 48,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              '¿Eliminar bloque?',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Esta acción eliminará el bloque asignado a la hora $hora del $dia.\n\nNo se eliminarán las materias ni cursos, solo la asignación en el horario.',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;

                                if (confirmar) {
                                  final controller = ref.read(
                                    horariosControllerProvider(dia).notifier,
                                  );
                                  await controller.eliminarHorario(
                                    bloque.horario.id!,
                                  );
                                  if (!context.mounted) return;
                                  mostrarSnackBar('Bloque eliminado');
                                }
                              }
                            : null,
                      ),
                onTap: (!estaVacio && !esDiaFuturo)
                    ? () async {
                        final fecha = DateFormat(
                          'yyyy-MM-dd',
                        ).format(fechaDelDia);
                        final materiaCursoId = bloque.materiaCurso?.id ?? 0;
                        final cursoId = bloque.materiaCurso?.cursoId ?? 0;

                        final jornadaController = ref.read(
                          jornadasControllerProvider(materiaCursoId).notifier,
                        );
                        final jornadaExistente = await jornadaController
                            .obtenerJornadaPorBloque(
                              fecha: fecha,
                              materiaCursoId: materiaCursoId,
                              hora: hora,
                            );

                        if (!context.mounted) return;

                        final esHoy = esFechaHoy(fechaDelDia);
                        final esPasado = esFechaPasada(fechaDelDia);

                        if (jornadaExistente != null) {
                          if (jornadaExistente.estado == 'activa') {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.jornada,
                              arguments: {
                                'cursoId': cursoId,
                                'curso': curso,
                                'materia': materia,
                                'dia': dia,
                                'hora': hora.toString(),
                                'materiaCursoId': materiaCursoId,
                                'fechaReal': fechaDelDia,
                              },
                            );
                          } else if (jornadaExistente.estado == 'suspendida') {
                            if (esHoy) {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text('Clase suspendida'),
                                  content: const Text(
                                    '¿Deseas reactivarla? Solo si no hay asistencias registradas.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Reactivar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmar == true) {
                                final ok = await jornadaController
                                    .intentarReactivacion(
                                      materiaCursoId: materiaCursoId,
                                      fecha: fecha,
                                      hora: hora,
                                    );

                                if (ok) {
                                  ref.invalidate(
                                    jornadasControllerProvider(materiaCursoId),
                                  );
                                  ref.invalidate(
                                    horariosControllerProvider(dia),
                                  );

                                  if (!context.mounted) return;

                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.jornada,
                                    arguments: {
                                      'cursoId': cursoId,
                                      'curso': curso,
                                      'materia': materia,
                                      'dia': dia,
                                      'hora': hora.toString(),
                                      'materiaCursoId': materiaCursoId,
                                      'fechaReal': fechaDelDia,
                                    },
                                  );
                                } else {
                                  mostrarSnackBar(
                                    '⛔ No se pudo reactivar: ya hay asistencias registradas',
                                  );
                                }
                              }
                            } else if (esPasado) {
                              await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text('Clase suspendida'),
                                  content: const Text(
                                    'Esta jornada fue suspendida.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cerrar'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }

                          return;
                        }

                        if (esHoy) {
                          final resultado = await showDialog<String>(
                            context: context,
                            builder: (_) => DialogConfirmacionClase(
                              curso: curso,
                              materia: materia,
                              hora: hora.toString(),
                              fecha: fechaDelDia,
                            ),
                          );

                          if (!context.mounted) return;

                          if (resultado == 'asistencia') {
                            await jornadaController.insertarJornada(
                              fecha: fecha,
                              materiaCursoId: materiaCursoId,
                              hora: hora,
                              estado: 'activa',
                            );

                            ref.invalidate(
                              jornadasControllerProvider(materiaCursoId),
                            );
                            ref.invalidate(horariosControllerProvider(dia));

                            final nuevaJornada = await jornadaController
                                .obtenerJornadaPorBloque(
                                  fecha: fecha,
                                  materiaCursoId: materiaCursoId,
                                  hora: hora,
                                );

                            if (!context.mounted || nuevaJornada == null) {
                              return;
                            }

                            Navigator.pushNamed(
                              context,
                              AppRoutes.jornada,
                              arguments: {
                                'cursoId': cursoId,
                                'curso': curso,
                                'materia': materia,
                                'dia': dia,
                                'hora': hora.toString(),
                                'materiaCursoId': materiaCursoId,
                                'fechaReal': fechaDelDia,
                              },
                            );
                          } else if (resultado == 'suspendida') {
                            final motivo = await showDialog<String>(
                              context: context,
                              builder: (_) => DialogSuspensionClase(
                                curso: curso,
                                materia: materia,
                                hora: hora.toString(),
                                fecha: fechaDelDia,
                              ),
                            );

                            if (!context.mounted) return;

                            if (motivo != null && motivo.trim().isNotEmpty) {
                              await jornadaController.insertarJornada(
                                fecha: fecha,
                                materiaCursoId: materiaCursoId,
                                hora: hora,
                                estado: 'suspendida',
                                detalle: motivo.trim(),
                              );

                              ref.invalidate(
                                jornadasControllerProvider(materiaCursoId),
                              );
                              ref.invalidate(horariosControllerProvider(dia));

                              mostrarSnackBar(
                                '✅ Clase suspendida correctamente',
                              );
                            } else {
                              mostrarSnackBar(
                                '⚠️ Motivo vacío, no se suspendió',
                              );
                            }
                          }
                        } else if (esPasado) {
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text('Sin jornada registrada'),
                              content: const Text(
                                'No existe jornada registrada para este día.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// Diálogo de confirmación
class DialogConfirmacionClase extends StatelessWidget {
  final String curso;
  final String materia;
  final String hora;
  final DateTime fecha;

  const DialogConfirmacionClase({
    super.key,
    required this.curso,
    required this.materia,
    required this.hora,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Confirmar jornada',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dato('Curso', curso),
          _dato('Materia', materia),
          _dato('Hora', hora),
          _dato('Fecha', DateFormat('dd/MM/yyyy').format(fecha)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'suspendida'),
          child: const Text('Suspender clase'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () => Navigator.pop(context, 'asistencia'),
          label: const Text('Registrar asistencia'),
        ),
      ],
    );
  }

  Widget _dato(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// Diálogo para motivo de suspensión
class DialogSuspensionClase extends StatefulWidget {
  final String curso;
  final String materia;
  final String hora;
  final DateTime fecha;

  const DialogSuspensionClase({
    super.key,
    required this.curso,
    required this.materia,
    required this.hora,
    required this.fecha,
  });

  @override
  State<DialogSuspensionClase> createState() => _DialogSuspensionClaseState();
}

class _DialogSuspensionClaseState extends State<DialogSuspensionClase> {
  final TextEditingController _motivoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Motivo de suspensión',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dato('Curso', widget.curso),
          _dato('Materia', widget.materia),
          _dato('Hora', widget.hora),
          _dato('Fecha', DateFormat('dd/MM/yyyy').format(widget.fecha)),
          const SizedBox(height: 12),
          TextField(
            controller: _motivoController,
            decoration: const InputDecoration(
              labelText: 'Motivo de suspensión',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save_alt),
          onPressed: () => Navigator.pop(context, _motivoController.text),
          label: const Text('Guardar motivo'),
        ),
      ],
    );
  }

  Widget _dato(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
