import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/controllers/periodos_controller.dart';
import '../../../data/models/periodo_model.dart';
import '../notificaciones.dart';

Future<void> mostrarDialogoPeriodoForm({
  required BuildContext context,
  required WidgetRef ref,
  Periodo? periodo,
}) async {
  DateTime? fechaInicio = periodo?.inicio;
  DateTime? fechaFin = periodo?.fin;
  bool cargando = false;
  String? mensajeError;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final nombreGenerado = (fechaInicio != null && fechaFin != null)
              ? '${fechaInicio?.year}-${fechaFin?.year}'
              : '';

          return AlertDialog(
            title: Text(periodo == null ? "Agregar Período" : "Editar Período"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _datePicker(context, "Fecha inicio", fechaInicio, (newDate) {
                  setModalState(() => fechaInicio = newDate);
                }),
                _datePicker(context, "Fecha final", fechaFin, (newDate) {
                  setModalState(() => fechaFin = newDate);
                }),
                if (nombreGenerado.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      "Periodo: $nombreGenerado",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                if (mensajeError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      mensajeError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              FilledButton(
                onPressed: cargando
                    ? null
                    : () async {
                        if (fechaInicio == null || fechaFin == null) {
                          setModalState(
                            () => mensajeError = "Selecciona ambas fechas",
                          );
                          return;
                        }
                        if (fechaInicio!.isAfter(fechaFin!)) {
                          setModalState(
                            () => mensajeError =
                                "La fecha de inicio no puede ser posterior a la fecha final.",
                          );
                          return;
                        }

                        setModalState(() {
                          cargando = true;
                          mensajeError = null;
                        });

                        final nombreFinal =
                            '${fechaInicio?.year}-${fechaFin?.year}';
                        final controller = ref.read(
                          periodosControllerProvider.notifier,
                        );

                        try {
                          final existe = await controller.existeNombrePeriodo(
                            nombreFinal,
                          );
                          if (existe &&
                              (periodo == null ||
                                  nombreFinal != periodo.nombre)) {
                            setModalState(() {
                              mensajeError =
                                  "Ya existe un período con ese rango de años.";
                              cargando = false;
                            });
                            return;
                          }

                          if (periodo == null) {
                            await controller.agregarPeriodo(
                              nombreFinal,
                              fechaInicio!,
                              fechaFin!,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              Notificaciones.showSuccess(
                                context,
                                "Período creado correctamente",
                              );
                            }
                          } else {
                            await controller.actualizarPeriodo(
                              periodo.id,
                              nombreFinal,
                              fechaInicio!,
                              fechaFin!,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              Notificaciones.showSuccess(
                                context,
                                "Período actualizado correctamente",
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            Notificaciones.showError(
                              context,
                              "Error al guardar: $e",
                            );
                          }
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
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
                    : const Text("Guardar"),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _datePicker(
  BuildContext context,
  String label,
  DateTime? selectedDate,
  Function(DateTime) onDatePicked,
) {
  return GestureDetector(
    onTap: () async {
      final newDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (newDate != null) {
        onDatePicked(newDate);
      }
    },
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$label: ${selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate) : 'Seleccione'}",
        style: const TextStyle(fontSize: 14),
      ),
    ),
  );
}
