import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/periodo_model.dart';
import '../controllers/periodos_controller.dart';

final periodoActivoProvider = FutureProvider<Periodo?>((ref) async {
  final controllerAsync = await ref.watch(periodosControllerProvider.future);
  return controllerAsync.periodoActivo;
});
