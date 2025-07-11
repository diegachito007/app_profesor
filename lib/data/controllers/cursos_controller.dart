import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/curso_model.dart';
import '../services/cursos_service.dart';
import '../providers/database_provider.dart';
import '../providers/periodo_activo_provider.dart';

final cursosControllerProvider =
    AsyncNotifierProvider<CursosController, List<Curso>>(CursosController.new);

class CursosController extends AsyncNotifier<List<Curso>> {
  @override
  Future<List<Curso>> build() async {
    final periodo = ref.watch(periodoActivoProvider);
    if (periodo == null) return [];

    final db = await ref.watch(databaseProvider.future);
    final service = CursosService(db);
    return service.obtenerCursosPorPeriodo(periodo.id);
  }

  Future<List<Curso>> obtenerCursosPorPeriodo(int periodoId) async {
    final db = await ref.read(databaseProvider.future);
    final service = CursosService(db);
    return service.obtenerCursosPorPeriodo(periodoId);
  }

  Future<void> agregarCursos(List<Curso> nuevos) async {
    state = const AsyncValue.loading();

    try {
      final periodo = ref.read(periodoActivoProvider);
      if (periodo == null) {
        state = AsyncValue.error('No hay período activo', StackTrace.current);
        return;
      }

      final db = await ref.read(databaseProvider.future);
      final service = CursosService(db);

      for (final curso in nuevos) {
        final existe = await service.existeCurso(
          curso.nombre,
          curso.paralelo,
          periodo.id,
        );
        if (!existe) {
          await service.insertarCurso(curso);
        }
      }

      final actualizados = await service.obtenerCursosPorPeriodo(periodo.id);
      state = AsyncValue.data(actualizados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> archivarCurso(int id) async {
    try {
      final periodo = ref.read(periodoActivoProvider);
      if (periodo == null) {
        state = AsyncValue.error('No hay período activo', StackTrace.current);
        return;
      }

      final db = await ref.read(databaseProvider.future);
      final service = CursosService(db);

      await service.archivarCurso(id);
      final actualizados = await service.obtenerCursosPorPeriodo(periodo.id);
      state = AsyncValue.data(actualizados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> eliminarCurso(int id) async {
    try {
      final db = await ref.read(databaseProvider.future);
      final service = CursosService(db);

      final tieneDependencias = await service.cursoTieneDatosRelacionados(id);
      if (tieneDependencias) return false;

      await service.eliminarCurso(id);

      final periodo = ref.read(periodoActivoProvider);
      if (periodo != null) {
        final actualizados = await service.obtenerCursosPorPeriodo(periodo.id);
        state = AsyncValue.data(actualizados);
      }

      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
