class Tema {
  final int id;
  final String nombre;

  Tema({required this.id, required this.nombre});

  /// 🔄 Mapeo para insertar en la base de datos
  Map<String, dynamic> toDatabaseMap() {
    return {if (id != 0) 'id': id, 'nombre': nombre.trim().toLowerCase()};
  }

  /// 🏗️ Constructor desde la base de datos
  factory Tema.fromMap(Map<String, dynamic> map) {
    return Tema(id: map['id'] as int, nombre: map['nombre'] as String);
  }

  /// 🎨 Nombre formateado para mostrar en la UI
  String get nombreFormateado {
    if (nombre.isEmpty) return '';
    return nombre[0].toUpperCase() + nombre.substring(1);
  }
}
