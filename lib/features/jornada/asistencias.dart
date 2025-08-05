import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/controllers/asistencias_controller.dart';
import '../../data/controllers/estudiantes_controller.dart';
import '../../data/models/estudiante_model.dart';
import '../../data/providers/asistencias_provider.dart';
import '../../shared/utils/texto_normalizado.dart';
import '../../shared/utils/horas.dart';
import '../../shared/utils/fechas.dart';

class AsistenciasSection extends ConsumerWidget {
  final int cursoId;
  final int materiaCursoId;
  final int hora;
  final String materia;
  final String dia;
  final DateTime fecha;

  const AsistenciasSection({
    super.key,
    required this.cursoId,
    required this.materiaCursoId,
    required this.hora,
    required this.materia,
    required this.dia,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fechaTexto = normalizarFecha(
      fecha,
    ).toIso8601String().substring(0, 10);
    final params = AsistenciasParams(
      cursoId: cursoId,
      materiaCursoId: materiaCursoId,
      hora: hora,
      fecha: fechaTexto,
    );

    final estudiantesAsync = ref.watch(estudiantesControllerProvider(cursoId));
    final asistenciasAsync = ref.watch(asistenciasControllerProvider(params));

    if (estudiantesAsync.isLoading || asistenciasAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (estudiantesAsync.hasError || asistenciasAsync.hasError) {
      final errorMensaje = estudiantesAsync.hasError
          ? 'Error al cargar estudiantes: ${estudiantesAsync.error}'
          : 'Error al cargar asistencias: ${asistenciasAsync.error}';
      return Center(child: Text(errorMensaje));
    }

    final estudiantes = estudiantesAsync.value!;

    final asistenciasMap = {
      for (final a in asistenciasAsync.value!) a.estudianteId: a.estado,
    };

    final conteo = {
      EstadoAsistencia.presente: 0,
      EstadoAsistencia.ausente: 0,
      EstadoAsistencia.justificado: 0,
    };

    for (final est in estudiantes) {
      final estadoNombre = asistenciasMap[est.id];
      final estado = EstadoAsistencia.values.firstWhere(
        (e) => e.name == estadoNombre,
        orElse: () => EstadoAsistencia.ausente,
      );
      conteo[estado] = conteo[estado]! + 1;
    }

    final GlobalKey tarjetaKey = GlobalKey();

    return Column(
      children: [
        Offstage(
          child: Container(
            key: tarjetaKey,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.transparent),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apellido',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text('Nombre', style: TextStyle(fontSize: 14)),
                ],
              ),
              trailing: SizedBox(
                width: 100,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Presente', style: TextStyle(fontSize: 13)),
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: EstadoAsistencia.values.map((estado) {
              return _contadorChip(
                _textoEstado(estado),
                conteo[estado]!,
                _colorEstado(estado),
              );
            }).toList(),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: estudiantes.length,
            itemBuilder: (_, index) {
              final est = estudiantes[index];
              final estudianteParams = AsistenciaParamsEstudiante(
                bloqueParams: params,
                estudianteId: est.id,
              );

              return Consumer(
                builder: (context, ref, _) {
                  final estado = ref.watch(
                    asistenciaPorEstudianteProvider(estudianteParams),
                  );
                  conteo[estado] = conteo[estado]! + 1;

                  return _tarjetaEstudiante(
                    est,
                    estado,
                    estudianteParams,
                    ref,
                    context,
                    fechaTexto,
                    params,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _tarjetaEstudiante(
    Estudiante est,
    EstadoAsistencia estado,
    AsistenciaParamsEstudiante estudianteParams,
    WidgetRef ref,
    BuildContext context,
    String fechaTexto,
    AsistenciasParams params,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _colorEstado(estado).withAlpha((0.4 * 255).round()),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              capitalizarConTildes(est.apellido),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              capitalizarConTildes(est.nombre),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        trailing: IntrinsicWidth(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorEstado(estado),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: Icon(_iconoEstado(estado), size: 18),
            label: Text(
              _textoEstado(estado),
              style: const TextStyle(fontSize: 13),
            ),
            onPressed: esFechaHoy(normalizarFecha(fecha))
                ? () async {
                    final nuevoEstado =
                        EstadoAsistencia.values[(estado.index + 1) %
                            EstadoAsistencia.values.length];
                    final controller = ref.read(
                      asistenciasControllerProvider(params).notifier,
                    );

                    try {
                      await controller.registrarAsistencia(
                        fecha: fechaTexto,
                        estudianteId: est.id,
                        estado: nuevoEstado.name,
                        params: params,
                      );
                    } catch (e, st) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '❌ Error: $e\n${st.toString().split('\n').take(3).join('\n')}',
                            ),
                            backgroundColor: Colors.redAccent,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                      return;
                    }

                    ref
                            .read(
                              asistenciaPorEstudianteProvider(
                                estudianteParams,
                              ).notifier,
                            )
                            .state =
                        nuevoEstado;
                  }
                : null,
          ),
        ),
      ),
    );
  }

  Widget _contadorChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text('$count', style: TextStyle(color: color, fontSize: 16)),
      ],
    );
  }

  String _textoEstado(EstadoAsistencia estado) {
    switch (estado) {
      case EstadoAsistencia.presente:
        return 'Presente';
      case EstadoAsistencia.ausente:
        return 'Ausente';
      case EstadoAsistencia.justificado:
        return 'Justificado';
    }
  }

  Color _colorEstado(EstadoAsistencia estado) {
    switch (estado) {
      case EstadoAsistencia.presente:
        return Colors.green;
      case EstadoAsistencia.ausente:
        return Colors.redAccent;
      case EstadoAsistencia.justificado:
        return Colors.orange;
    }
  }

  IconData _iconoEstado(EstadoAsistencia estado) {
    switch (estado) {
      case EstadoAsistencia.presente:
        return Icons.check;
      case EstadoAsistencia.ausente:
        return Icons.close;
      case EstadoAsistencia.justificado:
        return Icons.description;
    }
  }
}
