import 'package:flutter_riverpod/flutter_riverpod.dart';

final materiasCursoTriggerProvider = StateProvider.family<int, int>(
  (ref, cursoId) => 0,
);
