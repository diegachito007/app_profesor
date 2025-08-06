import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nota_detalle_model.dart';
import '../services/notas_detalle_service.dart';
import '../providers/database_provider.dart';

class NotasDetalleController
    extends FamilyAsyncNotifier<List<NotaDetalleModel>, int> {
  late final NotasDetalleService _service;

  @override
  Future<List<NotaDetalleModel>> build(int notaId) async {
    final db = await ref.watch(databaseProvider.future);
    _service = NotasDetalleService(db);
    return _service.obtenerIntentosPorNota(notaId);
  }

  Future<void> agregarIntento(NotaDetalleModel detalle) async {
    final existe = await _service.existeIntento(
      detalle.notaId,
      detalle.intento,
    );
    if (existe) {
      throw Exception(
        '⚠️ Ya existe el intento ${detalle.intento} para esta nota.',
      );
    }

    await _service.guardarIntento(detalle);
    state = await AsyncValue.guard(
      () => _service.obtenerIntentosPorNota(detalle.notaId),
    );
  }

  Future<void> eliminarIntento(int notaId, int intento) async {
    await _service.eliminarIntento(notaId, intento);
    state = await AsyncValue.guard(
      () => _service.obtenerIntentosPorNota(notaId),
    );
  }
}
