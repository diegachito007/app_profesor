import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/controllers/periodos_controller.dart';
import '../../data/models/periodo_model.dart';

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
    final nombreController = TextEditingController(text: periodo?.nombre ?? "");
    DateTime? fechaInicio = periodo?.inicio;
    DateTime? fechaFin = periodo?.fin;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => AlertDialog(
            title: Text(periodo == null ? "Agregar Período" : "Editar Período"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _datePicker("Fecha de inicio", fechaInicio, (newDate) {
                  setModalState(() => fechaInicio = newDate);
                }),
                _datePicker("Fecha de fin", fechaFin, (newDate) {
                  setModalState(() => fechaFin = newDate);
                }),
                const SizedBox(height: 12),
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombre del período",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade900,
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text("Cancelar"),
              ),
              FilledButton(
                onPressed: () async {
                  if (nombreController.text.isNotEmpty &&
                      fechaInicio != null &&
                      fechaFin != null) {
                    if (fechaInicio!.isAfter(fechaFin!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "La fecha de inicio no puede ser posterior a la fecha de fin",
                          ),
                        ),
                      );
                      return;
                    }

                    if (periodo == null) {
                      await _controller.agregarPeriodo(
                        nombreController.text,
                        fechaInicio!,
                        fechaFin!,
                      );
                    } else {
                      await _controller.actualizarPeriodo(
                        periodo.id,
                        nombreController.text,
                        fechaInicio!,
                        fechaFin!,
                      );
                    }

                    if (context.mounted) {
                      _cargarPeriodos();
                      Navigator.pop(context);
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text("Guardar"),
              ),
            ],
          ),
        );
      },
    );
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
          child: ListTile(
            leading: const Icon(Icons.date_range, color: Colors.blue),
            title: Text(periodo.nombre),
            subtitle: Text(
              "${DateFormat('dd/MM/yyyy').format(periodo.inicio)} - "
              "${DateFormat('dd/MM/yyyy').format(periodo.fin)} (${periodo.estadoLabel})",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!periodo.activo)
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    tooltip: 'Activar este período',
                    onPressed: () async {
                      await _controller.activarPeriodo(periodo.id);
                      _cargarPeriodos();
                    },
                  )
                else
                  const Icon(Icons.check_circle, color: Colors.green),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _mostrarDialogoPeriodo(periodo: periodo),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _controller.eliminarPeriodo(periodo.id);
                    _cargarPeriodos();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
