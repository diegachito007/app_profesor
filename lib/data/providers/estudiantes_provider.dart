import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/estudiantes_controller.dart';
import '../models/estudiante_model.dart';

/// Provider para manejar estudiantes por curso
final estudiantesControllerProvider =
    AsyncNotifierProvider.family<EstudiantesController, List<Estudiante>, int>(
      EstudiantesController.new,
    );
