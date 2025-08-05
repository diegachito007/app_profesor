import 'package:sqflite/sqflite.dart';
import '../models/nota_tipo_model.dart';

class NotasTipoService {
  final Database db;

  NotasTipoService(this.db);

  /// 🔍 Obtiene todos los tipos de nota activos
  Future<List<NotaTipoModel>> obtenerActivos() async {
    final result = await db.query(
      'notas_tipo',
      where: 'activo = 1',
      orderBy: 'nombre ASC',
    );
    return result.map(NotaTipoModel.fromMap).toList();
  }

  /// 🔍 Obtiene un tipo de nota por ID
  Future<NotaTipoModel?> obtenerPorId(int id) async {
    final result = await db.query(
      'notas_tipo',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return NotaTipoModel.fromMap(result.first);
  }

  /// ➕ Inserta un nuevo tipo de nota
  Future<void> insertar({
    required String nombre,
    required String prefijo,
  }) async {
    final tipo = NotaTipoModel(
      nombre: nombre,
      prefijo: prefijo,
      activo: true,
      createdAt: DateTime.now().toIso8601String(),
    );

    await db.insert(
      'notas_tipo',
      tipo.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// ✏️ Actualiza un tipo de nota existente
  Future<void> actualizar(NotaTipoModel tipo) async {
    await db.update(
      'notas_tipo',
      tipo.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [tipo.id],
    );
  }

  /// 🚫 Desactiva un tipo de nota (sin eliminar)
  Future<void> desactivar(int id) async {
    await db.update(
      'notas_tipo',
      {'activo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
