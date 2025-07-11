import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/horario_expandido.dart';
import '../models/horario_model.dart';
import '../services/horarios_service.dart';
import '../providers/database_provider.dart';

final horariosControllerProvider =
    AsyncNotifierProvider.family<
      HorariosController,
      List<HorarioExpandido>,
      String
    >(HorariosController.new);

class HorariosController
    extends FamilyAsyncNotifier<List<HorarioExpandido>, String> {
  late String dia;

  @override
  Future<List<HorarioExpandido>> build(String diaParametro) async {
    dia = diaParametro;

    final db = await ref.watch(databaseProvider.future);
    final service = HorariosService(db);

    return service.obtenerExpandidoPorDia(dia);
  }

  Future<void> guardarHorario(Horario nuevo) async {
    state = const AsyncValue.loading();

    try {
      final db = await ref.read(databaseProvider.future);
      final service = HorariosService(db);

      await service.guardar(nuevo);
      final actualizados = await service.obtenerExpandidoPorDia(dia);
      state = AsyncValue.data(actualizados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> eliminarHorario(int id) async {
    state = const AsyncValue.loading();

    try {
      final db = await ref.read(databaseProvider.future);
      final service = HorariosService(db);

      await service.eliminar(id);
      final actualizados = await service.obtenerExpandidoPorDia(dia);
      state = AsyncValue.data(actualizados);
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
      final db = await ref.read(databaseProvider.future);
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
      state = AsyncValue.data(actualizados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
