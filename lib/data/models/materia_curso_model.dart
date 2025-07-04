class MateriaCurso {
  final int id;
  final int cursoId;
  final int materiaId;
  final bool activo;
  final DateTime fechaAsignacion;
  final DateTime? fechaDesactivacion;

  MateriaCurso({
    required this.id,
    required this.cursoId,
    required this.materiaId,
    required this.activo,
    required this.fechaAsignacion,
    this.fechaDesactivacion,
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
}
