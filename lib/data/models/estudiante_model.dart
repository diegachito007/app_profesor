class Estudiante {
  final int id;
  final String cedula;
  final String nombre;
  final String apellido;
  final String telefono;
  final int cursoId;

  Estudiante({
    required this.id,
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.cursoId,
  });

  /// 👇 Para inserciones y actualizaciones
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id == 0 ? null : id,
      'cedula': cedula,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'curso_id': cursoId,
    };
  }

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id'] as int,
      cedula: map['cedula'] as String,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
      telefono: map['telefono'] as String? ?? '',
      cursoId: map['curso_id'] as int,
    );
  }

  /// 👤 Nombre completo del estudiante
  String get nombreCompleto => '$nombre $apellido';

  /// 📞 Teléfono formateado (si quieres aplicar lógica adicional)
  String get telefonoFormateado => telefono.isEmpty ? 'Sin número' : telefono;
}
