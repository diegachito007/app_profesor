import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tema_model.dart';
import '../services/temas_service.dart';
import '../providers/database_provider.dart';
import '../providers/triggers/temas_trigger_provider.dart';

final temasControllerProvider =
    AsyncNotifierProvider<TemasController, List<Tema>>(TemasController.new);

class TemasController extends AsyncNotifier<List<Tema>> {
  late TemasService _service;

  @override
  Future<List<Tema>> build() async {
    ref.watch(temasTriggerProvider); // 🔁 reactivo

    final db = await ref.watch(databaseProvider.future);
    _service = TemasService(db);
    return _service.obtenerTodos();
  }

  Future<void> agregarTema(Tema tema) async {
    await _service.agregar(tema);
    ref.read(temasTriggerProvider.notifier).state++; // 🔁 notifica cambio
    state = await AsyncValue.guard(() => _service.obtenerTodos());
  }

  Future<void> actualizarTema(Tema tema) async {
    await _service.actualizar(tema);
    ref.read(temasTriggerProvider.notifier).state++;
    state = await AsyncValue.guard(() => _service.obtenerTodos());
  }

  Future<bool> eliminarTema(int id) async {
    final exito = await _service.eliminar(id);
    if (exito) {
      ref.read(temasTriggerProvider.notifier).state++;
      state = await AsyncValue.guard(() => _service.obtenerTodos());
    }
    return exito;
  }

  Future<bool> existeNombreTema(String nombre) async {
    final temas = state.value ?? [];
    return temas.any((t) => t.nombre.toLowerCase() == nombre.toLowerCase());
  }
}
