import 'package:sqflite/sqflite.dart';
import '../models/nota_model.dart';
import '../models/nota_detalle_model.dart';
import '../models/tema_nota.dart';

class NotasService {
  final Database db;

  NotasService(this.db);

  /// 📝 Guarda una nota principal en la tabla `notas`
  Future<int> guardarNota(NotaModel nota) async {
    return await db.insert('notas', nota.toDatabaseMap());
  }

  /// 📄 Verifica si ya existe una nota para el estudiante con ese tema y tipo
  Future<bool> existeNota(int estudianteId, int temaId, int notaTipoId) async {
    final result = await db.query(
      'notas',
      where: 'estudiante_id = ? AND tema_id = ? AND nota_tipo_id = ?',
      whereArgs: [estudianteId, temaId, notaTipoId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// 📄 Obtiene todas las notas de un estudiante
  Future<List<NotaModel>> obtenerNotasPorEstudiante(int estudianteId) async {
    final result = await db.query(
      'notas',
      where: 'estudiante_id = ?',
      whereArgs: [estudianteId],
      orderBy: 'fecha DESC',
    );
    return result.map((e) => NotaModel.fromMap(e)).toList();
  }

  /// 🧾 Guarda un intento en la tabla `notas_detalle`
  Future<int> guardarDetalle(NotaDetalleModel detalle) async {
    return await db.insert('notas_detalle', detalle.toDatabaseMap());
  }

  /// 📄 Obtiene todos los intentos registrados para una nota
  Future<List<NotaDetalleModel>> obtenerDetallesPorNota(int notaId) async {
    final result = await db.query(
      'notas_detalle',
      where: 'nota_id = ?',
      whereArgs: [notaId],
      orderBy: 'intento ASC',
    );
    return result.map((e) => NotaDetalleModel.fromMap(e)).toList();
  }

  /// 🧠 Verifica si ya existe un intento específico para una nota
  Future<bool> existeIntento(int notaId, int intento) async {
    final result = await db.query(
      'notas_detalle',
      where: 'nota_id = ? AND intento = ?',
      whereArgs: [notaId, intento],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// 🔍 Obtiene el ID de una nota existente por estudiante, tema y tipo
  Future<int> obtenerNotaIdInicio({
    required int estudianteId,
    required int temaId,
    required int notaTipoId,
  }) async {
    final result = await db.query(
      'notas',
      columns: ['id'],
      where: 'estudiante_id = ? AND tema_id = ? AND nota_tipo_id = ?',
      whereArgs: [estudianteId, temaId, notaTipoId],
      limit: 1,
    );

    if (result.isEmpty) {
      throw Exception('❌ Nota no encontrada para el estudiante $estudianteId');
    }

    return result.first['id'] as int;
  }

  Future<int?> obtenerNotaIdActualizar({
    required int estudianteId,
    required String fecha, // 'YYYY-MM-DD'
    required String hora, // 'HH:mm'
    required int materiaCursoId,
    required String codigoNotaTema,
  }) async {
    final result = await db.rawQuery(
      '''
    SELECT id FROM notas
    WHERE estudiante_id = ?
      AND fecha = ?
      AND hora = ?
      AND materia_curso_id = ?
      AND codigo_nota_tema = ?
    LIMIT 1
    ''',
      [estudianteId, fecha, hora, materiaCursoId, codigoNotaTema],
    );

    if (result.isEmpty) return null;
    return result.first['id'] as int;
  }

  /// ✏️ Actualiza la nota numérica de un intento específico
  Future<void> actualizarNotaDetalle({
    required int notaId,
    required int intento,
    required double nuevaNota,
  }) async {
    await db.update(
      'notas_detalle',
      {'nota': nuevaNota},
      where: 'nota_id = ? AND intento = ?',
      whereArgs: [notaId, intento],
    );
  }

  /// 🗒️ Actualiza el texto del detalle de un intento específico
  Future<void> actualizarDetalleTexto({
    required int notaId,
    required int intento,
    required String nuevoDetalle,
  }) async {
    await db.update(
      'notas_detalle',
      {'detalle': nuevoDetalle},
      where: 'nota_id = ? AND intento = ?',
      whereArgs: [notaId, intento],
    );
  }

  /// 🔁 Actualiza el campo `nota_final` en la tabla `notas`
  Future<void> actualizarNotaFinal({
    required int notaId,
    required double notaFinal,
  }) async {
    await db.update(
      'notas',
      {'nota_final': notaFinal},
      where: 'id = ?',
      whereArgs: [notaId],
    );
  }

  /// 📥 Obtiene todas las notas asociadas a un tema específico
  Future<List<NotaModel>> obtenerNotasPorTema(int temaId) async {
    final result = await db.query(
      'notas',
      where: 'tema_id = ?',
      whereArgs: [temaId],
      orderBy: 'estudiante_id ASC',
    );
    return result.map((e) => NotaModel.fromMap(e)).toList();
  }

  Future<List<TemaNota>> obtenerTemasPorBloque({
    required String fecha,
    required int hora,
    required int materiaCursoId,
  }) async {
    final result = await db.rawQuery(
      '''
    SELECT DISTINCT 
      t.id, 
      t.nombre, 
      n.codigo_nota_tema AS codigo, 
      n.nota_tipo_id AS tipo_id
    FROM temas t
    JOIN notas n ON n.tema_id = t.id
    WHERE 
      n.fecha = ? AND 
      n.hora = ? AND 
      n.materia_curso_id = ?
    ORDER BY t.id ASC
    ''',
      [fecha, hora, materiaCursoId],
    );

    return result.map((e) => TemaNota.fromMap(e)).toList();
  }

  Future<List<NotaDetalleModel>> obtenerDetallesPorEstudianteYTema({
    required int estudianteId,
    required String codigoNotaTema,
  }) async {
    final result = await db.rawQuery(
      '''
    SELECT nd.* FROM notas_detalle nd
    JOIN notas n ON nd.nota_id = n.id
    WHERE n.estudiante_id = ?
      AND n.codigo_nota_tema = ?
    ORDER BY nd.intento ASC
    ''',
      [estudianteId, codigoNotaTema],
    );

    return result.map((e) => NotaDetalleModel.fromMap(e)).toList();
  }
}
