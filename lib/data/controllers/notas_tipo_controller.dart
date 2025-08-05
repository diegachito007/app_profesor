import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nota_tipo_model.dart';
import '../services/notas_tipo_service.dart';
import '../providers/database_provider.dart';

final notasTipoControllerProvider =
    AsyncNotifierProvider<NotasTipoController, List<NotaTipoModel>>(
      NotasTipoController.new,
    );

class NotasTipoController extends AsyncNotifier<List<NotaTipoModel>> {
  late NotasTipoService _notasTipoService;

  @override
  Future<List<NotaTipoModel>> build() async {
    final db = await ref.watch(databaseProvider.future);
    _notasTipoService = NotasTipoService(db);

    return await _notasTipoService.obtenerActivos();
  }

  /// 🔄 Recarga los tipos de nota activos
  Future<void> recargar() async {
    final nuevos = await _notasTipoService.obtenerActivos();
    state = AsyncValue.data(nuevos);
  }

  /// ➕ Inserta un nuevo tipo de nota
  Future<void> insertar({
    required String nombre,
    required String prefijo,
  }) async {
    await _notasTipoService.insertar(nombre: nombre, prefijo: prefijo);
    await recargar();
  }

  /// ✏️ Actualiza un tipo de nota existente
  Future<void> actualizar(NotaTipoModel tipo) async {
    await _notasTipoService.actualizar(tipo);
    await recargar();
  }

  /// 🚫 Desactiva un tipo de nota
  Future<void> desactivar(int id) async {
    await _notasTipoService.desactivar(id);
    await recargar();
  }

  /// 🔍 Buscar por ID
  NotaTipoModel? obtenerPorId(int id) {
    return state.value?.firstWhere((e) => e.id == id);
  }
}
