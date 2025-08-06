import 'package:sqflite/sqflite.dart';
import '../models/tema_model.dart';

class TemasService {
  final Database db;

  TemasService(this.db);

  Future<List<Tema>> obtenerTodos() async {
    final result = await db.query('temas', orderBy: 'nombre ASC');
    return result.map((e) => Tema.fromMap(e)).toList();
  }

  Future<void> agregar(Tema tema) async {
    await db.insert(
      'temas',
      tema.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> actualizar(Tema tema) async {
    await db.update(
      'temas',
      tema.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [tema.id],
    );
  }

  Future<bool> eliminar(int id) async {
    try {
      final count = await db.delete('temas', where: 'id = ?', whereArgs: [id]);
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> existeNombre(String nombre) async {
    final result = await db.query(
      'temas',
      where: 'LOWER(nombre) = ?',
      whereArgs: [nombre.toLowerCase()],
    );
    return result.isNotEmpty;
  }

  Future<Tema?> obtenerPorId(int id) async {
    final result = await db.query('temas', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Tema.fromMap(result.first);
    }
    return null;
  }

  /// 🔧 Nuevo método: obtiene el ID del tema, insertando si no existe
  Future<int> obtenerTemaId(String nombre) async {
    final nombreNormalizado = nombre.trim().toLowerCase();

    final resultado = await db.query(
      'temas',
      where: 'LOWER(nombre) = ?',
      whereArgs: [nombreNormalizado],
      limit: 1,
    );

    if (resultado.isNotEmpty) {
      return resultado.first['id'] as int;
    }

    return await db.insert('temas', {'nombre': nombreNormalizado});
  }
}
