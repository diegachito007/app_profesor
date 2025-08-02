import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/jornada_model.dart';
import '../services/jornadas_service.dart';
import '../providers/database_provider.dart';

final jornadasControllerProvider =
    AsyncNotifierProvider.family<JornadasController, List<JornadaModel>, int>(
      JornadasController.new,
    );

class JornadasController extends FamilyAsyncNotifier<List<JornadaModel>, int> {
  late final JornadasService _service;

  @override
  Future<List<JornadaModel>> build(int materiaCursoId) async {
    final db = await ref.watch(databaseProvider.future);
    _service = JornadasService(db);
    return _service.obtenerPorMateriaCurso(materiaCursoId);
  }

  Future<void> insertarJornada({
    required String fecha,
    required int materiaCursoId,
    required int hora,
    String estado = 'activa',
    String? detalle,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.insertar(
        fecha: fecha,
        materiaCursoId: materiaCursoId,
        hora: hora,
        estado: estado,
        detalle: detalle,
      );
      final actualizadas = await _service.obtenerPorMateriaCurso(
        materiaCursoId,
      );
      state = AsyncValue.data(actualizadas);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> suspenderJornada({
    required int jornadaId,
    required int materiaCursoId,
    required String motivo,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.suspender(jornadaId: jornadaId, motivo: motivo);
      final actualizadas = await _service.obtenerPorMateriaCurso(
        materiaCursoId,
      );
      state = AsyncValue.data(actualizadas);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> activarJornada({
    required int jornadaId,
    required int materiaCursoId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.activar(jornadaId);
      final actualizadas = await _service.obtenerPorMateriaCurso(
        materiaCursoId,
      );
      state = AsyncValue.data(actualizadas);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> eliminarJornada({
    required int jornadaId,
    required int materiaCursoId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.eliminar(jornadaId);
      final actualizadas = await _service.obtenerPorMateriaCurso(
        materiaCursoId,
      );
      state = AsyncValue.data(actualizadas);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> actualizarJornada(JornadaModel jornada) async {
    state = const AsyncValue.loading();
    try {
      await _service.actualizar(jornada: jornada);
      final actualizadas = await _service.obtenerPorMateriaCurso(
        jornada.materiaCursoId,
      );
      state = AsyncValue.data(actualizadas);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<JornadaModel?> obtenerJornadaPorBloque({
    required String fecha,
    required int materiaCursoId,
    required int hora,
  }) async {
    return _service.obtenerPorBloque(
      fecha: fecha,
      materiaCursoId: materiaCursoId,
      hora: hora,
    );
  }

  Future<bool> intentarReactivacion({
    required int materiaCursoId,
    required String fecha,
    required int hora,
  }) async {
    try {
      final ok = await _service.reactivarSiEsPosible(
        materiaCursoId: materiaCursoId,
        fecha: fecha,
        hora: hora,
      );

      if (ok) {
        final actualizadas = await _service.obtenerPorMateriaCurso(
          materiaCursoId,
        );
        state = AsyncValue.data(actualizadas);
      }

      return ok;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
