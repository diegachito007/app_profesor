class AsistenciaModel {
  final int? id;
  final String fecha;
  final int estudianteId;
  final int materiaCursoId;
  final int hora;
  final String estado;
  final String? fechaRegistro;
  final String? fotoJustificacion;
  final String? comentario;

  AsistenciaModel({
    this.id,
    required this.fecha,
    required this.estudianteId,
    required this.materiaCursoId,
    required this.hora,
    required this.estado,
    this.fechaRegistro,
    this.fotoJustificacion,
    this.comentario,
  });

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'fecha': fecha,
      'estudiante_id': estudianteId,
      'materia_curso_id': materiaCursoId,
      'hora': hora,
      'estado': estado,
      'fecha_registro': fechaRegistro,
      'foto_justificacion': fotoJustificacion,
      'comentario': comentario,
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
      fechaRegistro: map['fecha_registro'] as String?,
      fotoJustificacion: map['foto_justificacion'] as String?,
      comentario: map['comentario'] as String?,
    );
  }

  @override
  String toString() {
    return 'AsistenciaModel(id: $id, fecha: $fecha, estudianteId: $estudianteId, materiaCursoId: $materiaCursoId, hora: $hora, estado: $estado)';
  }
}
