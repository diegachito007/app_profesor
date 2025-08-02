class AsistenciaModel {
  final int? id;
  final String fecha;
  final int estudianteId;
  final int materiaCursoId;
  final int hora;
  final String estado;

  final String? detalle; // observación contextual al registrar
  final String? fechaJustificacion; // cuándo se justificó
  final String? fotoJustificacion; // evidencia visual
  final String? detalleJustificacion; // explicación formal

  AsistenciaModel({
    this.id,
    required this.fecha,
    required this.estudianteId,
    required this.materiaCursoId,
    required this.hora,
    required this.estado,
    this.detalle,
    this.fechaJustificacion,
    this.fotoJustificacion,
    this.detalleJustificacion,
  });

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'fecha': fecha,
      'estudiante_id': estudianteId,
      'materia_curso_id': materiaCursoId,
      'hora': hora,
      'estado': estado,
      'detalle': detalle,
      'fecha_justificacion': fechaJustificacion,
      'foto_justificacion': fotoJustificacion,
      'detalle_justificacion': detalleJustificacion,
    };
  }

  factory AsistenciaModel.fromMap(Map<String, dynamic> map) {
    return AsistenciaModel(
      id: map['id'] as int?,
      fecha: map['fecha'] as String,
      estudianteId: map['estudiante_id'] as int,
      materiaCursoId: map['materia_curso_id'] as int,
      hora: map['hora'] as int,
      estado: map['estado'] as String,
      detalle: map['detalle'] as String?,
      fechaJustificacion: map['fecha_justificacion'] as String?,
      fotoJustificacion: map['foto_justificacion'] as String?,
      detalleJustificacion: map['detalle_justificacion'] as String?,
    );
  }

  @override
  String toString() {
    return 'AsistenciaModel(id: $id, fecha: $fecha, estudianteId: $estudianteId, materiaCursoId: $materiaCursoId, hora: $hora, estado: $estado)';
  }
}
