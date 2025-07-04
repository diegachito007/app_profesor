import 'package:flutter/material.dart';
import '../../shared/theme/dialog_styles.dart';

class ShowDialogs {
  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required String entityName,
    required String itemLabel,
    String confirmText = 'Eliminar',
    String cancelText = 'Cancelar',
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: DialogStyles.dialogShape,
        title: Text('Eliminar $entityName', style: DialogStyles.titleTextStyle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: bodyStyle,
                children: [
                  const TextSpan(text: '¿Estás seguro de eliminar '),
                  TextSpan(
                    text: itemLabel,
                    style: bodyStyle?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: DialogStyles.actionsPadding,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              textStyle: DialogStyles.buttonTextStyle,
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
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: DialogStyles.dialogShape,
        title: Text(
          '$actionText $entityName',
          style: DialogStyles.titleTextStyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: bodyStyle,
                children: [
                  TextSpan(text: '¿Deseas $actionText el $entityName '),
                  TextSpan(
                    text: itemLabel,
                    style: bodyStyle?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: DialogStyles.actionsPadding,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              textStyle: DialogStyles.buttonTextStyle,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  static Future<void> showSimpleFormDialog({
    required BuildContext context,
    required String title,
    required Widget Function(void Function(void Function())) buildContent,
    required Future<void> Function(void Function(String? mensaje)) onSubmit,
    String confirmText = 'Guardar',
    String cancelText = 'Cancelar',
    Color confirmColor = const Color(0xFF1565C0),
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        String? mensajeError;
        bool cargando = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: DialogStyles.dialogShape,
              title: Text(title, style: DialogStyles.titleTextStyle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildContent(setState),
                  if (mensajeError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        width: double.infinity,
                        decoration: DialogStyles.errorCardDecoration,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                mensajeError!,
                                style: DialogStyles.errorTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              actionsPadding: DialogStyles.actionsPadding,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(cancelText),
                ),
                FilledButton(
                  onPressed: cargando
                      ? null
                      : () async {
                          setState(() {
                            cargando = true;
                            mensajeError = null;
                          });

                          await onSubmit((mensaje) {
                            setState(() {
                              mensajeError = mensaje;
                              cargando = false;
                            });
                          });

                          if (context.mounted && mensajeError == null) {
                            Navigator.pop(context);
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: confirmColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    textStyle: DialogStyles.buttonTextStyle,
                  ),
                  child: cargando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(confirmText),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
