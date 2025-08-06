class NotaDetalleModel {
  final int? id;
  final int notaId;
  final int intento;
  final double nota;
  final String detalle;
  final String fecha;
  final String tipoIntento;
  final String? planificacionUrl;

  NotaDetalleModel({
    this.id,
    required this.notaId,
    required this.intento,
    required this.nota,
    required this.detalle,
    required this.fecha,
    required this.tipoIntento,
    this.planificacionUrl,
  });

  Map<String, dynamic> toDatabaseMap() {
    return {
      if (id != null) 'id': id,
      'nota_id': notaId,
      'intento': intento,
      'nota': nota,
      'detalle': detalle,
      'fecha': fecha,
      'tipo_intento': tipoIntento,
      'planificacion_url': planificacionUrl,
    };
  }

  factory NotaDetalleModel.fromMap(Map<String, dynamic> map) {
    return NotaDetalleModel(
      id: map['id'] as int?,
      notaId: map['nota_id'] as int,
      intento: map['intento'] as int,
      nota: map['nota'] as double,
      detalle: map['detalle'] as String? ?? '',
      fecha: map['fecha'] as String,
      tipoIntento: map['tipo_intento'] as String,
      planificacionUrl: map['planificacion_url'] as String?,
    );
  }

  @override
  String toString() {
    return 'NotaDetalleModel(id: $id, notaId: $notaId, intento: $intento, nota: $nota, tipoIntento: $tipoIntento, fecha: $fecha)';
  }
}
