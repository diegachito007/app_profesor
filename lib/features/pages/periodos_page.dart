import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/controllers/cursos_controller.dart';
import '../../data/controllers/periodos_controller.dart';
import '../../data/models/periodo_model.dart';
import '../../shared/utils/notificaciones.dart';
import '../../shared/utils/showdialogs.dart'; // ✅ Importación añadida

class PeriodosPage extends ConsumerStatefulWidget {
  const PeriodosPage({super.key});

  @override
  ConsumerState<PeriodosPage> createState() => _PeriodosPageState();
}

class _PeriodosPageState extends ConsumerState<PeriodosPage> {
  String _filtro = '';

  void _mostrarDialogoPeriodo({Periodo? periodo}) {
    DateTime? fechaInicio = periodo?.inicio;
    DateTime? fechaFin = periodo?.fin;
    bool cargando = false;
    String? mensajeError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final nombreGenerado = (fechaInicio != null && fechaFin != null)
                ? '${fechaInicio?.year}-${fechaFin?.year}'
                : '';

            return AlertDialog(
              title: Text(
                periodo == null ? "Agregar Período" : "Editar Período",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _datePicker("Fecha inicio", fechaInicio, (newDate) {
                    setModalState(() => fechaInicio = newDate);
                  }),
                  _datePicker("Fecha final", fechaFin, (newDate) {
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

  Future<void> _confirmarEliminacion(Periodo periodo) async {
    final confirmado = await ShowDialogs.showDeleteConfirmation(
      context: context,
      entityName: 'período',
      itemLabel: periodo.nombre,
    );

    if (confirmado == true) {
      try {
        final controller = ref.read(periodosControllerProvider.notifier);
        await controller.eliminarPeriodo(periodo.id);
        if (!mounted) return;
        Notificaciones.showSuccess(context, "Período eliminado correctamente");
      } catch (e) {
        if (!mounted) return;
        Notificaciones.showError(context, "Error al eliminar período: $e");
      }
    }
  }

  Widget _datePicker(
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

  @override
  Widget build(BuildContext context) {
    final periodosAsync = ref.watch(periodosControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Períodos Académicos")),
      body: periodosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (periodos) {
          final controller = ref.read(periodosControllerProvider.notifier);

          if (periodos.isEmpty) {
            return const Center(
              child: Text(
                'No se encontraron períodos.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final filtrados = periodos
              .where(
                (p) => p.nombre.toLowerCase().contains(_filtro.toLowerCase()),
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar período...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => setState(() => _filtro = value),
                ),
              ),
              if (filtrados.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No se encontraron períodos.')),
                ),
              ...filtrados.map((p) => _buildPeriodoTile(p, controller)),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Acción de exportar
              },
              icon: const Icon(Icons.file_download),
              label: const Text('Exportar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _mostrarDialogoPeriodo(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodoTile(Periodo periodo, PeriodosController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.03 * 255).round()),
              blurRadius: 3,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              periodo.nombre,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text("Inicio: ${DateFormat('dd/MM/yyyy').format(periodo.inicio)}"),
            Text("Fin: ${DateFormat('dd/MM/yyyy').format(periodo.fin)}"),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  periodo.estadoLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: periodo.activo ? Colors.green : Colors.grey.shade700,
                  ),
                ),
                Row(
                  children: [
                    if (!periodo.activo)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        tooltip: 'Activar este período',
                        onPressed: () async {
                          await controller.activarPeriodo(periodo.id);
                          ref.invalidate(cursosControllerProvider);
                        },
                      )
                    else
                      const IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        onPressed: null,
                        tooltip: 'Período activo',
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      tooltip: 'Editar período',
                      onPressed: () => _mostrarDialogoPeriodo(periodo: periodo),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'Eliminar período',
                      onPressed: () => _confirmarEliminacion(periodo),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
