import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔁 Trigger para recargar la lista de temas cuando se agregan, actualizan o eliminan
final temasTriggerProvider = StateProvider<int>((ref) => 0);
