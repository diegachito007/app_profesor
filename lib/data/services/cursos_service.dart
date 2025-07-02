import 'package:sqflite/sqflite.dart';
import '../models/curso_model.dart';

class CursosService {
  final Database db;

  CursosService(this.db);

  Future<List<Curso>> obtenerCursosPorPeriodo(int periodoId) async {
    final result = await db.query(
      'cursos',
      where: 'periodo_id = ?',
      whereArgs: [periodoId],
      orderBy: 'nombre, paralelo',
    );
    return result.map((e) => Curso.fromMap(e)).toList();
  }

  Future<void> insertarCurso(Curso curso) async {
    await db.insert('cursos', curso.toDatabaseMap());
  }

  Future<void> actualizarCurso(Curso curso) async {
    await db.update(
      'cursos',
      curso.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [curso.id],
    );
  }

  Future<void> eliminarCurso(int cursoId) async {
    await db.delete('cursos', where: 'id = ?', whereArgs: [cursoId]);
  }

  /// ✅ Alterna el estado de activo entre 1 y 0
  Future<void> archivarCurso(int id) async {
    await db.rawUpdate(
      '''
      UPDATE cursos
      SET activo = CASE WHEN activo = 1 THEN 0 ELSE 1 END
      WHERE id = ?
    ''',
      [id],
    );
  }

  Future<bool> existeCurso(
    String nombre,
    String paralelo,
    int periodoId,
  ) async {
    final result = await db.query(
      'cursos',
      where: 'nombre = ? AND paralelo = ? AND periodo_id = ?',
      whereArgs: [nombre, paralelo, periodoId],
    );
    return result.isNotEmpty;
  }

  Future<bool> cursoTieneDatosRelacionados(int cursoId) async {
    final materiasRelacionadas = await db.rawQuery(
      'SELECT 1 FROM materias_curso WHERE curso_id = ? LIMIT 1',
      [cursoId],
    );

    final estudiantesRelacionados = await db.rawQuery(
      'SELECT 1 FROM estudiantes WHERE curso_id = ? LIMIT 1',
      [cursoId],
    );

    return materiasRelacionadas.isNotEmpty ||
        estudiantesRelacionados.isNotEmpty;
  }
}
