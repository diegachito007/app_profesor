import 'package:flutter_riverpod/flutter_riverpod.dart';

final snackbarProvider = StateNotifierProvider<SnackbarNotifier, List<String>>(
  (ref) => SnackbarNotifier(),
);

class SnackbarNotifier extends StateNotifier<List<String>> {
  SnackbarNotifier() : super([]);

  void add(String mensaje) {
    state = [...state, mensaje];
  }

  void clear() {
    state = [];
  }
}
