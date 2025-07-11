import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/materia_curso_model.dart';
import '../services/materias_curso_service.dart';
import 'database_provider.dart';

final materiasCursoGlobalProvider = FutureProvider<List<MateriaCurso>>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  final service = MateriasCursoService(db);
  return service.obtenerTodasActivas();
});
