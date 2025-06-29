import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/curso_model.dart';
import '../services/cursos_service.dart';
import '../providers/database_provider.dart';
import '../providers/periodo_activo_provider.dart';

final cursosControllerProvider =
    AsyncNotifierProvider<CursosController, List<Curso>>(CursosController.new);

class CursosController extends AsyncNotifier<List<Curso>> {
  late final CursosService _service;

  @override
  Future<List<Curso>> build() async {
    final db = await ref.watch(databaseProvider.future);
    final periodo = await ref.watch(periodoActivoProvider.future);

    if (periodo == null) return [];

    _service = CursosService(db);
    return _service.obtenerCursosPorPeriodo(periodo.id);
  }

  Future<void> agregarCursos(List<Curso> nuevos) async {
    state = const AsyncValue.loading();

    try {
      final periodo = await ref.read(periodoActivoProvider.future);
      if (periodo == null) {
        state = AsyncValue.error('No hay período activo', StackTrace.current);
        return;
      }

      for (final curso in nuevos) {
        final existe = await _service.existeCurso(
          curso.nombre,
          curso.paralelo,
          periodo.id,
        );
        if (!existe) {
          await _service.insertarCurso(curso);
        }
      }

      final actualizados = await _service.obtenerCursosPorPeriodo(periodo.id);
      state = AsyncValue.data(actualizados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> archivarCurso(int id) async {
    try {
      final periodo = await ref.read(periodoActivoProvider.future);
      if (periodo == null) {
        state = AsyncValue.error('No hay período activo', StackTrace.current);
        return;
      }

      await _service.archivarCurso(id);
      final actualizados = await _service.obtenerCursosPorPeriodo(periodo.id);
      state = AsyncValue.data(actualizados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> eliminarCurso(int id) async {
    try {
      final tieneDependencias = await _service.cursoTieneDatosRelacionados(id);
      if (tieneDependencias) return false;

      await _service.eliminarCurso(id);

      final periodo = await ref.read(periodoActivoProvider.future);
      if (periodo != null) {
        final actualizados = await _service.obtenerCursosPorPeriodo(periodo.id);
        state = AsyncValue.data(actualizados);
      }

      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
