import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/jornada_model.dart';
import '../controllers/jornadas_controller.dart';

final jornadasControllerProvider =
    AsyncNotifierProvider.family<JornadasController, List<JornadaModel>, int>(
      JornadasController.new,
    );
