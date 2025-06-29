import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../models/periodo_model.dart';
import '../services/periodos_service.dart';
import '../providers/database_provider.dart';

final periodosControllerProvider = FutureProvider<PeriodosController>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  final controller = PeriodosController(PeriodosService(db));
  await controller.cargarPeriodos();
  return controller;
});

class PeriodosController {
  final PeriodosService service;
  List<Periodo> _periodos = [];

  PeriodosController(this.service);

  List<Periodo> get periodos => _periodos;

  Future<void> cargarPeriodos() async {
    _periodos = await service.obtenerTodos();
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
    await service.insertar(nuevo);
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
    await service.actualizar(actualizado);
    await cargarPeriodos();
  }

  Future<void> eliminarPeriodo(int id) async {
    await service.eliminar(id);
    await cargarPeriodos();
  }

  Future<void> activarPeriodo(int id) async {
    await service.desactivarTodos();
    await service.activar(id);
    await cargarPeriodos();
  }

  Future<bool> existeNombrePeriodo(String nombre) =>
      service.existeNombre(nombre);

  Periodo? get periodoActivo => _periodos.firstWhereOrNull((p) => p.activo);
}
