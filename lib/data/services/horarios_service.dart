import 'package:sqflite/sqflite.dart';
import '../models/horario_model.dart';
import '../models/horario_expandido.dart';
import '../../data/models/materia_curso_model.dart';

class HorariosService {
  final Database db;

  HorariosService(this.db);

  Future<List<Horario>> obtenerPorDia(String dia) async {
    final result = await db.query(
      'horario_clase',
      where: 'dia = ?',
      whereArgs: [dia],
      orderBy: 'hora ASC',
    );
    return result.map((e) => Horario.fromMap(e)).toList();
  }

  Future<Horario?> obtenerPorDiaYHora(String dia, int hora) async {
    final result = await db.query(
      'horario_clase',
      where: 'dia = ? AND hora = ?',
      whereArgs: [dia, hora],
    );
    if (result.isNotEmpty) {
      return Horario.fromMap(result.first);
    }
    return null;
  }

  Future<void> guardar(Horario horario) async {
    final existente = await obtenerPorDiaYHora(horario.dia, horario.hora);
    if (existente != null) {
      await db.update(
        'horario_clase',
        horario.toDatabaseMap(),
        where: 'id = ?',
        whereArgs: [existente.id],
      );
    } else {
      await db.insert('horario_clase', horario.toDatabaseMap());
    }
  }

  Future<void> eliminar(int id) async {
    await db.delete('horario_clase', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<HorarioExpandido>> obtenerExpandidoPorDia(String dia) async {
    final result = await db.rawQuery(
      '''
      SELECT hc.id, hc.dia, hc.hora, hc.materia_curso_id,
             mc.id AS mc_id, mc.curso_id, mc.materia_id, mc.activo,
             mc.fecha_asignacion, mc.fecha_desactivacion,
             c.nombre || ' ' || c.paralelo AS nombre_curso,
             m.nombre AS nombre_materia
      FROM horario_clase hc
      JOIN materias_curso mc ON hc.materia_curso_id = mc.id
      JOIN cursos c ON mc.curso_id = c.id
      JOIN materias m ON mc.materia_id = m.id
      WHERE hc.dia = ?
      ORDER BY hc.hora ASC
    ''',
      [dia],
    );

    return result.map((row) {
      final horario = Horario(
        id: row['id'] as int,
        dia: row['dia'] as String,
        hora: row['hora'] as int,
        materiaCursoId: row['materia_curso_id'] as int,
      );

      final materiaCurso = MateriaCurso.fromMap({
        'id': row['mc_id'],
        'curso_id': row['curso_id'],
        'materia_id': row['materia_id'],
        'activo': row['activo'],
        'fecha_asignacion': row['fecha_asignacion'],
        'fecha_desactivacion': row['fecha_desactivacion'],
        'nombre_materia': row['nombre_materia'], // ✅ necesario
        'nombre_curso': row['nombre_curso'], // ✅ necesario
        'paralelo': null, // opcional si ya lo incluiste en el nombre del curso
      });

      return HorarioExpandido(
        horario: horario,
        materiaCurso: materiaCurso,
        nombreCurso: row['nombre_curso'] as String,
        nombreMateria: row['nombre_materia'] as String,
      );
    }).toList();
  }

  Future<void> actualizar(Horario horario) async {
    await db.update(
      'horario_clase',
      horario.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [horario.id],
    );
  }

  Future<void> limpiarBloquesHuerfanos() async {
    await db.rawDelete('''
    DELETE FROM horario_clase
    WHERE materia_curso_id NOT IN (
      SELECT id FROM materias_curso WHERE activo = 1
    )
  ''');
  }
}
