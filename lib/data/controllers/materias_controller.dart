import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/materia_model.dart';
import '../services/materias_service.dart';
import '../providers/database_provider.dart';
import '../providers/materias_trigger_provider.dart'; // ⬅️ Asegúrate de tener este archivo
import '../services/materias_curso_service.dart';

final materiasControllerProvider =
    AsyncNotifierProvider<MateriasController, List<Materia>>(
      MateriasController.new,
    );

class MateriasController extends AsyncNotifier<List<Materia>> {
  late MateriasService _service; // ⬅️ Ya no es final

  @override
  Future<List<Materia>> build() async {
    ref.watch(materiasTriggerProvider); // 🔁 reactivo

    final db = await ref.watch(databaseProvider.future);
    _service = MateriasService(db);
    return _service.obtenerTodas();
  }

  Future<void> agregarMateria(Materia materia) async {
    await _service.agregar(materia);
    ref.read(materiasTriggerProvider.notifier).state++; // 🔁 notifica cambio
    state = await AsyncValue.guard(() => _service.obtenerTodas());
  }

  Future<bool> eliminarMateria(int id) async {
    final exito = await _service.eliminar(id);
    if (exito) {
      final db = await ref.watch(databaseProvider.future);
      final materiasCursoService = MateriasCursoService(db);

      // 🔥 Elimina todas las asignaciones de esta materia
      await materiasCursoService.eliminarAsignacionesPorMateriaId(id);

      // 🔁 Notifica que el catálogo ha cambiado
      ref.read(materiasTriggerProvider.notifier).state++;

      // ⏱️ Opcional: reconstruye todos los tabs de cursos si usas triggers por curso
      // ref.read(materiasCursoTriggerProvider(0).notifier).state++;

      // 🔁 Recarga el catálogo completo
      state = await AsyncValue.guard(() => _service.obtenerTodas());
    }
    return exito;
  }

  Future<void> actualizarMateria(Materia materia) async {
    await _service.actualizar(materia);
    ref.read(materiasTriggerProvider.notifier).state++; // 🔁 notifica cambio
    state = await AsyncValue.guard(() => _service.obtenerTodas());
  }

  Future<void> cargarPorTipo(int tipoId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _service.obtenerPorTipoId(tipoId);
    });
  }

  Future<bool> existeNombreMateria(String nombre) async {
    final materias = state.value ?? [];
    return materias.any((m) => m.nombre.toLowerCase() == nombre.toLowerCase());
  }
}
