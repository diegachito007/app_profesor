import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asistencia_model.dart';
import '../services/asistencias_service.dart';
import '../services/estudiantes_service.dart';
import '../providers/database_provider.dart';
import '../providers/asistencias_trigger_provider.dart';

class AsistenciasParams {
  final int cursoId;
  final int materiaCursoId;
  final int hora;
  final String fecha;

  AsistenciasParams({
    required this.cursoId,
    required this.materiaCursoId,
    required this.hora,
    required this.fecha,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsistenciasParams &&
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

final asistenciasControllerProvider =
    AsyncNotifierProviderFamily<
      AsistenciasController,
      List<AsistenciaModel>,
      AsistenciasParams
    >(AsistenciasController.new);

class AsistenciasController
    extends FamilyAsyncNotifier<List<AsistenciaModel>, AsistenciasParams> {
  late AsistenciasService _asistenciaService;
  late EstudiantesService _estudiantesService;

  @override
  Future<List<AsistenciaModel>> build(AsistenciasParams params) async {
    final db = await ref.watch(databaseProvider.future);
    _asistenciaService = AsistenciasService(db);
    _estudiantesService = EstudiantesService(db);

    final estudiantes = await _estudiantesService.obtenerPorCurso(
      params.cursoId,
    );
    if (estudiantes.isEmpty) return [];

    final asistenciasExistentes = await _asistenciaService.obtenerPorBloque(
      fecha: params.fecha,
      materiaCursoId: params.materiaCursoId,
      hora: params.hora,
    );

    final insercionesPendientes = estudiantes.where((est) {
      return !asistenciasExistentes.any(
        (a) =>
            a.estudianteId == est.id &&
            a.fecha == params.fecha &&
            a.hora == params.hora &&
            a.materiaCursoId == params.materiaCursoId,
      );
    });

    for (final est in insercionesPendientes) {
      await _asistenciaService.insertar(
        estudianteId: est.id,
        fecha: params.fecha,
        materiaCursoId: params.materiaCursoId,
        hora: params.hora,
      );
    }

    return await _asistenciaService.obtenerPorBloque(
      fecha: params.fecha,
      materiaCursoId: params.materiaCursoId,
      hora: params.hora,
    );
  }

  /// ✏️ Actualiza el estado de asistencia de un estudiante
  Future<void> registrarAsistencia({
    required String fecha,
    required int estudianteId,
    required String estado,
    String? detalle,
    required AsistenciasParams params,
  }) async {
    final existente = await _asistenciaService.obtenerPorEstudianteYBloque(
      estudianteId: estudianteId,
      fecha: fecha,
      materiaCursoId: params.materiaCursoId,
      hora: params.hora,
    );
    if (existente == null) return;

    final actualizado = AsistenciaModel(
      id: existente.id,
      fecha: existente.fecha,
      estudianteId: existente.estudianteId,
      materiaCursoId: existente.materiaCursoId,
      hora: existente.hora,
      estado: estado,
      detalle: detalle ?? existente.detalle,
      fechaJustificacion: existente.fechaJustificacion,
      fotoJustificacion: existente.fotoJustificacion,
      detalleJustificacion: existente.detalleJustificacion,
    );

    await _asistenciaService.actualizar(asistencia: actualizado);

    // 🔄 Actualizar el estado local sin depender de invalidate
    final nuevas = await _asistenciaService.obtenerPorBloque(
      fecha: fecha,
      materiaCursoId: params.materiaCursoId,
      hora: params.hora,
    );

    ref.read(asistenciaTriggerProvider.notifier).state++;
    state = AsyncValue.data(nuevas);
  }

  /// 🧾 Justifica una asistencia con trazabilidad
  Future<void> justificarAsistencia({
    required int estudianteId,
    required String fecha,
    required String foto,
    required String detalleJustificacion,
    required AsistenciasParams params,
  }) async {
    final existente = await _asistenciaService.obtenerPorEstudianteYBloque(
      estudianteId: estudianteId,
      fecha: fecha,
      materiaCursoId: params.materiaCursoId,
      hora: params.hora,
    );
    if (existente == null) return;

    await _asistenciaService.justificar(
      asistenciaId: existente.id!,
      foto: foto,
      detalleJustificacion: detalleJustificacion,
    );

    final nuevas = await _asistenciaService.obtenerPorBloque(
      fecha: fecha,
      materiaCursoId: params.materiaCursoId,
      hora: params.hora,
    );

    ref.read(asistenciaTriggerProvider.notifier).state++;
    state = AsyncValue.data(nuevas);
  }

  /// 📊 Conteo por estado
  int contar(String estado) {
    return state.value?.where((a) => a.estado == estado).length ?? 0;
  }
}
