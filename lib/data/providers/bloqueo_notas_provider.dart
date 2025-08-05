import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'asistencias_provider.dart'; // Asegúrate de que este sea el nombre correcto

/// Provider que indica si el campo de notas debe estar bloqueado para un estudiante
final bloqueoNotasProvider = Provider.family<bool, AsistenciaParamsEstudiante>((
  ref,
  params,
) {
  final estado = ref.watch(asistenciaPorEstudianteProvider(params));

  // Solo se permite registrar notas si está presente o justificado
  final estaPermitido =
      estado == EstadoAsistencia.presente ||
      estado == EstadoAsistencia.justificado;

  return !estaPermitido; // true = bloqueado
});
