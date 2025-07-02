import 'package:flutter/material.dart';

class ShowDialogs {
  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required String entityName, // Ej: 'período'
    required String itemLabel, // Ej: '2024-2025'
    String confirmText = 'Eliminar',
    String cancelText = 'Cancelar',
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Eliminar $entityName'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: '¿Estás seguro de eliminar '),
              TextSpan(
                text: itemLabel,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showArchiveConfirmation({
    required BuildContext context,
    required String entityName,
    required String itemLabel,
    required bool archivar,
  }) {
    final actionText = archivar ? 'Archivar' : 'Restaurar';
    final color = archivar ? Colors.blueGrey : Colors.green;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('$actionText $entityName'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: '¿Deseas $actionText el $entityName '),
              TextSpan(
                text: itemLabel,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}
