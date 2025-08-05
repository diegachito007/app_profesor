import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../models/estudiante_model.dart';
import '../services/estudiantes_service.dart';
import '../services/asistencias_service.dart';
import '../services/notas_service.dart';
import '../providers/database_provider.dart';

class EstudianteConEstado {
  final Estudiante estudiante;
  final bool estaBloqueado;

  EstudianteConEstado({required this.estudiante, required this.estaBloqueado});
}

class NotasParams {
  final int cursoId;
  final int materiaCursoId;
  final int hora;
  final String fecha;

  NotasParams({
    required this.cursoId,
    required this.materiaCursoId,
    required this.hora,
    required this.fecha,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotasParams &&
          runtimeType == other.runtimeType &&
          cursoId == other.cursoId &&
          materiaCursoId == other.materiaCursoId &&
          hora == other.hora &&
          fecha == other.fecha;

  @override
  int get hashCode =>
      cursoId.hashCode ^
      materiaCursoId.hashCode ^
      hora.hashCode ^
      fecha.hashCode;
}

final notasControllerProvider =
    AsyncNotifierProviderFamily<
      NotasController,
      List<EstudianteConEstado>,
      NotasParams
    >(NotasController.new);

class NotasController
    extends FamilyAsyncNotifier<List<EstudianteConEstado>, NotasParams> {
  late EstudiantesService _estudiantesService;
  late AsistenciasService _asistenciasService;
  late NotasService _notasService;

  @override
  Future<List<EstudianteConEstado>> build(NotasParams params) async {
    final db = await ref.watch(databaseProvider.future);
    _estudiantesService = EstudiantesService(db);
    _asistenciasService = AsistenciasService(db);
    _notasService = NotasService(db);

    final estudiantes = await _estudiantesService.obtenerPorCurso(
      params.cursoId,
    );
    final asistencias = await _asistenciasService.obtenerPorBloque(
      fecha: params.fecha,
      materiaCursoId: params.materiaCursoId,
      hora: params.hora,
    );

    return estudiantes.map((est) {
      final asistencia = asistencias.firstWhereOrNull(
        (a) => a.estudianteId == est.id,
      );

      final estaBloqueado =
          asistencia == null ||
          (asistencia.estado != 'presente' &&
              asistencia.estado != 'Justificado');

      return EstudianteConEstado(estudiante: est, estaBloqueado: estaBloqueado);
    }).toList();
  }

  /// 🧠 Genera un código único para el tema evaluado
  Future<String> generarCodigoNotaTema({
    required String tipoAbreviado,
    required int materiaCursoId,
    required int notaTipoId, // ← actualizado
  }) async {
    return '$tipoAbreviado-MC$materiaCursoId-TN$notaTipoId';
  }

  /// 📝 Guarda una nota delegando al service
  Future<void> guardarNota({
    required int estudianteId,
    required int materiaCursoId,
    required int notaTipoId, // ← actualizado
    required int hora,
    required String fecha,
    required String tema,
    required double notaFinal,
    required String codigoNotaTema,
  }) async {
    await _notasService.guardarNota(
      estudianteId: estudianteId,
      materiaCursoId: materiaCursoId,
      notaTipoId: notaTipoId, // ← actualizado
      hora: hora,
      fecha: fecha,
      tema: tema,
      notaFinal: notaFinal,
      codigoNotaTema: codigoNotaTema,
    );
  }
}
