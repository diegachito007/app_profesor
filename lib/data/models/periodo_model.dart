class Periodo {
  final int id;
  final String nombre;
  final DateTime inicio;
  final DateTime fin;
  final bool activo;

  Periodo({
    required this.id,
    required this.nombre,
    required this.inicio,
    required this.fin,
    required this.activo,
  });

  // 👇 Úsalo para inserciones y actualizaciones a la base
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id == 0 ? null : id, // SQLite manejará autoincrement si es null
      'nombre': nombre,
      'fecha_inicio': inicio.toIso8601String(),
      'fecha_fin': fin.toIso8601String(),
      'activo': activo ? 1 : 0,
    };
  }

  factory Periodo.fromMap(Map<String, dynamic> map) {
    return Periodo(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      inicio: DateTime.parse(map['fecha_inicio'] as String),
      fin: DateTime.parse(map['fecha_fin'] as String),
      activo: map['activo'] == 1,
    );
  }

  String get estadoLabel => activo ? 'Activo' : 'Inactivo';
}
