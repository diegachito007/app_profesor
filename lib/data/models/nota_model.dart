class NotaModel {
  final int? id;
  final int estudianteId;
  final int materiaCursoId;
  final String fecha;
  final int temaId;
  final int notaTipoId; // ← nuevo campo
  final double valor;
  final String? observacion;

  NotaModel({
    this.id,
    required this.estudianteId,
    required this.materiaCursoId,
    required this.fecha,
    required this.temaId,
    required this.notaTipoId, // ← requerido
    required this.valor,
    this.observacion,
  });

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'estudiante_id': estudianteId,
      'materia_curso_id': materiaCursoId,
      'fecha': fecha,
      'tema_id': temaId,
      'nota_tipo_id': notaTipoId, // ← actualizado
      'valor': valor,
      'observacion': observacion,
    };
  }

  factory NotaModel.fromMap(Map<String, dynamic> map) {
    return NotaModel(
      id: map['id'] as int?,
      estudianteId: map['estudiante_id'] as int,
      materiaCursoId: map['materia_curso_id'] as int,
      fecha: map['fecha'] as String,
      temaId: map['tema_id'] as int,
      notaTipoId: map['nota_tipo_id'] as int, // ← actualizado
      valor: map['valor'] as double,
      observacion: map['observacion'] as String?,
    );
  }

  @override
  String toString() {
    return 'NotaModel(id: $id, estudianteId: $estudianteId, materiaCursoId: $materiaCursoId, fecha: $fecha, temaId: $temaId, notaTipoId: $notaTipoId, valor: $valor)';
  }
}
