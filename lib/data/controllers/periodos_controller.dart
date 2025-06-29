import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../models/periodo_model.dart';
import '../services/periodos_service.dart';
import '../providers/database_provider.dart';

final periodosControllerProvider =
    AsyncNotifierProvider<PeriodosController, List<Periodo>>(
      PeriodosController.new,
    );

class PeriodosController extends AsyncNotifier<List<Periodo>> {
  late final PeriodosService _service;
  List<Periodo> _periodos = [];

  @override
  Future<List<Periodo>> build() async {
    final db = await ref.watch(databaseProvider.future);
    _service = PeriodosService(db);
    _periodos = await _service.obtenerTodos();
    return _periodos;
  }

  Future<void> cargarPeriodos() async {
    _periodos = await _service.obtenerTodos();
    state = AsyncValue.data(_periodos);
  }

  Future<void> agregarPeriodo(
    String nombre,
    DateTime inicio,
    DateTime fin,
  ) async {
    final nuevo = Periodo(
      id: 0,
      nombre: nombre,
      inicio: inicio,
      fin: fin,
      activo: false,
    );
    await _service.insertar(nuevo);
    await cargarPeriodos();
  }

  Future<void> actualizarPeriodo(
    int id,
    String nombre,
    DateTime inicio,
    DateTime fin,
  ) async {
    final actualizado = Periodo(
      id: id,
      nombre: nombre,
      inicio: inicio,
      fin: fin,
      activo: false,
    );
    await _service.actualizar(actualizado);
    await cargarPeriodos();
  }

  Future<void> eliminarPeriodo(int id) async {
    await _service.eliminar(id);
    await cargarPeriodos();
  }

  Future<void> activarPeriodo(int id) async {
    await _service.desactivarTodos();
    await _service.activar(id);
    await cargarPeriodos();
  }

  Future<bool> existeNombrePeriodo(String nombre) {
    return _service.existeNombre(nombre);
  }

  Periodo? get periodoActivo => _periodos.firstWhereOrNull((p) => p.activo);
}
