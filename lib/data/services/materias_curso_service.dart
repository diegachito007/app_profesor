import 'package:sqflite/sqflite.dart';
import '../models/materia_curso_model.dart';

class MateriasCursoService {
  final Database db;

  MateriasCursoService(this.db);

  Future<List<MateriaCurso>> obtenerPorCurso(int cursoId) async {
    final result = await db.query(
      'materias_curso',
      where: 'curso_id = ?',
      whereArgs: [cursoId],
      orderBy: 'fecha_asignacion DESC',
    );
    return result.map((e) => MateriaCurso.fromMap(e)).toList();
  }

  Future<void> asignarMateria(int cursoId, int materiaId) async {
    await db.insert('materias_curso', {
      'curso_id': cursoId,
      'materia_id': materiaId,
      'activo': 1,
      'fecha_asignacion': DateTime.now().toIso8601String(),
    });
  }

  Future<void> desactivarMateria(int id) async {
    await db.update(
      'materias_curso',
      {'activo': 0, 'fecha_desactivacion': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> eliminarMateriaCurso(int id) async {
    await db.delete('materias_curso', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> restaurarMateria(int id) async {
    await db.update(
      'materias_curso',
      {'activo': 1, 'fecha_desactivacion': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
