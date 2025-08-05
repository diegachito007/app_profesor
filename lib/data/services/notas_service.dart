import 'package:sqflite/sqflite.dart';
import '../models/nota_model.dart';

class NotasService {
  final Database db;

  NotasService(this.db);

  /// 🔍 Obtiene todas las notas de un bloque específico
  Future<List<NotaModel>> obtenerPorBloque({
    required String fecha,
    required int materiaCursoId,
    required int temaId,
  }) async {
    final result = await db.query(
      'notas',
      where: 'fecha = ? AND materia_curso_id = ? AND tema_id = ?',
      whereArgs: [fecha, materiaCursoId, temaId],
    );
    return result.map(NotaModel.fromMap).toList();
  }

  /// 🔍 Obtiene la nota de un estudiante en un bloque específico
  Future<NotaModel?> obtenerPorEstudianteYBloque({
    required int estudianteId,
    required String fecha,
    required int materiaCursoId,
    required int temaId,
  }) async {
    final result = await db.query(
      'notas',
      where:
          'estudiante_id = ? AND fecha = ? AND materia_curso_id = ? AND tema_id = ?',
      whereArgs: [estudianteId, fecha, materiaCursoId, temaId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return NotaModel.fromMap(result.first);
  }

  /// ➕ Inserta una nota básica
  Future<void> insertar({
    required int estudianteId,
    required String fecha,
    required int materiaCursoId,
    required int temaId,
    required double valor,
  }) async {
    final nota = NotaModel(
      estudianteId: estudianteId,
      materiaCursoId: materiaCursoId,
      fecha: fecha,
      temaId: temaId,
      notaTipoId: 0, // ← valor temporal si aplica
      valor: valor,
    );

    await db.insert(
      'notas',
      nota.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// ✏️ Actualiza una nota existente
  Future<void> actualizar({required NotaModel nota}) async {
    await db.update(
      'notas',
      nota.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [nota.id],
    );
  }

  /// 🧠 Guarda una nota con trazabilidad completa
  Future<void> guardarNota({
    required int estudianteId,
    required int materiaCursoId,
    required int notaTipoId, // ← actualizado
    required int hora,
    required String fecha,
    required String tema,
    required double notaFinal,
    required String codigoNotaTema,
  }) async {
    final notaMap = {
      'estudiante_id': estudianteId,
      'materia_curso_id': materiaCursoId,
      'nota_tipo_id': notaTipoId, // ← actualizado
      'hora': hora,
      'fecha': fecha,
      'tema': tema,
      'nota_final': notaFinal,
      'codigo_nota_tema': codigoNotaTema,
      'created_at': DateTime.now().toIso8601String(),
    };

    await db.insert(
      'notas',
      notaMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
