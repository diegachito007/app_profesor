import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../models/estudiante_model.dart';
import '../models/nota_model.dart';
import '../models/nota_detalle_model.dart';
import '../models/nota_tipo_model.dart';
import '../models/tema_nota.dart';
import '../services/estudiantes_service.dart';
import '../services/asistencias_service.dart';
import '../services/notas_service.dart';
import '../services/temas_service.dart';
import '../providers/database_provider.dart';

final temaSeleccionadoProvider = StateProvider<TemaNota?>((ref) => null);

class EstudianteConEstado {
  final Estudiante estudiante;
  final bool estaBloqueado;
  final NotaDetalleModel? notasIntento1;

  EstudianteConEstado({
    required this.estudiante,
    required this.estaBloqueado,
    this.notasIntento1,
  });
}

class NotasParams {
  final int cursoId;
  final int materiaCursoId;
  final int hora;
  final String fecha;
  final String temaCodigo; // ✅ Nuevo campo

  const NotasParams({
    required this.cursoId,
    required this.materiaCursoId,
    required this.hora,
    required this.fecha,
    required this.temaCodigo,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotasParams &&
          runtimeType == other.runtimeType &&
          cursoId == other.cursoId &&
          materiaCursoId == other.materiaCursoId &&
          hora == other.hora &&
          fecha == other.fecha &&
          temaCodigo == other.temaCodigo;

  @override
  int get hashCode =>
      cursoId.hashCode ^
      materiaCursoId.hashCode ^
      hora.hashCode ^
      fecha.hashCode ^
      temaCodigo.hashCode;
}

final notasControllerProvider =
    AsyncNotifierProviderFamily<
      NotasController,
      List<EstudianteConEstado>,
      NotasParams
    >(NotasController.new);

class NotasController
    extends FamilyAsyncNotifier<List<EstudianteConEstado>, NotasParams> {
  late EstudiantesService _estudiantesService;
  late AsistenciasService _asistenciasService;
  late NotasService _notasService;
  late TemasService _temasService;

  @override
  Future<List<EstudianteConEstado>> build(NotasParams params) async {
    final db = await ref.watch(databaseProvider.future);
    _estudiantesService = EstudiantesService(db);
    _asistenciasService = AsistenciasService(db);
    _notasService = NotasService(db);
    _temasService = TemasService(db);

    final estudiantes = await _estudiantesService.obtenerPorCurso(
      params.cursoId,
    );
    final asistencias = await _asistenciasService.obtenerPorBloque(
      fecha: params.fecha,
      materiaCursoId: params.materiaCursoId,
      hora: params.hora,
    );

    final resultado = <EstudianteConEstado>[];

    for (final est in estudiantes) {
      final asistencia = asistencias.firstWhereOrNull(
        (a) => a.estudianteId == est.id,
      );

      final estaBloqueado =
          asistencia == null ||
          (asistencia.estado != 'presente' &&
              asistencia.estado != 'Justificado');

      NotaDetalleModel? intento1;

      // ✅ Solo buscar notas si hay un tema seleccionado
      if (params.temaCodigo.trim().isNotEmpty) {
        final detalles = await _notasService.obtenerDetallesPorEstudianteYTema(
          estudianteId: est.id,
          codigoNotaTema: params.temaCodigo,
        );

        intento1 = detalles.firstWhereOrNull((d) => d.intento == 1);
      }

      resultado.add(
        EstudianteConEstado(
          estudiante: est,
          estaBloqueado: estaBloqueado,
          notasIntento1: intento1,
        ),
      );
    }

    return resultado;
  }

  Future<void> guardarNota({
    required int estudianteId,
    required int materiaCursoId,
    required int notaTipoId,
    required int temaId,
    required int hora,
    required String fecha,
    required String tema,
    required double notaFinal,
    required String codigoNotaTema,
  }) async {
    final nota = NotaModel(
      estudianteId: estudianteId,
      materiaCursoId: materiaCursoId,
      notaTipoId: notaTipoId,
      temaId: temaId,
      hora: hora,
      fecha: fecha,
      codigoNotaTema: codigoNotaTema,
      notaFinal: notaFinal,
      estado: 'Regular',
    );

    await _notasService.guardarNota(nota);
  }

  Future<TemaNota> crearTemaYNotasIniciales({
    required int cursoId,
    required int materiaCursoId,
    required int hora,
    required DateTime fecha,
    required String temaNombre,
    required NotaTipoModel tipo,
  }) async {
    final fechaTexto = fecha.toIso8601String().substring(0, 10);

    final temaId = await _temasService.obtenerTemaId(temaNombre);
    final codigo = '${tipo.prefijo}$temaId';

    final estudiantes = await _estudiantesService.obtenerPorCurso(cursoId);
    final asistencias = await _asistenciasService.obtenerPorCursoYBloque(
      cursoId: cursoId,
      fecha: fechaTexto,
      materiaCursoId: materiaCursoId,
      hora: hora,
    );

    for (final est in estudiantes) {
      final asistencia = asistencias.firstWhereOrNull(
        (a) => a.estudianteId == est.id,
      );
      final estaAusente = asistencia == null || asistencia.estado == 'Ausente';

      await guardarNota(
        estudianteId: est.id,
        materiaCursoId: materiaCursoId,
        notaTipoId: tipo.id!,
        temaId: temaId,
        hora: hora,
        fecha: fechaTexto,
        tema: temaNombre,
        notaFinal: 0.0,
        codigoNotaTema: codigo,
      );

      final notaId = await _notasService.obtenerNotaIdInicio(
        estudianteId: est.id,
        temaId: temaId,
        notaTipoId: tipo.id!,
      );

      await _notasService.guardarDetalle(
        NotaDetalleModel(
          notaId: notaId,
          intento: 1,
          nota: 0.0,
          detalle: estaAusente
              ? 'Ausente en intento 1'
              : 'Intento 1 automático',
          fecha: fechaTexto,
          tipoIntento: 'Regular',
          planificacionUrl: null,
        ),
      );
    }

    return TemaNota(
      id: temaId,
      codigo: codigo,
      descripcion: temaNombre,
      tipo: tipo,
    );
  }

  Future<void> actualizarIntento({
    required int estudianteId,
    required double nota,
    required String? detalle,
    required DateTime fecha,
    required int hora,
    required int materiaCursoId,
    required String codigoNotaTema,
    required int intento, // 🔥 clave para flexibilidad
  }) async {
    final fechaTexto = fecha.toIso8601String().substring(0, 10);
    final hoyTexto = DateTime.now().toIso8601String().substring(0, 10);

    final notaId = await _notasService.obtenerNotaIdActualizar(
      estudianteId: estudianteId,
      fecha: fechaTexto,
      hora: hora.toString(),
      materiaCursoId: materiaCursoId,
      codigoNotaTema: codigoNotaTema,
    );

    if (notaId == null) {
      throw Exception('❌ No se encontró nota para el intento $intento');
    }

    await _notasService.actualizarNotaDetalle(
      notaId: notaId,
      intento: intento,
      nuevaNota: nota,
    );

    await _notasService.actualizarNotaFinal(notaId: notaId, notaFinal: nota);

    if (detalle != null &&
        detalle.trim().isNotEmpty &&
        fechaTexto == hoyTexto) {
      await _notasService.actualizarDetalleTexto(
        notaId: notaId,
        intento: intento,
        nuevoDetalle: detalle.trim(),
      );
    }
  }

  Future<List<TemaNota>> obtenerTemasDelBloque({
    required int materiaCursoId,
    required int hora,
    required String fecha,
  }) async {
    return await _notasService.obtenerTemasPorBloque(
      fecha: fecha,
      hora: hora,
      materiaCursoId: materiaCursoId,
    );
  }
}
