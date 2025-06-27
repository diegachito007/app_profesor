import '../models/periodo_model.dart';
import '../services/periodos_service.dart';

class PeriodosController {
  final PeriodosService _service = PeriodosService();

  Future<List<Periodo>> cargarPeriodos() => _service.obtenerTodos();

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
      activo: false, // El servicio no modifica el campo activo
    );
    await _service.actualizar(actualizado);
  }

  Future<void> eliminarPeriodo(int id) => _service.eliminar(id);

  Future<void> activarPeriodo(int id) => _service.activar(id);

  Future<bool> existeNombrePeriodo(String nombre) =>
      _service.existeNombre(nombre);
}
