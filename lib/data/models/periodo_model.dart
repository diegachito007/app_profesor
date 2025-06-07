class Periodo {
  final int id;
  final String nombre;
  final DateTime inicio;
  final DateTime fin;

  Periodo({
    required this.id,
    required this.nombre,
    required this.inicio,
    required this.fin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'inicio': inicio.toIso8601String(),
      'fin': fin.toIso8601String(),
    };
  }

  factory Periodo.fromMap(Map<String, dynamic> map) {
    return Periodo(
      id: map['id'],
      nombre: map['nombre'],
      inicio: DateTime.parse(map['inicio']),
      fin: DateTime.parse(map['fin']),
    );
  }
}
