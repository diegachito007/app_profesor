class NotaTipoModel {
  final int? id;
  final String nombre;
  final String prefijo;
  final bool activo;
  final String createdAt;

  NotaTipoModel({
    this.id,
    required this.nombre,
    required this.prefijo,
    required this.activo,
    required this.createdAt,
  });

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'nombre': nombre,
      'prefijo': prefijo,
      'activo': activo ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory NotaTipoModel.fromMap(Map<String, dynamic> map) {
    return NotaTipoModel(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      prefijo: map['prefijo'] as String,
      activo: map['activo'] == 1,
      createdAt: map['created_at'] as String,
    );
  }

  @override
  String toString() {
    return 'NotaTipoModel(id: $id, nombre: $nombre, prefijo: $prefijo, activo: $activo)';
  }
}
