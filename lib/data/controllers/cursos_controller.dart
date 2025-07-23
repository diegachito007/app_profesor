import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/curso_model.dart';
import '../services/cursos_service.dart';
import '../services/materias_curso_service.dart';
import '../services/horarios_service.dart';
import '../providers/database_provider.dart';
import '../providers/periodo_activo_provider.dart';
import '../providers/materias_curso_global_provider.dart';
import '../providers/materias_curso_trigger_provider.dart';
import '../controllers/materias_curso_controller.dart';

final cursosControllerProvider =
    AsyncNotifierProvider<CursosController, List<Curso>>(CursosController.new);

class CursosController extends AsyncNotifier<List<Curso>> {
  CursosService? _service;

  @override
  Future<List<Curso>> build() async {
    final periodo = ref.watch(periodoActivoProvider);
    if (periodo == null) return [];

    final db = await ref.watch(databaseProvider.future);
    _service = CursosService(db);

    await ref.read(materiasCursoGlobalProvider.notifier).recargar();

    return _service!.obtenerCursosPorPeriodo(periodo.id);
  }

  Future<CursosService> _ensureService() async {
    if (_service != null) return _service!;
    final db = await ref.read(databaseProvider.future);
    _service = CursosService(db);
    return _service!;
  }

  Future<List<Curso>> obtenerCursosPorPeriodo(int periodoId) async {
    final service = await _ensureService();
    return service.obtenerCursosPorPeriodo(periodoId);
  }

  Future<void> agregarCursos(List<Curso> nuevos) async {
    state = const AsyncLoading();

    try {
      final periodo = ref.read(periodoActivoProvider);
      if (periodo == null) {
        state = AsyncError('No hay período activo', StackTrace.current);
        return;
      }

      final service = await _ensureService();

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
      state = AsyncData(actualizados);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> archivarCurso(int id) async {
    try {
      final periodo = ref.read(periodoActivoProvider);
      if (periodo == null) {
        state = AsyncError('No hay período activo', StackTrace.current);
        return;
      }

      final db = await ref.read(databaseProvider.future);
      final service = await _ensureService();
      final materiasCursoService = MateriasCursoService(db);
      final horariosService = HorariosService(db);

      await service.archivarCurso(id);
      await materiasCursoService.archivarTodasPorCurso(id);
      await horariosService.limpiarBloquesHuerfanos();
      await ref.read(materiasCursoGlobalProvider.notifier).recargar();

      final actualizados = await service.obtenerCursosPorPeriodo(periodo.id);
      state = AsyncData(actualizados);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> restaurarCurso(int id) async {
    try {
      final periodo = ref.read(periodoActivoProvider);
      if (periodo == null) {
        state = AsyncError('No hay período activo', StackTrace.current);
        return;
      }

      final service = await _ensureService();

      await service.restaurarCurso(id);

      // 🔄 Forzar reconstrucción del controller de materias
      ref.invalidate(materiasCursoControllerProvider(id));

      // 🔁 Activar trigger reactivo para vistas ya montadas
      ref.read(materiasCursoTriggerProvider(id).notifier).state++;

      // 🔄 Refrescar estado global para sincronizar horario
      await ref.read(materiasCursoGlobalProvider.notifier).recargar();

      final actualizados = await service.obtenerCursosPorPeriodo(periodo.id);
      state = AsyncData(actualizados);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> eliminarCurso(int id) async {
    try {
      final service = await _ensureService();

      final tieneDependencias = await service.cursoTieneDatosRelacionados(id);
      if (tieneDependencias) return false;

      await service.eliminarCurso(id);

      final periodo = ref.read(periodoActivoProvider);
      if (periodo != null) {
        final actualizados = await service.obtenerCursosPorPeriodo(periodo.id);
        state = AsyncData(actualizados);
      }

      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
