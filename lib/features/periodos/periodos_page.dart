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
  String _filtro = ""; // ✅ Variable para el buscador

  @override
  void initState() {
    super.initState();
    _cargarPeriodos();
  }

  Future<void> _cargarPeriodos() async {
    _periodos = _controller.cargarPeriodos();
    setState(() {});
  }

  void _mostrarDialogoPeriodo({Periodo? periodo}) {
    final nombreController = TextEditingController(text: periodo?.nombre ?? "");
    DateTime? fechaInicio = periodo?.inicio;
    DateTime? fechaFin = periodo?.fin;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(periodo == null ? "Agregar Período" : "Editar Período"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            _datePicker(
              "Fecha de inicio",
              fechaInicio,
              (newDate) => setState(() => fechaInicio = newDate),
            ),
            _datePicker(
              "Fecha de fin",
              fechaFin,
              (newDate) => setState(() => fechaFin = newDate),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              if (nombreController.text.isNotEmpty &&
                  fechaInicio != null &&
                  fechaFin != null) {
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
                if (mounted) {
                  setState(() => _periodos = _controller.cargarPeriodos());
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Widget _datePicker(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDatePicked,
  ) {
    return ListTile(
      title: Text(
        "$label: ${selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate) : 'Seleccione'}",
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        DateTime? newDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (newDate != null) {
          onDatePicked(newDate);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Períodos Académicos")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Buscar período académico",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (valor) {
                setState(() {
                  _filtro = valor.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Periodo>>(
              future: _periodos,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No existen períodos académicos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return _buildListaPeriodos(
                  snapshot.data!,
                ); // ✅ Mostramos la lista
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogoPeriodo(),
      ),
    );
  }

  Widget _buildListaPeriodos(List<Periodo> periodos) {
    final periodosFiltrados = periodos
        .where((p) => p.nombre.toLowerCase().contains(_filtro))
        .toList();

    return ListView.builder(
      itemCount: periodosFiltrados.length,
      itemBuilder: (context, index) {
        final periodo = periodosFiltrados[index];
        return Card(
          elevation: 6,
          child: ListTile(
            leading: const Icon(Icons.date_range, color: Colors.blue),
            title: Text(periodo.nombre),
            subtitle: Text(
              "${DateFormat('dd/MM/yyyy').format(periodo.inicio)} - ${DateFormat('dd/MM/yyyy').format(periodo.fin)}",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _mostrarDialogoPeriodo(periodo: periodo),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _controller.eliminarPeriodo(periodo.id);
                    setState(() => _periodos = _controller.cargarPeriodos());
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
