import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/materia_model.dart';
import '../services/materias_service.dart';
import '../providers/database_provider.dart';

final materiasControllerProvider =
    AsyncNotifierProvider<MateriasController, List<Materia>>(
      MateriasController.new,
    );

class MateriasController extends AsyncNotifier<List<Materia>> {
  late final MateriasService _service;

  @override
  Future<List<Materia>> build() async {
    final db = await ref.watch(databaseProvider.future);
    _service = MateriasService(db);
    return _service.obtenerTodas();
  }

  Future<void> agregarMateria(Materia materia) async {
    state = await AsyncValue.guard(() async {
      await _service.agregar(materia);
      return _service.obtenerTodas();
    });
  }

  Future<void> eliminarMateria(int id) async {
    state = await AsyncValue.guard(() async {
      await _service.eliminar(id);
      return _service.obtenerTodas();
    });
  }

  Future<void> actualizarMateria(Materia materia) async {
    state = await AsyncValue.guard(() async {
      await _service.actualizar(materia);
      return _service.obtenerTodas();
    });
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
