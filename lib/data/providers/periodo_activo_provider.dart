import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../models/periodo_model.dart';
import '../controllers/periodos_controller.dart';

final periodoActivoProvider = Provider<Periodo?>((ref) {
  final periodos = ref.watch(periodosControllerProvider).value ?? [];
  return periodos.firstWhereOrNull((p) => p.activo);
});
