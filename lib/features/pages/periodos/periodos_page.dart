import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/controllers/cursos_controller.dart';
import '../../../data/controllers/periodos_controller.dart';
import '../../../data/models/periodo_model.dart';
import '../../../shared/utils/notificaciones.dart';

class PeriodosPage extends ConsumerStatefulWidget {
  const PeriodosPage({super.key});

  @override
  ConsumerState<PeriodosPage> createState() => _PeriodosPageState();
}

class _PeriodosPageState extends ConsumerState<PeriodosPage> {
  void _mostrarFormulario({Periodo? periodo}) {
    final controller = ref.read(periodosControllerProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
            onCerrarDialogo: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarEliminacion(Periodo periodo) async {
    final confirmado =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Eliminar período'),
            content: Text(
              '¿Estás seguro de eliminar el período ${periodo.nombre}?\n\n'
              'Esta acción es permanente y no se puede deshacer.',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!context.mounted || !confirmado) return;

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

  @override
  Widget build(BuildContext context) {
    final periodosAsync = ref.watch(periodosControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Períodos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: periodosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (periodos) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${periodos.length} período${periodos.length == 1 ? '' : 's'} registrado${periodos.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xFF1565C0),
                        size: 28,
                      ),
                      tooltip: 'Agregar período',
                      onPressed: () => _mostrarFormulario(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: periodos.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No se encontraron períodos.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: periodos.length,
                        itemBuilder: (_, index) =>
                            _buildPeriodoCard(context, ref, periodos[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodoCard(
    BuildContext context,
    WidgetRef ref,
    Periodo periodo,
  ) {
    final bool esActivo = periodo.activo;
    final Color fondo = esActivo ? Colors.green.shade50 : Colors.white;
    final Color borde = esActivo ? Colors.green.shade200 : Colors.blue.shade100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borde),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  periodo.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Inicio: ${DateFormat('dd/MM/yyyy').format(periodo.inicio)}",
                ),
                Text("Fin: ${DateFormat('dd/MM/yyyy').format(periodo.fin)}"),
                const SizedBox(height: 6),
                Text(
                  periodo.estadoLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: esActivo ? Colors.green : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _mostrarMenuPeriodo(context, ref, periodo),
          ),
        ],
      ),
    );
  }

  void _mostrarMenuPeriodo(
    BuildContext context,
    WidgetRef ref,
    Periodo periodo,
  ) {
    final controller = ref.read(periodosControllerProvider.notifier);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!periodo.activo)
              ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                title: const Text('Activar período'),
                onTap: () async {
                  Navigator.pop(context);
                  await controller.activarPeriodo(periodo.id);
                  if (!context.mounted) return;
                  ref.invalidate(cursosControllerProvider);
                  Notificaciones.showSuccess(context, 'Período activado');
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
              title: const Text('Editar período'),
              onTap: () {
                Navigator.pop(context);
                _mostrarFormulario(periodo: periodo);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: const Text('Eliminar período'),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminacion(periodo);
              },
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
  bool _activo = false;

  @override
  void initState() {
    super.initState();
    _inicio = widget.periodo?.inicio;
    _fin = widget.periodo?.fin;
    _activo = widget.periodo?.activo ?? false;
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
    final controller = ref.read(periodosControllerProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.periodo != null ? 'Editar período' : 'Nuevo período',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 20),
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
              Text(
                'Nombre generado:',
                style: TextStyle(color: Colors.grey.shade700),
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
              if (widget.periodo != null)
                SwitchListTile(
                  title: const Text('Activar período'),
                  value: _activo,
                  onChanged: (value) => setState(() => _activo = value),
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
                        _errorFin = _fin == null ? 'Campo obligatorio' : null;
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
                      final existe = await controller.existeNombrePeriodo(
                        nombreGenerado,
                      );
                      if (!mounted) return;

                      if (existe && widget.periodo == null) {
                        setState(() {
                          _errorLogico = 'Ya existe un período con ese nombre';
                        });
                        return;
                      }

                      await widget.onGuardar(nombreGenerado, _inicio!, _fin!);

                      if (widget.periodo != null && _activo) {
                        await controller.activarPeriodo(widget.periodo!.id);
                        ref.invalidate(cursosControllerProvider);
                      }

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
