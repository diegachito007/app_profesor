import 'horario_model.dart';
import 'materia_curso_model.dart';

class HorarioExpandido {
  final Horario horario;
  final MateriaCurso? materiaCurso;
  final String nombreMateria;
  final String nombreCurso;

  HorarioExpandido({
    required this.horario,
    required this.materiaCurso,
    required this.nombreMateria,
    required this.nombreCurso,
  });

  String get descripcion => '$nombreCurso - $nombreMateria';

  factory HorarioExpandido.fromMap(Map<String, dynamic> map) {
    return HorarioExpandido(
      horario: Horario(
        id: map['id'] as int?,
        dia: map['dia'] as String,
        hora: map['hora'] as int,
        materiaCursoId: map['materia_curso_id'] as int,
      ),
      materiaCurso: map['mc_id'] != null
          ? MateriaCurso.fromMap({
              'id': map['mc_id'],
              'curso_id': map['curso_id'],
              'materia_id': map['materia_id'],
              'activo': map['activo'],
              'fecha_asignacion': map['fecha_asignacion'],
              'fecha_desactivacion': map['fecha_desactivacion'],
            })
          : null,
      nombreMateria: map['nombre_materia'] as String? ?? 'Materia desconocida',
      nombreCurso: map['nombre_curso'] as String? ?? 'Curso desconocido',
    );
  }
}
