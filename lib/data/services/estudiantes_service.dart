import 'package:sqflite/sqflite.dart';
import '../models/estudiante_model.dart';

class EstudiantesService {
  final Database db;

  EstudiantesService(this.db);

  /// 🔍 Obtiene todos los estudiantes de un curso específico
  Future<List<Estudiante>> obtenerPorCurso(int cursoId) async {
    final result = await db.query(
      'estudiantes',
      where: 'curso_id = ?',
      whereArgs: [cursoId],
      orderBy: 'apellido, nombre',
    );
    return result.map((e) => Estudiante.fromMap(e)).toList();
  }

  /// ➕ Inserta un nuevo estudiante
  Future<void> insertarEstudiante(Estudiante estudiante) async {
    await db.insert('estudiantes', estudiante.toDatabaseMap());
  }

  /// ✏️ Actualiza un estudiante existente
  Future<void> actualizarEstudiante(Estudiante estudiante) async {
    await db.update(
      'estudiantes',
      estudiante.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [estudiante.id],
    );
  }

  /// 🗑️ Elimina un estudiante por ID
  Future<void> eliminarEstudiante(int id) async {
    await db.delete('estudiantes', where: 'id = ?', whereArgs: [id]);
  }

  /// 🔢 Cuenta cuántos estudiantes hay en un curso
  Future<int> contarPorCurso(int cursoId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM estudiantes WHERE curso_id = ?',
      [cursoId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// ✅ Verifica si ya existe un estudiante con la misma cédula
  Future<bool> existeCedula(String cedula) async {
    final result = await db.query(
      'estudiantes',
      where: 'cedula = ?',
      whereArgs: [cedula],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// 📦 Inserta múltiples estudiantes (ideal para importación desde Excel)
  Future<void> insertarLote(List<Estudiante> estudiantes) async {
    final batch = db.batch();
    for (final estudiante in estudiantes) {
      batch.insert('estudiantes', estudiante.toDatabaseMap());
    }
    await batch.commit(noResult: true);
  }
}
