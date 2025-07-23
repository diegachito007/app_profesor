import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/materia_curso_model.dart';
import '../services/materias_curso_service.dart';
import 'database_provider.dart';

final materiasCursoGlobalProvider =
    AsyncNotifierProvider<MateriasCursoGlobalNotifier, List<MateriaCurso>>(
      () => MateriasCursoGlobalNotifier(),
    );

class MateriasCursoGlobalNotifier extends AsyncNotifier<List<MateriaCurso>> {
  MateriasCursoService? _service;

  @override
  Future<List<MateriaCurso>> build() async {
    final db = await ref.watch(databaseProvider.future);
    _service = MateriasCursoService(db);
    return await _service!.obtenerTodasActivas();
  }

  Future<void> recargar() async {
    try {
      state = const AsyncLoading();

      if (_service == null) {
        final db = await ref.read(databaseProvider.future);
        _service = MateriasCursoService(db);
      }

      final materias = await _service!.obtenerTodasActivas();
      state = AsyncData(materias);
    } catch (e) {
      state = const AsyncData([]); // ✅ tolera base vacía sin lanzar error
    }
  }
}
