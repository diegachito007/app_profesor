import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/jornada/asistencias_model.dart';
import '../../services/jornada/asistencias_service.dart';
import '../../services/estudiantes_service.dart';
import '../../providers/database_provider.dart';
import '../../providers/jornada/asistencias_trigger_provider.dart';
import '../../../shared/utils/texto_normalizado.dart';

/// 🔹 Parámetros para inicializar el controlador
class AsistenciasParams {
  final int cursoId;
  final int materiaCursoId;
  final int hora;

  AsistenciasParams({
    required this.cursoId,
    required this.materiaCursoId,
    required this.hora,
  });
}

/// 🔹 Provider reactivo por bloque
final asistenciasControllerProvider =
    AsyncNotifierProviderFamily<
      AsistenciasController,
      List<AsistenciaModel>,
      AsistenciasParams
    >(AsistenciasController.new);

class AsistenciasController
    extends FamilyAsyncNotifier<List<AsistenciaModel>, AsistenciasParams> {
  late AsistenciaService _asistenciaService;
  late EstudiantesService _estudiantesService;

  @override
  Future<List<AsistenciaModel>> build(AsistenciasParams params) async {
    final db = await ref.watch(databaseProvider.future);
    _asistenciaService = AsistenciaService(db);
    _estudiantesService = EstudiantesService(db);

    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    final estudiantes = await _estudiantesService.obtenerPorCurso(
      params.cursoId,
    );

    if (estudiantes.isEmpty) return [];

    final asistenciasExistentes = await _asistenciaService.obtenerPorBloque(
      fecha: hoy,
      materiaCursoId: params.materiaCursoId,
      hora: params.hora,
    );

    if (asistenciasExistentes.isEmpty) {
      for (final est in estudiantes) {
        await _asistenciaService.insertar(
          AsistenciaModel(
            fecha: hoy,
            estudianteId: est.id,
            materiaCursoId: params.materiaCursoId,
            hora: params.hora,
            estado: 'Presente',
            fechaRegistro: DateTime.now().toIso8601String(),
            comentario: capitalizarNombreCompleto(est.nombre, est.apellido),
          ),
        );
      }
    }

    return await _asistenciaService.obtenerPorBloque(
      fecha: hoy,
      materiaCursoId: params.materiaCursoId,
      hora: params.hora,
    );
  }

  Future<void> registrarAsistencia({
    required String fecha,
    required int estudianteId,
    required String estado,
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
      fechaRegistro: existente.fechaRegistro,
      comentario: existente.comentario,
      fotoJustificacion: existente.fotoJustificacion,
    );

    await _asistenciaService.actualizar(actualizado);
    ref.read(asistenciaTriggerProvider.notifier).state++;
    state = await AsyncValue.guard(
      () => _asistenciaService.obtenerPorBloque(
        fecha: fecha,
        materiaCursoId: params.materiaCursoId,
        hora: params.hora,
      ),
    );
  }

  Future<void> justificarAsistencia({
    required int estudianteId,
    required String fecha,
    required String fechaRegistro,
    required String foto,
    String? comentario,
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
      estado: 'Justificado',
      fechaRegistro: fechaRegistro,
      fotoJustificacion: foto,
      comentario: comentario ?? existente.comentario,
    );

    await _asistenciaService.actualizar(actualizado);
    ref.read(asistenciaTriggerProvider.notifier).state++;
    state = await AsyncValue.guard(
      () => _asistenciaService.obtenerPorBloque(
        fecha: fecha,
        materiaCursoId: params.materiaCursoId,
        hora: params.hora,
      ),
    );
  }
}
