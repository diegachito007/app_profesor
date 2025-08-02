import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/snackbar_provider.dart';

class SnackBarAcumulativo extends ConsumerStatefulWidget {
  const SnackBarAcumulativo({super.key});

  @override
  ConsumerState<SnackBarAcumulativo> createState() =>
      _SnackBarAcumulativoState();
}

class _SnackBarAcumulativoState extends ConsumerState<SnackBarAcumulativo> {
  @override
  void didUpdateWidget(covariant SnackBarAcumulativo oldWidget) {
    super.didUpdateWidget(oldWidget);

    final mensajes = ref.read(snackbarProvider);
    if (mensajes.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final mensaje = mensajes.last;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), duration: const Duration(seconds: 2)),
      );
      ref.read(snackbarProvider.notifier).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
