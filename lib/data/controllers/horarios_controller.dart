import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/horario_expandido.dart';
import '../models/horario_model.dart';
import '../services/horarios_service.dart';
import '../providers/database_provider.dart';
import '../services/materias_curso_service.dart';
import 'package:sqflite/sqflite.dart';

final horariosControllerProvider =
    AsyncNotifierProvider.family<
      HorariosController,
      List<HorarioExpandido>,
      String
    >(HorariosController.new);

class HorariosController
    extends FamilyAsyncNotifier<List<HorarioExpandido>, String> {
  late String dia;
  late Database db;

  @override
  Future<List<HorarioExpandido>> build(String diaParametro) async {
    dia = diaParametro;
    db = await ref.watch(databaseProvider.future);

    final service = HorariosService(db);
    final todosLosBloques = await service.obtenerExpandidoPorDia(dia);
    return await _filtrarSoloValidos(todosLosBloques);
  }

  Future<List<HorarioExpandido>> _filtrarSoloValidos(
    List<HorarioExpandido> todos,
  ) async {
    final materiasService = MateriasCursoService(db);
    final materiasCursoValidas = await materiasService.obtenerTodasActivas();
    final idsValidos = materiasCursoValidas.map((mc) => mc.id).toSet();
    return todos
        .where((b) => idsValidos.contains(b.horario.materiaCursoId))
        .toList();
  }

  Future<void> guardarHorario(Horario nuevo) async {
    state = const AsyncValue.loading();

    try {
      final service = HorariosService(db);
      await service.guardar(nuevo);

      final actualizados = await service.obtenerExpandidoPorDia(dia);
      final filtrados = await _filtrarSoloValidos(actualizados);
      state = AsyncValue.data(filtrados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> eliminarHorario(int id) async {
    state = const AsyncValue.loading();

    try {
      final service = HorariosService(db);
      await service.eliminar(id);

      final actualizados = await service.obtenerExpandidoPorDia(dia);
      final filtrados = await _filtrarSoloValidos(actualizados);
      state = AsyncValue.data(filtrados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> guardarBloque({
    required String dia,
    required int hora,
    required int materiaCursoId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = HorariosService(db);
      final existente = await service.obtenerPorDiaYHora(dia, hora);

      if (existente != null) {
        final actualizado = Horario(
          id: existente.id,
          dia: existente.dia,
          hora: existente.hora,
          materiaCursoId: materiaCursoId,
        );
        await service.actualizar(actualizado);
      } else {
        final nuevo = Horario(
          id: null,
          dia: dia,
          hora: hora,
          materiaCursoId: materiaCursoId,
        );
        await service.guardar(nuevo);
      }

      final actualizados = await service.obtenerExpandidoPorDia(dia);
      final filtrados = await _filtrarSoloValidos(actualizados);
      state = AsyncValue.data(filtrados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
