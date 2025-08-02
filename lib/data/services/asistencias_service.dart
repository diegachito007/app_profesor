import 'package:sqflite/sqflite.dart';
import '../models/asistencia_model.dart';

class AsistenciasService {
  final Database db;

  AsistenciasService(this.db);

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
    return result.map(AsistenciaModel.fromMap).toList();
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

  /// ➕ Inserta una asistencia nueva sin justificación ni detalle
  Future<void> insertar({
    required int estudianteId,
    required String fecha,
    required int materiaCursoId,
    required int hora,
    String estado = 'presente',
  }) async {
    final asistencia = AsistenciaModel(
      fecha: fecha,
      estudianteId: estudianteId,
      materiaCursoId: materiaCursoId,
      hora: hora,
      estado: estado,
    );

    await db.insert(
      'asistencias',
      asistencia.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// ✏️ Actualiza el estado de una asistencia existente
  Future<void> actualizarEstado({
    required int asistenciaId,
    required String nuevoEstado,
  }) async {
    await db.update(
      'asistencias',
      {'estado': nuevoEstado},
      where: 'id = ?',
      whereArgs: [asistenciaId],
    );
  }

  /// 🧾 Justifica una asistencia con trazabilidad completa
  Future<void> justificar({
    required int asistenciaId,
    required String foto,
    required String detalleJustificacion,
  }) async {
    await db.update(
      'asistencias',
      {
        'estado': 'Justificado',
        'fecha_justificacion': DateTime.now().toIso8601String(),
        'foto_justificacion': foto,
        'detalle_justificacion': detalleJustificacion,
      },
      where: 'id = ?',
      whereArgs: [asistenciaId],
    );
  }

  /// 📝 Actualiza el estado y el detalle contextual
  Future<void> actualizar({required AsistenciaModel asistencia}) async {
    await db.update(
      'asistencias',
      asistencia.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [asistencia.id],
    );
  }
}
