class Curso {
  final int id;
  final String nombre; // Ej: "Segundo EGB"
  final String paralelo; // Ej: "A"
  final int periodoId;
  final bool activo;

  Curso({
    required this.id,
    required this.nombre,
    required this.paralelo,
    required this.periodoId,
    required this.activo,
  });

  /// 👇 Úsalo para inserciones y actualizaciones a la base
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id == 0 ? null : id, // SQLite manejará autoincrement si es null
      'nombre': nombre,
      'paralelo': paralelo,
      'periodo_id': periodoId,
      'activo': activo ? 1 : 0,
    };
  }

  factory Curso.fromMap(Map<String, dynamic> map) {
    return Curso(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      paralelo: map['paralelo'] as String,
      periodoId: map['periodo_id'] as int,
      activo: map['activo'] == 1,
    );
  }

  String get estadoLabel => activo ? 'Activo' : 'Archivado';

  String get nombreCompleto => '$nombre $paralelo';
}
