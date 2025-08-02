class JornadaModel {
  final int? id;
  final String fecha; // formato ISO: yyyy-MM-dd
  final int materiaCursoId;
  final int hora; // entero para facilitar comparaciones
  final String estado; // 'activa' o 'suspendida'

  final String? detalle; // motivo de suspensión
  final String creadoEn; // timestamp de creación

  JornadaModel({
    this.id,
    required this.fecha,
    required this.materiaCursoId,
    required this.hora,
    required this.estado,
    this.detalle,
    required this.creadoEn,
  });

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'fecha': fecha,
      'materia_curso_id': materiaCursoId,
      'hora': hora,
      'estado': estado,
      'detalle': detalle,
      'creado_en': creadoEn,
    };
  }

  factory JornadaModel.fromMap(Map<String, dynamic> map) {
    return JornadaModel(
      id: map['id'] as int?,
      fecha: map['fecha'] as String,
      materiaCursoId: map['materia_curso_id'] as int,
      hora: map['hora'] as int,
      estado: map['estado'] as String,
      detalle: map['detalle'] as String?,
      creadoEn: map['creado_en'] as String,
    );
  }

  @override
  String toString() {
    return 'JornadaModel(id: $id, fecha: $fecha, materiaCursoId: $materiaCursoId, hora: $hora, estado: $estado)';
  }
}
