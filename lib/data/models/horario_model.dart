class Horario {
  final int? id;
  final String dia; // Ej: "Lunes"
  final int hora; // Ej: 1, 2, ..., 7
  final int materiaCursoId;

  Horario({
    required this.id,
    required this.dia,
    required this.hora,
    required this.materiaCursoId,
  });

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      id: map['id'] as int?,
      dia: map['dia'] as String,
      hora: map['hora'] as int,
      materiaCursoId: map['materia_curso_id'] as int,
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'dia': dia,
      'hora': hora,
      'materia_curso_id': materiaCursoId,
    };
  }
}
