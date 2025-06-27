import 'package:sqflite/sqflite.dart';
import '../models/periodo_model.dart';
import '../database/sqlite_service.dart';

class PeriodosService {
  Future<Database> get _db async => await SQLiteService.db;

  Future<List<Periodo>> obtenerTodos() async {
    final db = await _db;
    final result = await db.query('periodos', orderBy: 'fecha_inicio DESC');
    return result.map((e) => Periodo.fromMap(e)).toList();
  }

  Future<void> insertar(Periodo periodo) async {
    final db = await _db;
    try {
      await db.insert('periodos', periodo.toDatabaseMap());
    } catch (e) {
      throw Exception("Error al insertar período: $e");
    }
  }

  Future<void> actualizar(Periodo periodo) async {
    final db = await _db;
    try {
      await db.update(
        'periodos',
        periodo.toDatabaseMap(),
        where: 'id = ?',
        whereArgs: [periodo.id],
      );
    } catch (e) {
      throw Exception("Error al actualizar período: $e");
    }
  }

  Future<void> eliminar(int id) async {
    final db = await _db;
    try {
      await db.delete('periodos', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception("Error al eliminar período: $e");
    }
  }

  Future<void> activar(int id) async {
    final db = await _db;
    try {
      await db.transaction((txn) async {
        await txn.update('periodos', {'activo': 0});
        await txn.update(
          'periodos',
          {'activo': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      throw Exception("Error al activar período: $e");
    }
  }

  Future<bool> existeNombre(String nombre) async {
    final db = await _db;
    final result = await db.query(
      'periodos',
      where: 'nombre = ?',
      whereArgs: [nombre],
    );
    return result.isNotEmpty;
  }
}
