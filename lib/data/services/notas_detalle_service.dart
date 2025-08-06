import 'package:sqflite/sqflite.dart';
import '../models/nota_detalle_model.dart';

class NotasDetalleService {
  final Database db;

  NotasDetalleService(this.db);

  Future<int> guardarIntento(NotaDetalleModel detalle) async {
    return await db.insert('notas_detalle', detalle.toDatabaseMap());
  }

  Future<List<NotaDetalleModel>> obtenerIntentosPorNota(int notaId) async {
    final result = await db.query(
      'notas_detalle',
      where: 'nota_id = ?',
      whereArgs: [notaId],
      orderBy: 'intento ASC',
    );
    return result.map((e) => NotaDetalleModel.fromMap(e)).toList();
  }

  Future<bool> existeIntento(int notaId, int intento) async {
    final result = await db.query(
      'notas_detalle',
      where: 'nota_id = ? AND intento = ?',
      whereArgs: [notaId, intento],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> eliminarIntento(int notaId, int intento) async {
    await db.delete(
      'notas_detalle',
      where: 'nota_id = ? AND intento = ?',
      whereArgs: [notaId, intento],
    );
  }
}
