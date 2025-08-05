import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔄 Trigger para actualizar el estado local de notas
final notasTriggerProvider = StateProvider<int>((ref) => 0);
