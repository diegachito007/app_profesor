import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/materia_model.dart';
import '../services/materias_service.dart';
import '../providers/database_provider.dart';

final materiasControllerProvider =
    AsyncNotifierProvider<MateriasController, List<Materia>>(
      MateriasController.new,
    );

class MateriasController extends AsyncNotifier<List<Materia>> {
  @override
  Future<List<Materia>> build() async {
    final db = await ref.watch(databaseProvider.future);
    final service = MateriasService(db);
    return service.obtenerTodas();
  }

  Future<void> agregarMateria(Materia materia) async {
    state = await AsyncValue.guard(() async {
      final db = await ref.read(databaseProvider.future);
      final service = MateriasService(db);

      await service.agregar(materia);
      return service.obtenerTodas();
    });
  }

  Future<void> eliminarMateria(int id) async {
    state = await AsyncValue.guard(() async {
      final db = await ref.read(databaseProvider.future);
      final service = MateriasService(db);

      await service.eliminar(id);
      return service.obtenerTodas();
    });
  }

  Future<void> actualizarMateria(Materia materia) async {
    state = await AsyncValue.guard(() async {
      final db = await ref.read(databaseProvider.future);
      final service = MateriasService(db);

      await service.actualizar(materia);
      return service.obtenerTodas();
    });
  }

  Future<bool> existeNombreMateria(String nombre) async {
    final materias = state.value ?? [];
    return materias.any((m) => m.nombre.toLowerCase() == nombre.toLowerCase());
  }
}
