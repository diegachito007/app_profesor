import 'package:sqflite/sqflite.dart';
import '../models/materia_tipo_model.dart'; // Ajusta la ruta según tu estructura

class MateriasTipoService {
  final Database db;

  MateriasTipoService(this.db);

  Future<void> insertarTipo(MateriaTipo tipo) async {
    await db.insert(
      'tipos_materia',
      tipo.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<MateriaTipo>> obtenerTipos() async {
    final List<Map<String, dynamic>> maps = await db.query('tipos_materia');
    return maps.map((map) => MateriaTipo.fromMap(map)).toList();
  }

  Future<MateriaTipo?> obtenerPorNombre(String nombre) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'tipos_materia',
      where: 'nombre = ?',
      whereArgs: [nombre],
    );
    if (maps.isEmpty) return null;
    return MateriaTipo.fromMap(maps.first);
  }

  Future<MateriaTipo?> obtenerPorId(int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'tipos_materia',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return MateriaTipo.fromMap(maps.first);
  }

  Future<MateriaTipo?> obtenerPorSigla(String sigla) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'tipos_materia',
      where: 'sigla = ?',
      whereArgs: [sigla],
    );
    if (maps.isEmpty) return null;
    return MateriaTipo.fromMap(maps.first);
  }
}
