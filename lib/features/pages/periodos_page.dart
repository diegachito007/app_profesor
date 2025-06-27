import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/controllers/periodos_controller.dart';
import '../../data/models/periodo_model.dart';
import '../../shared/utils/log_helper.dart';

class PeriodosPage extends StatefulWidget {
  const PeriodosPage({super.key});

  @override
  State<PeriodosPage> createState() => _PeriodosPageState();
}

class _PeriodosPageState extends State<PeriodosPage> {
  final PeriodosController _controller = PeriodosController();
  late Future<List<Periodo>> _periodos;

  @override
  void initState() {
    super.initState();
    _cargarPeriodos();
  }

  void _cargarPeriodos() {
    setState(() {
      _periodos = _controller.cargarPeriodos();
    });
  }

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
                        "Nombre generado: $nombreGenerado",
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
                            setModalState(() {
                              mensajeError = "Selecciona ambas fechas";
                            });
                            return;
                          }
                          if (fechaInicio!.isAfter(fechaFin!)) {
                            setModalState(() {
                              mensajeError =
                                  "La fecha de inicio no puede ser posterior a la fecha final";
                            });
                            return;
                          }

                          setModalState(() {
                            cargando = true;
                            mensajeError = null;
                          });

                          final nombreFinal =
                              '${fechaInicio?.year}-${fechaFin?.year}';

                          try {
                            final existe = await _controller
                                .existeNombrePeriodo(nombreFinal);
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
                              await _controller.agregarPeriodo(
                                nombreFinal,
                                fechaInicio!,
                                fechaFin!,
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                _cargarPeriodos();
                                LogHelper.showSuccess(
                                  context,
                                  "Período creado correctamente",
                                );
                              }
                            } else {
                              await _controller.actualizarPeriodo(
                                periodo.id,
                                nombreFinal,
                                fechaInicio!,
                                fechaFin!,
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                _cargarPeriodos();
                                LogHelper.showSuccess(
                                  context,
                                  "Período actualizado correctamente",
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              LogHelper.showError(
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
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar período?"),
        content: Text(
          "Esta acción eliminará el período '${periodo.nombre}' de forma permanente.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await _controller.eliminarPeriodo(periodo.id);
        _cargarPeriodos();
        if (!mounted) return;
        LogHelper.showSuccess(context, "Período eliminado correctamente");
      } catch (e) {
        if (!mounted) return;
        LogHelper.showError(context, "Error al eliminar período: $e");
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
    return Scaffold(
      appBar: AppBar(title: const Text("Períodos Académicos")),
      body: FutureBuilder<List<Periodo>>(
        future: _periodos,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No existen períodos académicos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }
          return _buildListaPeriodos(snapshot.data!);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogoPeriodo(),
      ),
    );
  }

  Widget _buildListaPeriodos(List<Periodo> periodos) {
    return ListView.builder(
      itemCount: periodos.length,
      itemBuilder: (context, index) {
        final periodo = periodos[index];
        return Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(
              periodo.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Inicio: ${DateFormat('dd/MM/yyyy').format(periodo.inicio)}",
                  ),
                  Text("Fin: ${DateFormat('dd/MM/yyyy').format(periodo.fin)}"),
                  Text(
                    periodo.estadoLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: periodo.activo
                          ? Colors.green
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!periodo.activo)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: 'Activar este período',
                    onPressed: () async {
                      await _controller.activarPeriodo(periodo.id);
                      _cargarPeriodos();
                    },
                  )
                else
                  const IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    onPressed: null,
                    tooltip: 'Período activo',
                  ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar período',
                  onPressed: () => _mostrarDialogoPeriodo(periodo: periodo),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Eliminar período',
                  onPressed: () => _confirmarEliminacion(periodo),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
