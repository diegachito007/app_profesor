import 'package:flutter/material.dart';

/// 🔍 Diálogo de búsqueda con diseño profesional y botón de limpiar
Future<void> mostrarBuscadorDialog({
  required BuildContext context,
  required String titulo,
  required String filtroActual,
  required void Function(String nuevoFiltro) onFiltroCambiar,
}) async {
  final controller = TextEditingController(text: filtroActual);
  final focusNode = FocusNode();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Escribe para buscar...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          onFiltroCambiar('');
                        },
                      )
                    : null,
              ),
              onChanged: onFiltroCambiar,
              onSubmitted: (_) => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    controller.clear();
                    onFiltroCambiar('');
                  },
                  child: const Text('Limpiar búsqueda'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      onFiltroCambiar('');
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
