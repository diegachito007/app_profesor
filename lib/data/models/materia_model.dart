class Materia {
  final int id;
  final String nombre;

  Materia({required this.id, required this.nombre});

  /// 👇 Para insertar o actualizar en la base de datos
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id == 0 ? null : id, // SQLite manejará autoincrement si es null
      'nombre': nombre,
    };
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(id: map['id'] as int, nombre: map['nombre'] as String);
  }

  /// 👇 Para mostrar en la UI si decides extenderlo
  String get nombreFormateado => nombre;
}
