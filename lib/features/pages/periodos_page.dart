import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/controllers/cursos_controller.dart';
import '../../data/controllers/periodos_controller.dart';
import '../../data/models/periodo_model.dart';
import '../../shared/utils/notificaciones.dart';
import '../../shared/utils/dialogo_confirmacion.dart';

class PeriodosPage extends ConsumerStatefulWidget {
  const PeriodosPage({super.key});

  @override
  ConsumerState<PeriodosPage> createState() => _PeriodosPageState();
}

class _PeriodosPageState extends ConsumerState<PeriodosPage> {
  String _filtro = '';
  final TextEditingController _buscadorController = TextEditingController();
  final FocusNode _buscadorFocus = FocusNode();

  @override
  void dispose() {
    _buscadorController.dispose();
    _buscadorFocus.dispose();
    super.dispose();
  }

  Future<void> _confirmarEliminacion(Periodo periodo) async {
    final confirmado = await mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Eliminar período',
      mensaje:
          '¿Estás seguro de que deseas eliminar el período "${periodo.nombre}"?',
      textoConfirmar: 'Eliminar',
      colorConfirmar: Colors.redAccent,
      icono: Icons.warning_amber_rounded,
    );

    if (confirmado) {
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

  void _mostrarFormulario({Periodo? periodo}) {
    _buscadorFocus.unfocus();

    final controller = ref.read(periodosControllerProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _FormularioPeriodo(
          periodo: periodo,
          onGuardar: (nombre, inicio, fin) async {
            if (periodo == null) {
              await controller.agregarPeriodo(nombre, inicio, fin);
            } else {
              await controller.actualizarPeriodo(
                periodo.id,
                nombre,
                inicio,
                fin,
              );
            }
          },
          onCerrarDialogo: () {
            _buscadorFocus.unfocus();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodosAsync = ref.watch(periodosControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco puro
      appBar: AppBar(title: const Text("Períodos")),
      body: periodosAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (periodos) {
          final controller = ref.read(periodosControllerProvider.notifier);
          final filtrados = periodos
              .where(
                (p) => p.nombre.toLowerCase().contains(_filtro.toLowerCase()),
              )
              .toList();

          return Column(
            children: [
              // 🔍 Buscador sin sombra
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _buscadorController,
                  focusNode: _buscadorFocus,
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

              // 📋 Lista scrollable
              Expanded(
                child: filtrados.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No se encontraron períodos.'),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filtrados.length,
                        itemBuilder: (_, index) =>
                            _buildPeriodoTile(filtrados[index], controller),
                      ),
              ),
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
            ),
            ElevatedButton.icon(
              onPressed: () => _mostrarFormulario(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
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
              color: Colors.black.withAlpha(8),
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
                      onPressed: () => _mostrarFormulario(periodo: periodo),
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

class _FormularioPeriodo extends ConsumerStatefulWidget {
  final Periodo? periodo;
  final Future<void> Function(String nombre, DateTime inicio, DateTime fin)
  onGuardar;
  final VoidCallback onCerrarDialogo;

  const _FormularioPeriodo({
    required this.onGuardar,
    required this.onCerrarDialogo,
    this.periodo,
  });

  @override
  ConsumerState<_FormularioPeriodo> createState() => _FormularioPeriodoState();
}

class _FormularioPeriodoState extends ConsumerState<_FormularioPeriodo> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _inicio;
  DateTime? _fin;

  String? _errorInicio;
  String? _errorFin;
  String? _errorLogico;

  @override
  void initState() {
    super.initState();
    _inicio = widget.periodo?.inicio;
    _fin = widget.periodo?.fin;
  }

  Future<void> _seleccionarFecha(bool esInicio) async {
    final seleccionada = await showDatePicker(
      context: context,
      locale: const Locale('es'),
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (seleccionada != null) {
      setState(() {
        if (esInicio) {
          _inicio = seleccionada;
          _errorInicio = null;
        } else {
          _fin = seleccionada;
          _errorFin = null;
        }
        _errorLogico = null;
      });
    }
  }

  String get _nombreGenerado {
    if (_inicio != null && _fin != null) {
      return '${_inicio!.year}-${_fin!.year}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.periodo != null ? 'Editar período' : 'Nuevo período',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFechaCampo(
                    label: 'Fecha de inicio',
                    fecha: _inicio,
                    error: _errorInicio,
                    onTap: () => _seleccionarFecha(true),
                  ),
                  _buildFechaCampo(
                    label: 'Fecha de fin',
                    fecha: _fin,
                    error: _errorFin,
                    onTap: () => _seleccionarFecha(false),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nombre generado:',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _nombreGenerado.isNotEmpty ? _nombreGenerado : '—',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (_errorLogico != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Card(
                        color: Colors.orange.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.orange.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorLogico!,
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.onCerrarDialogo,
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _errorInicio = _inicio == null
                                ? 'Campo obligatorio'
                                : null;
                            _errorFin = _fin == null
                                ? 'Campo obligatorio'
                                : null;
                            _errorLogico = null;
                          });

                          if (_inicio == null || _fin == null) return;

                          if (_fin!.isBefore(_inicio!)) {
                            setState(() {
                              _errorLogico =
                                  'La fecha de fin no puede ser anterior a la de inicio';
                            });
                            return;
                          }

                          final nombreGenerado = _nombreGenerado;
                          final controller = ref.read(
                            periodosControllerProvider.notifier,
                          );
                          final existe = await controller.existeNombrePeriodo(
                            nombreGenerado,
                          );
                          if (!mounted) return;

                          if (existe && widget.periodo == null) {
                            setState(() {
                              _errorLogico =
                                  'Ya existe un período con ese nombre';
                            });
                            return;
                          }

                          await widget.onGuardar(
                            nombreGenerado,
                            _inicio!,
                            _fin!,
                          );
                          widget.onCerrarDialogo();
                        },
                        child: Text(
                          widget.periodo != null ? 'Actualizar' : 'Guardar',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFechaCampo({
    required String label,
    required DateTime? fecha,
    required String? error,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: error != null ? Colors.red : Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  fecha != null
                      ? DateFormat('dd/MM/yyyy').format(fecha)
                      : 'Seleccionar',
                  style: TextStyle(
                    fontSize: 16,
                    color: fecha != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
