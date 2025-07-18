import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/materia_model.dart';
import '../services/materias_service.dart';
import '../providers/database_provider.dart';

final materiasPorTipoProvider = FutureProvider.family<List<Materia>, int>((
  ref,
  tipoId,
) async {
  final db = await ref.watch(databaseProvider.future);
  final service = MateriasService(db);
  return service.obtenerPorTipoId(tipoId);
});
