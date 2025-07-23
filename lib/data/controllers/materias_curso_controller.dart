import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/materia_curso_model.dart';
import '../services/materias_curso_service.dart';
import '../providers/database_provider.dart';
import '../providers/materias_curso_trigger_provider.dart';
import '../providers/materias_curso_global_provider.dart';
import '../services/horarios_service.dart';

final materiasCursoControllerProvider =
    AsyncNotifierProviderFamily<
      MateriasCursoController,
      List<MateriaCurso>,
      int
    >(MateriasCursoController.new);

class MateriasCursoController
    extends FamilyAsyncNotifier<List<MateriaCurso>, int> {
  MateriasCursoService? _service;

  @override
  Future<List<MateriaCurso>> build(int cursoId) async {
    ref.watch(materiasCursoTriggerProvider(cursoId)); // 🔁 reactivo por curso

    final db = await ref.watch(databaseProvider.future);
    _service = MateriasCursoService(db);
    return _service!.obtenerPorCurso(cursoId);
  }

  Future<void> asignar(int cursoId, int materiaId) async {
    await _service!.asignarMateria(cursoId, materiaId);

    state = await AsyncValue.guard(() => _service!.obtenerPorCurso(cursoId));
    ref.read(materiasCursoTriggerProvider(cursoId).notifier).state++;

    // 🔄 Refrescar estado global para sincronizar horario
    await ref.read(materiasCursoGlobalProvider.notifier).recargar();
  }

  Future<void> eliminar(int id, int cursoId) async {
    await _service!.eliminarMateriaCurso(id);
    state = await AsyncValue.guard(() => _service!.obtenerPorCurso(cursoId));
    ref.read(materiasCursoTriggerProvider(cursoId).notifier).state++;

    // 🔄 Refrescar estado global para sincronizar horario
    await ref.read(materiasCursoGlobalProvider.notifier).recargar();
  }

  Future<void> restaurar(int id, int cursoId) async {
    await _service!.restaurarMateria(id);
    state = await AsyncValue.guard(() => _service!.obtenerPorCurso(cursoId));
    ref.read(materiasCursoTriggerProvider(cursoId).notifier).state++;

    // 🔄 Refrescar estado global para sincronizar horario
    await ref.read(materiasCursoGlobalProvider.notifier).recargar();
  }

  Future<void> desactivar(int id, int cursoId) async {
    await _service!.desactivarMateria(id);
    state = await AsyncValue.guard(() => _service!.obtenerPorCurso(cursoId));
    ref.read(materiasCursoTriggerProvider(cursoId).notifier).state++;

    // 🔄 Refrescar estado global para sincronizar horario
    await ref.read(materiasCursoGlobalProvider.notifier).recargar();
  }

  Future<void> archivarMateria(int materiaId, int cursoId) async {
    final db = await ref.read(databaseProvider.future);
    final materiasCursoService = MateriasCursoService(db);
    final horariosService = HorariosService(db);

    await materiasCursoService.archivarMateria(materiaId);
    await horariosService.limpiarBloquesHuerfanos();

    state = await AsyncValue.guard(
      () => materiasCursoService.obtenerPorCurso(cursoId),
    );
    ref.read(materiasCursoTriggerProvider(cursoId).notifier).state++;
    await ref.read(materiasCursoGlobalProvider.notifier).recargar();
  }
}
