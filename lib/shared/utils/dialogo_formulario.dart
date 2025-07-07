import 'package:flutter/material.dart';

class DialogoFormulario extends StatelessWidget {
  final String titulo;
  final Widget contenido;
  final bool barrierDismissible;

  const DialogoFormulario({
    super.key,
    required this.titulo,
    required this.contenido,
    this.barrierDismissible = false,
  });

  static Future<void> mostrar({
    required BuildContext context,
    required String titulo,
    required Widget contenido,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => DialogoFormulario(
        titulo: titulo,
        contenido: contenido,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              contenido,
            ],
          ),
        ),
      ),
    );
  }
}
