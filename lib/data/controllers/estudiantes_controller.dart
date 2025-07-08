import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/estudiante_model.dart';
import '../services/estudiantes_service.dart';
import '../providers/database_provider.dart';

final estudiantesControllerProvider =
    AsyncNotifierProvider.family<EstudiantesController, List<Estudiante>, int>(
      EstudiantesController.new,
    );

class EstudiantesController extends FamilyAsyncNotifier<List<Estudiante>, int> {
  late final EstudiantesService _service;

  @override
  Future<List<Estudiante>> build(int cursoId) async {
    final db = await ref.watch(databaseProvider.future);
    _service = EstudiantesService(db);
    return _service.obtenerPorCurso(cursoId);
  }

  Future<List<Estudiante>> obtenerTodos() async {
    final currentState = state;
    if (currentState is AsyncData<List<Estudiante>>) {
      return currentState.value;
    } else {
      return [];
    }
  }

  Future<void> agregarEstudiante(Estudiante estudiante) async {
    state = const AsyncValue.loading();
    try {
      await _service.insertarEstudiante(estudiante);
      final actualizados = await _service.obtenerPorCurso(estudiante.cursoId);
      state = AsyncValue.data(actualizados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> actualizarEstudiante(Estudiante estudiante) async {
    state = const AsyncValue.loading();
    try {
      await _service.actualizarEstudiante(estudiante);
      final actualizados = await _service.obtenerPorCurso(estudiante.cursoId);
      state = AsyncValue.data(actualizados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> eliminarEstudiante(int estudianteId, int cursoId) async {
    state = const AsyncValue.loading();
    try {
      await _service.eliminarEstudiante(estudianteId);
      final actualizados = await _service.obtenerPorCurso(cursoId);
      state = AsyncValue.data(actualizados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> existeCedula(String cedula) async {
    return _service.existeCedula(cedula);
  }

  Future<void> insertarLote(List<Estudiante> estudiantes) async {
    if (estudiantes.isEmpty) return;
    state = const AsyncValue.loading();
    try {
      await _service.insertarLote(estudiantes);
      final actualizados = await _service.obtenerPorCurso(
        estudiantes.first.cursoId,
      );
      state = AsyncValue.data(actualizados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> eliminarTodosLosEstudiantes() async {
    state = const AsyncValue.loading();
    try {
      await _service.eliminarTodosDelCurso(arg); // `arg` es el cursoId
      final actualizados = await _service.obtenerPorCurso(arg);
      state = AsyncValue.data(actualizados);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
