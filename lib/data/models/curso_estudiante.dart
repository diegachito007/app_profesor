class CursoEstudiantes {
  final int id;
  final String nombre;
  final String paralelo;
  final int periodoId;
  final bool activo;
  final int totalEstudiantes;

  CursoEstudiantes({
    required this.id,
    required this.nombre,
    required this.paralelo,
    required this.periodoId,
    required this.activo,
    required this.totalEstudiantes,
  });

  factory CursoEstudiantes.fromMap(Map<String, dynamic> map) {
    return CursoEstudiantes(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      paralelo: map['paralelo'] as String,
      periodoId: map['periodo_id'] as int,
      activo: map['activo'] == 1,
      totalEstudiantes: map['total_estudiantes'] as int,
    );
  }

  String get nombreCompleto => '$nombre $paralelo';
  String get estadoLabel => activo ? 'Activo' : 'Archivado';
}
