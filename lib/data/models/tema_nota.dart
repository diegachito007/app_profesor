import 'nota_tipo_model.dart';

class TemaNota {
  final int id; // ✅ ID institucional del tema
  final String codigo; // Código generado para el tema (ej. REG123)
  final String descripcion; // Nombre del tema
  final NotaTipoModel
  tipo; // Tipo de nota asociado (Regular, Recuperación, etc.)

  TemaNota({
    required this.id,
    required this.codigo,
    required this.descripcion,
    required this.tipo,
  });

  /// 🏗️ Constructor desde la base de datos (si lo necesitas)
  factory TemaNota.fromMap(Map<String, dynamic> map) {
    return TemaNota(
      id: map['id'] as int,
      codigo: map['codigo'] as String,
      descripcion: map['nombre'] as String, // ← corregido
      tipo: NotaTipoModel.minimo(id: map['tipo_id'] as int), // ← prefijo vacío
    );
  }

  /// 🔄 Mapeo para insertar o actualizar en la base de datos
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'codigo': codigo,
      'descripcion': descripcion,
      'nota_tipo_id': tipo.id, // si lo necesitas como FK
    };
  }

  @override
  String toString() {
    return 'TemaNota(id: $id, codigo: $codigo, descripcion: $descripcion, tipo: ${tipo.prefijo})';
  }
}
