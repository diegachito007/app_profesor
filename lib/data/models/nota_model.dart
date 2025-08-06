class NotaModel {
  final int? id;
  final String fecha;
  final int hora;

  final int estudianteId;
  final int materiaCursoId;
  final int notaTipoId;
  final int temaId;

  final String codigoNotaTema;
  final double notaFinal;
  final String estado;

  NotaModel({
    this.id,
    required this.fecha,
    required this.hora,
    required this.estudianteId,
    required this.materiaCursoId,
    required this.notaTipoId,
    required this.temaId,
    required this.codigoNotaTema,
    required this.notaFinal,
    this.estado = 'Regular',
  });

  /// 🔄 Mapeo para insertar en la base de datos
  Map<String, dynamic> toDatabaseMap() {
    return {
      if (id != null) 'id': id,
      'fecha': fecha,
      'hora': hora,
      'estudiante_id': estudianteId,
      'materia_curso_id': materiaCursoId,
      'nota_tipo_id': notaTipoId,
      'tema_id': temaId,
      'codigo_nota_tema': codigoNotaTema,
      'nota_final': notaFinal,
      'estado': estado,
    };
  }

  /// 🏗️ Constructor desde la base de datos
  factory NotaModel.fromMap(Map<String, dynamic> map) {
    return NotaModel(
      id: map['id'] as int?,
      fecha: map['fecha'] as String,
      hora: map['hora'] as int,
      estudianteId: map['estudiante_id'] as int,
      materiaCursoId: map['materia_curso_id'] as int,
      notaTipoId: map['nota_tipo_id'] as int,
      temaId: map['tema_id'] as int,
      codigoNotaTema: map['codigo_nota_tema'] as String,
      notaFinal: map['nota_final'] as double,
      estado: map['estado'] as String? ?? 'Regular',
    );
  }

  @override
  String toString() {
    return 'NotaModel(id: $id, estudianteId: $estudianteId, materiaCursoId: $materiaCursoId, fecha: $fecha, hora: $hora, temaId: $temaId, notaTipoId: $notaTipoId, notaFinal: $notaFinal, estado: $estado)';
  }
}
