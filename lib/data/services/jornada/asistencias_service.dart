import 'package:sqflite/sqflite.dart';
import '../../models/jornada/asistencias_model.dart';

class AsistenciaService {
  final Database db;

  AsistenciaService(this.db);

  Future<void> insertar(AsistenciaModel asistencia) async {
    await db.insert(
      'asistencias',
      asistencia.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> actualizar(AsistenciaModel asistencia) async {
    await db.update(
      'asistencias',
      asistencia.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [asistencia.id],
    );
  }

  /// 🔍 Obtiene todas las asistencias de un bloque específico
  Future<List<AsistenciaModel>> obtenerPorBloque({
    required String fecha,
    required int materiaCursoId,
    required int hora,
  }) async {
    final result = await db.query(
      'asistencias',
      where: 'fecha = ? AND materia_curso_id = ? AND hora = ?',
      whereArgs: [fecha, materiaCursoId, hora],
    );
    return result.map((e) => AsistenciaModel.fromMap(e)).toList();
  }

  /// 🔍 Obtiene la asistencia de un estudiante en un bloque específico
  Future<AsistenciaModel?> obtenerPorEstudianteYBloque({
    required int estudianteId,
    required String fecha,
    required int materiaCursoId,
    required int hora,
  }) async {
    final result = await db.query(
      'asistencias',
      where:
          'estudiante_id = ? AND fecha = ? AND materia_curso_id = ? AND hora = ?',
      whereArgs: [estudianteId, fecha, materiaCursoId, hora],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return AsistenciaModel.fromMap(result.first);
  }
}
