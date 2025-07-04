import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/materia_curso_model.dart';
import '../services/materias_curso_service.dart';
import '../providers/database_provider.dart';

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
    final db = await ref.watch(databaseProvider.future);
    _service = MateriasCursoService(db);
    return _service!.obtenerPorCurso(cursoId);
  }

  Future<void> asignar(int cursoId, int materiaId) async {
    await _service!.asignarMateria(cursoId, materiaId);
    state = await AsyncValue.guard(() => _service!.obtenerPorCurso(cursoId));
  }

  Future<void> desactivar(int id, int cursoId) async {
    await _service!.desactivarMateria(id);
    state = await AsyncValue.guard(() => _service!.obtenerPorCurso(cursoId));
  }

  Future<void> eliminar(int id, int cursoId) async {
    await _service!.eliminarMateriaCurso(id);
    state = await AsyncValue.guard(() => _service!.obtenerPorCurso(cursoId));
  }

  Future<void> restaurar(int id, int cursoId) async {
    await _service!.restaurarMateria(id);
    state = await AsyncValue.guard(() => _service!.obtenerPorCurso(cursoId));
  }
}
