import 'package:sqflite/sqflite.dart';
import '../models/materia_model.dart';

class MateriasService {
  final Database db;

  MateriasService(this.db);

  Future<List<Materia>> obtenerTodas() async {
    final result = await db.query('materias', orderBy: 'nombre ASC');
    return result.map((e) => Materia.fromMap(e)).toList();
  }

  Future<List<Materia>> obtenerPorTipoId(int tipoId) async {
    final result = await db.query(
      'materias',
      where: 'tipo_id = ?',
      whereArgs: [tipoId],
      orderBy: 'nombre ASC',
    );
    return result.map((e) => Materia.fromMap(e)).toList();
  }

  Future<void> agregar(Materia materia) async {
    await db.insert(
      'materias',
      materia.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> actualizar(Materia materia) async {
    await db.update(
      'materias',
      materia.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [materia.id],
    );
  }

  Future<bool> eliminar(int id) async {
    try {
      final count = await db.delete(
        'materias',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Future<Materia?> obtenerPorId(int id) async {
    final result = await db.query('materias', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Materia.fromMap(result.first);
    }
    return null;
  }
}
