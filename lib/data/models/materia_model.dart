import 'package:app_profesor/data/models/materia_tipo_model.dart';

class Materia {
  final int id;
  final String nombre;
  final int tipoId;
  final MateriaTipo? tipo; // opcional si quieres cargarlo

  Materia({
    required this.id,
    required this.nombre,
    required this.tipoId,
    this.tipo,
  });

  /// 👇 Para insertar o actualizar en la base de datos
  Map<String, dynamic> toDatabaseMap() {
    return {'id': id == 0 ? null : id, 'nombre': nombre, 'tipo_id': tipoId};
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      tipoId: map['tipo_id'] as int,
    );
  }

  /// 👇 Para mostrar en la UI si decides extenderlo
  String get nombreFormateado => nombre;
}
