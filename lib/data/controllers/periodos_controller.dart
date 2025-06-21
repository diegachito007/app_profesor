import '../services/periodos_service.dart';
import '../models/periodo_model.dart';

class PeriodosController {
  Future<List<Periodo>> cargarPeriodos() async {
    return await PeriodosService.obtenerPeriodos();
  }

  Future<void> agregarPeriodo(
    String nombre,
    DateTime inicio,
    DateTime fin,
  ) async {
    await PeriodosService.agregarPeriodo(nombre, inicio, fin);
  }

  Future<void> actualizarPeriodo(
    int id,
    String nombre,
    DateTime inicio,
    DateTime fin,
  ) async {
    await PeriodosService.actualizarPeriodo(id, nombre, inicio, fin);
  }

  Future<void> eliminarPeriodo(int id) async {
    await PeriodosService.eliminarPeriodo(id);
  }

  Future<void> activarPeriodo(int id) async {
    await PeriodosService.desactivarTodos();
    await PeriodosService.activarPeriodo(id);
  }
}
