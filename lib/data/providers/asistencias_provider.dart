import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/asistencias_controller.dart';
import '../models/asistencia_model.dart';

enum EstadoAsistencia { presente, ausente, justificado }

/// Provider reactivo por estudiante para manejar su estado individual
final asistenciaPorEstudianteProvider =
    StateProvider.family<EstadoAsistencia, AsistenciaParamsEstudiante>((
      ref,
      params,
    ) {
      final asistenciasAsync = ref.watch(
        asistenciasControllerProvider(params.bloqueParams),
      );
      final asistencias = asistenciasAsync.value ?? [];

      final asistencia = asistencias.firstWhere(
        (a) => a.estudianteId == params.estudianteId,
        orElse: () => AsistenciaModel(
          estudianteId: params.estudianteId,
          fecha: params.bloqueParams.fecha,
          materiaCursoId: params.bloqueParams.materiaCursoId,
          hora: params.bloqueParams.hora,
          estado: 'presente',
        ),
      );

      final estado = asistencia.estado.toLowerCase();
      return EstadoAsistencia.values.firstWhere(
        (x) => x.name.toLowerCase() == estado,
        orElse: () => EstadoAsistencia.presente,
      );
    });

/// Parámetros combinados para identificar un estudiante dentro de un bloque
class AsistenciaParamsEstudiante {
  final AsistenciasParams bloqueParams;
  final int estudianteId;

  AsistenciaParamsEstudiante({
    required this.bloqueParams,
    required this.estudianteId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsistenciaParamsEstudiante &&
          runtimeType == other.runtimeType &&
          bloqueParams == other.bloqueParams &&
          estudianteId == other.estudianteId;

  @override
  int get hashCode => bloqueParams.hashCode ^ estudianteId.hashCode;
}
