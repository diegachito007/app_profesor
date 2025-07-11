class MateriaCurso {
  final int id;
  final int cursoId;
  final int materiaId;
  final bool activo;
  final DateTime fechaAsignacion;
  final DateTime? fechaDesactivacion;

  // Campos opcionales para visualización
  final String? nombreMateria;
  final String? nombreCurso;
  final String? paralelo; // ✅ nuevo campo

  MateriaCurso({
    required this.id,
    required this.cursoId,
    required this.materiaId,
    required this.activo,
    required this.fechaAsignacion,
    this.fechaDesactivacion,
    this.nombreMateria,
    this.nombreCurso,
    this.paralelo, // ✅ nuevo campo
  });

  factory MateriaCurso.fromMap(Map<String, dynamic> map) {
    return MateriaCurso(
      id: map['id'],
      cursoId: map['curso_id'],
      materiaId: map['materia_id'],
      activo: map['activo'] == 1,
      fechaAsignacion: DateTime.parse(map['fecha_asignacion']),
      fechaDesactivacion: map['fecha_desactivacion'] != null
          ? DateTime.tryParse(map['fecha_desactivacion'])
          : null,
      nombreMateria: map['nombre_materia'],
      nombreCurso: map['nombre_curso'],
      paralelo: map['paralelo'], // ✅ mapeo desde SQL
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'curso_id': cursoId,
      'materia_id': materiaId,
      'activo': activo ? 1 : 0,
      'fecha_asignacion': fechaAsignacion.toIso8601String(),
      'fecha_desactivacion': fechaDesactivacion?.toIso8601String(),
    };
  }

  // ✅ Getter para mostrar curso completo con paralelo
  String get nombreCursoCompleto {
    if (nombreCurso == null) return 'Curso';
    if (paralelo == null || paralelo!.isEmpty) return nombreCurso!;
    return '$nombreCurso $paralelo';
  }
}
