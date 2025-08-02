import 'package:sqflite/sqflite.dart';
import '../models/jornada_model.dart';

class JornadasService {
  final Database db;

  JornadasService(this.db);

  /// ➕ Inserta una jornada nueva
  Future<void> insertar({
    required String fecha,
    required int materiaCursoId,
    required int hora,
    String estado = 'activa',
    String? detalle,
  }) async {
    final jornada = JornadaModel(
      fecha: fecha,
      materiaCursoId: materiaCursoId,
      hora: hora,
      estado: estado,
      detalle: detalle,
      creadoEn: DateTime.now().toIso8601String(),
    );

    await db.insert(
      'jornadas',
      jornada.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// 🔍 Obtiene todas las jornadas de un materiaCursoId
  Future<List<JornadaModel>> obtenerPorMateriaCurso(int materiaCursoId) async {
    final result = await db.query(
      'jornadas',
      where: 'materia_curso_id = ?',
      whereArgs: [materiaCursoId],
      orderBy: 'fecha DESC, hora ASC',
    );
    return result.map(JornadaModel.fromMap).toList();
  }

  /// 🔍 Obtiene una jornada específica por ID
  Future<JornadaModel?> obtenerPorId(int jornadaId) async {
    final result = await db.query(
      'jornadas',
      where: 'id = ?',
      whereArgs: [jornadaId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return JornadaModel.fromMap(result.first);
  }

  /// 📝 Suspende una jornada con detalle contextual
  Future<void> suspender({
    required int jornadaId,
    required String motivo,
  }) async {
    await db.update(
      'jornadas',
      {'estado': 'suspendida', 'detalle': motivo},
      where: 'id = ?',
      whereArgs: [jornadaId],
    );
  }

  /// ✅ Reactiva una jornada
  Future<void> activar(int jornadaId) async {
    await db.update(
      'jornadas',
      {'estado': 'activa', 'detalle': null},
      where: 'id = ?',
      whereArgs: [jornadaId],
    );
  }

  /// 🧾 Actualiza jornada completa
  Future<void> actualizar({required JornadaModel jornada}) async {
    await db.update(
      'jornadas',
      jornada.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [jornada.id],
    );
  }

  /// 🗑️ Elimina una jornada
  Future<void> eliminar(int jornadaId) async {
    await db.delete('jornadas', where: 'id = ?', whereArgs: [jornadaId]);
  }

  Future<JornadaModel?> obtenerPorBloque({
    required String fecha,
    required int materiaCursoId,
    required int hora,
  }) async {
    final result = await db.query(
      'jornadas',
      where: 'fecha = ? AND materia_curso_id = ? AND hora = ?',
      whereArgs: [fecha, materiaCursoId, hora],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return JornadaModel.fromMap(result.first);
  }

  /// 🔄 Reactiva una jornada suspendida si no tiene asistencias registradas
  Future<bool> reactivarSiEsPosible({
    required int materiaCursoId,
    required String fecha,
    required int hora,
  }) async {
    final jornada = await db.query(
      'jornadas',
      where: 'materia_curso_id = ? AND fecha = ? AND hora = ?',
      whereArgs: [materiaCursoId, fecha, hora],
      limit: 1,
    );

    if (jornada.isEmpty || jornada.first['estado'] != 'suspendida') {
      return false;
    }

    final asistencias = await db.query(
      'asistencias',
      where: 'materia_curso_id = ? AND fecha = ? AND hora = ?',
      whereArgs: [materiaCursoId, fecha, hora],
    );

    if (asistencias.isNotEmpty) return false;

    await db.update(
      'jornadas',
      {'estado': 'activa', 'detalle': 'Reactivada tras llegada tardía'},
      where: 'materia_curso_id = ? AND fecha = ? AND hora = ?',
      whereArgs: [materiaCursoId, fecha, hora],
    );

    return true;
  }
}
