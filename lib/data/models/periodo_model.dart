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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'inicio': inicio.toIso8601String(),
      'fin': fin.toIso8601String(),
      'activo': activo ? 1 : 0,
    };
  }

  factory Periodo.fromMap(Map<String, dynamic> map) {
    return Periodo(
      id: map['id'],
      nombre: map['nombre'],
      inicio: DateTime.parse(map['inicio']),
      fin: DateTime.parse(map['fin']),
      activo: map['activo'] == 1,
    );
  }

  String get estadoLabel => activo ? 'Activo' : 'Inactivo';
}
