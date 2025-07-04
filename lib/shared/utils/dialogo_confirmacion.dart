import 'package:flutter/material.dart';

Future<bool> mostrarDialogoConfirmacion({
  required BuildContext context,
  required String titulo,
  required String mensaje,
  required String textoConfirmar,
  required Color colorConfirmar,
  IconData? icono,
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          if (icono != null) ...[
            Icon(icono, color: colorConfirmar),
            const SizedBox(width: 8),
          ],
          Text(titulo),
        ],
      ),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: colorConfirmar),
          onPressed: () => Navigator.pop(context, true),
          child: Text(textoConfirmar),
        ),
      ],
    ),
  );

  return resultado ?? false;
}
