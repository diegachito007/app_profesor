import 'package:sqflite/sqflite.dart';
import '../models/periodo_model.dart';

class PeriodosService {
  final Database db;

  PeriodosService(this.db);

  Future<List<Periodo>> obtenerTodos() async {
    final result = await db.query('periodos', orderBy: 'fecha_inicio DESC');
    return result.map((e) => Periodo.fromMap(e)).toList();
  }

  Future<void> insertar(Periodo periodo) async {
    await db.insert('periodos', periodo.toDatabaseMap());
  }

  Future<void> actualizar(Periodo periodo) async {
    await db.update(
      'periodos',
      periodo.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [periodo.id],
    );
  }

  Future<void> eliminar(int id) async {
    await db.delete('periodos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> activar(int id) async {
    await db.update(
      'periodos',
      {'activo': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> desactivarTodos() async {
    await db.update('periodos', {'activo': 0});
  }

  Future<bool> existeNombre(String nombre) async {
    final result = await db.query(
      'periodos',
      where: 'nombre = ?',
      whereArgs: [nombre],
    );
    return result.isNotEmpty;
  }
}
