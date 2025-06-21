import '../database/sqlite_service.dart';
import '../models/periodo_model.dart';

class PeriodosService {
  static Future<List<Periodo>> obtenerPeriodos() async {
    final db = await SQLiteService.getDatabase();
    final result = await db.query('periodos');
    return result.map((map) => Periodo.fromMap(map)).toList();
  }

  static Future<void> agregarPeriodo(
    String nombre,
    DateTime inicio,
    DateTime fin,
  ) async {
    final db = await SQLiteService.getDatabase();
    await db.insert('periodos', {
      'nombre': nombre,
      'inicio': inicio.toIso8601String(),
      'fin': fin.toIso8601String(),
      'activo': 0,
    });
  }

  static Future<void> actualizarPeriodo(
    int id,
    String nombre,
    DateTime inicio,
    DateTime fin,
  ) async {
    final db = await SQLiteService.getDatabase();
    await db.update(
      'periodos',
      {
        'nombre': nombre,
        'inicio': inicio.toIso8601String(),
        'fin': fin.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> eliminarPeriodo(int id) async {
    final db = await SQLiteService.getDatabase();
    await db.delete('periodos', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> desactivarTodos() async {
    final db = await SQLiteService.getDatabase();
    await db.update('periodos', {'activo': 0});
  }

  static Future<void> activarPeriodo(int id) async {
    final db = await SQLiteService.getDatabase();
    await db.update(
      'periodos',
      {'activo': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
