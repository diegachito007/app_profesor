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

  /// 🧠 Prioriza nombre desde materiaCurso si está presente
  String get nombreMateriaFinal => materiaCurso?.nombreMateria ?? nombreMateria;

  String get nombreCursoFinal =>
      materiaCurso?.nombreCursoCompleto ?? nombreCurso;

  /// 🎯 Descripción compuesta para mostrar en UI
  String get descripcion => '$nombreCursoFinal - $nombreMateriaFinal';

  /// 🔍 Estado del bloque (activo/inactivo)
  bool get estaActivo => materiaCurso?.activo ?? false;

  /// 🧩 Constructor desde SQL JOIN
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
              'nombre_materia': map['nombre_materia'],
              'nombre_curso': map['nombre_curso'],
              'paralelo': map['paralelo'],
            })
          : null,
      nombreMateria: map['nombre_materia'] as String? ?? 'Materia desconocida',
      nombreCurso: map['nombre_curso'] as String? ?? 'Curso desconocido',
    );
  }
}
