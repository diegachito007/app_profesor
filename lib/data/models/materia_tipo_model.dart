class MateriaTipo {
  final int id;
  final String nombre;
  final String sigla;

  MateriaTipo({required this.id, required this.nombre, required this.sigla});

  factory MateriaTipo.fromMap(Map<String, dynamic> map) {
    return MateriaTipo(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      sigla: map['sigla'] as String,
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {'id': id == 0 ? null : id, 'nombre': nombre, 'sigla': sigla};
  }

  @override
  String toString() => sigla;
}
