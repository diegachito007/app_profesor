import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/controllers/notas_controller.dart';
import '../../data/providers/asistencias_provider.dart';
import '../../data/controllers/notas_tipo_controller.dart';
import '../../data/models/nota_tipo_model.dart';
import '../../data/models/tema_nota.dart';
import '../../shared/utils/texto_normalizado.dart';
import '../../shared/utils/horas.dart';
import '../../data/controllers/asistencias_controller.dart';
import '../../data/providers/bloqueo_notas_provider.dart';

// 🔧 Helper para íconos por tipo
String obtenerIcono(String tipoNombre) {
  const mapa = {
    'Tareas': '📝',
    'Lecciones': '📘',
    'Trabajo Grupal': '👥',
    'Trabajo Individual': '👤',
    'Evaluaciones': '📊',
    'Examen Acumulativo': '🧪',
    'Supletorio': '🛠️',
    'Proyecto Interdisciplinario': '📂',
    'Participación': '💬',
  };

  return mapa[tipoNombre] ?? '📄'; // Ícono genérico si no está definido
}

final temaSeleccionadoProvider = StateProvider<TemaNota?>((ref) => null);

class NotaEditorDialog extends StatefulWidget {
  final double? notaActual;
  final String? detalleActual;
  final void Function(double nota, String? detalle) onGuardar;

  const NotaEditorDialog({
    super.key,
    this.notaActual,
    this.detalleActual,
    required this.onGuardar,
  });

  @override
  State<NotaEditorDialog> createState() => _NotaEditorDialogState();
}

class _NotaEditorDialogState extends State<NotaEditorDialog> {
  final TextEditingController _notaController = TextEditingController();
  final TextEditingController _detalleController = TextEditingController();
  final FocusNode _notaFocusNode = FocusNode();
  final FocusNode _detalleFocusNode = FocusNode();

  String? _observacionSeleccionada;
  String? _detalleError;
  String? _chipError;

  @override
  void initState() {
    super.initState();
    _notaController.text = widget.notaActual?.toString() ?? '';
    _detalleController.text = widget.detalleActual ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_notaFocusNode);
      }
    });
  }

  @override
  void dispose() {
    _notaController.dispose();
    _detalleController.dispose();
    _notaFocusNode.dispose();
    _detalleFocusNode.dispose();
    super.dispose();
  }

  void _guardar() {
    final nota = double.tryParse(_notaController.text.trim()) ?? 0.0;

    if (nota < 7) {
      if (_observacionSeleccionada == null) {
        setState(() {
          _chipError = 'Debes seleccionar una observación';
        });
        return;
      }

      if (_observacionSeleccionada == 'Otro') {
        final detalle = _detalleController.text.trim();
        if (detalle.length < 3) {
          setState(() {
            _detalleError = 'Este campo es requerido';
            _chipError = null;
          });
          return;
        }
      }
    }

    final detalle = _observacionSeleccionada == 'Otro'
        ? _detalleController.text.trim()
        : _observacionSeleccionada;

    widget.onGuardar(nota, detalle?.isEmpty ?? true ? null : detalle);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editar nota',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notaController,
              focusNode: _notaFocusNode,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nota',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Observación',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ['No presenta', 'Incompleto', 'Otro'].map((opcion) {
                final bool seleccionado = _observacionSeleccionada == opcion;

                Color borderColor;
                if (!seleccionado) {
                  borderColor = Colors.grey.shade300;
                } else if (opcion == 'No presenta') {
                  borderColor = Colors.red;
                } else if (opcion == 'Incompleto') {
                  borderColor = Colors.amber;
                } else {
                  borderColor = Colors.blue;
                }

                return ChoiceChip(
                  label: Text(opcion),
                  selected: seleccionado,
                  onSelected: (_) {
                    setState(() {
                      _observacionSeleccionada = opcion;
                      _detalleError = null;
                      _chipError = null;
                      if (opcion != 'Otro') {
                        _detalleController.clear();
                      }
                    });
                  },
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: borderColor, width: 1.0),
                  ),
                  labelStyle: const TextStyle(fontSize: 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                );
              }).toList(),
            ),
            if (_chipError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _chipError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (_observacionSeleccionada == 'Otro') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _detalleController,
                focusNode: _detalleFocusNode,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Detalle',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  errorText: _detalleError,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NotasSection extends ConsumerStatefulWidget {
  final int cursoId;
  final int materiaCursoId;
  final int hora;
  final DateTime fecha;

  const NotasSection({
    super.key,
    required this.cursoId,
    required this.materiaCursoId,
    required this.hora,
    required this.fecha,
  });

  @override
  ConsumerState<NotasSection> createState() => _NotasSectionState();
}

class _NotasSectionState extends ConsumerState<NotasSection> {
  TemaNota? temaSeleccionado;
  final List<TemaNota> temas = [];

  String get fechaTexto =>
      normalizarFecha(widget.fecha).toIso8601String().substring(0, 10);

  NotasParams get notasParams => NotasParams(
    cursoId: widget.cursoId,
    materiaCursoId: widget.materiaCursoId,
    hora: widget.hora,
    fecha: fechaTexto,
    temaCodigo: temaSeleccionado?.codigo ?? '',
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // ✅ Carga inicial de estudiantes sin tema
      await ref.read(
        notasControllerProvider(
          NotasParams(
            cursoId: widget.cursoId,
            materiaCursoId: widget.materiaCursoId,
            hora: widget.hora,
            fecha: fechaTexto,
            temaCodigo: '', // sin tema aún
          ),
        ).future,
      );

      await cargarTemasIniciales();
    });
  }

  Future<void> cargarTemasIniciales() async {
    final temasDelBloque = await ref
        .read(notasControllerProvider(notasParams).notifier)
        .obtenerTemasDelBloque(
          materiaCursoId: widget.materiaCursoId,
          hora: widget.hora,
          fecha: fechaTexto,
        );

    if (mounted) {
      setState(() {
        temas.clear();
        temas.addAll(temasDelBloque);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final estudiantesAsync = ref.watch(notasControllerProvider(notasParams));
    final tiposAsync = ref.watch(notasTipoControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tiposAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error al cargar tipos: $e'),
          data: (tipos) => Wrap(
            spacing: 8,
            children: [
              ...temas.map((tema) {
                final seleccionadoChip =
                    temaSeleccionado?.codigo == tema.codigo;
                return ChoiceChip(
                  selected: seleccionadoChip,
                  onSelected: (_) {
                    setState(() => temaSeleccionado = tema);
                    ref.read(temaSeleccionadoProvider.notifier).state = tema;

                    final params = NotasParams(
                      cursoId: widget.cursoId,
                      materiaCursoId: widget.materiaCursoId,
                      hora: widget.hora,
                      fecha: fechaTexto,
                      temaCodigo: tema.codigo,
                    );

                    ref.invalidate(notasControllerProvider(params));
                  },
                  label: Text(
                    tema.codigo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }),
              ActionChip(
                label: const Text('+'),
                onPressed: () => mostrarDialogoAgregarTema(
                  context,
                  tipos,
                  temas,
                  (nuevoTema) {
                    setState(() {
                      temas.add(nuevoTema);
                      temaSeleccionado = nuevoTema;
                      ref.read(temaSeleccionadoProvider.notifier).state =
                          nuevoTema;

                      ref.invalidate(
                        notasControllerProvider(
                          NotasParams(
                            cursoId: widget.cursoId,
                            materiaCursoId: widget.materiaCursoId,
                            hora: widget.hora,
                            fecha: fechaTexto,
                            temaCodigo: nuevoTema.codigo,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        if (temaSeleccionado == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    temas.isEmpty
                        ? 'No hay temas disponibles. Agrega uno para comenzar.'
                        : 'Selecciona un tema para ver y editar las notas.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (temaSeleccionado != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: tiposAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (tipos) {
                final tipo = tipos.firstWhere(
                  (t) => t.id == temaSeleccionado!.tipo.id,
                  orElse: () => NotaTipoModel(
                    id: 0,
                    nombre: 'Tipo desconocido',
                    prefijo: '',
                    activo: true,
                    createdAt: DateTime.now().toIso8601String(),
                  ),
                );

                final icono = obtenerIcono(tipo.nombre);

                return Text(
                  '$icono ${tipo.nombre}: ${temaSeleccionado!.descripcion}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo,
                  ),
                );
              },
            ),
          ),
        estudiantesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error al cargar estudiantes: $e'),
          data: (estudiantes) => Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: estudiantes.length,
              itemBuilder: (_, index) {
                final item = estudiantes[index];
                final est = item.estudiante;
                final notaIntento1 = item.notasIntento1?.nota;
                final detalleIntento1 = item.notasIntento1?.detalle;

                final asistenciaParams = AsistenciaParamsEstudiante(
                  bloqueParams: AsistenciasParams(
                    cursoId: widget.cursoId,
                    materiaCursoId: widget.materiaCursoId,
                    hora: widget.hora,
                    fecha: fechaTexto,
                  ),
                  estudianteId: est.id,
                );

                final bloqueado = ref.watch(
                  bloqueoNotasProvider(asistenciaParams),
                );

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: bloqueado
                          ? Colors.redAccent.withAlpha(100)
                          : Colors.green.withAlpha(100),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(25),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          capitalizarConTildes(est.apellido),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          capitalizarConTildes(est.nombre),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    trailing: bloqueado
                        ? const Icon(Icons.lock, color: Colors.redAccent)
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            icon: const Icon(Icons.edit, size: 18),
                            label: Text(
                              temaSeleccionado == null
                                  ? 'Nota'
                                  : (notaIntento1 != null
                                        ? 'Editar (${notaIntento1.toStringAsFixed(1)})'
                                        : 'Nota'),
                              style: const TextStyle(fontSize: 13),
                            ),
                            onPressed: () {
                              if (temaSeleccionado == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '⚠️ Debes seleccionar un tema antes de registrar notas',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              showDialog(
                                context: context,
                                builder: (_) => NotaEditorDialog(
                                  notaActual: notaIntento1,
                                  detalleActual: detalleIntento1,
                                  onGuardar: (notaNueva, detalleNuevo) async {
                                    await ref
                                        .read(
                                          notasControllerProvider(
                                            notasParams,
                                          ).notifier,
                                        )
                                        .actualizarIntento(
                                          estudianteId: est.id,
                                          nota: notaNueva,
                                          detalle: detalleNuevo,
                                          fecha: widget.fecha,
                                          hora: notasParams.hora,
                                          materiaCursoId:
                                              notasParams.materiaCursoId,
                                          codigoNotaTema: temaSeleccionado!
                                              .codigo
                                              .trim(),
                                          intento: 1,
                                        );

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '✅ Nota actualizada para ${est.nombre}',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    ref.invalidate(
                                      notasControllerProvider(notasParams),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void mostrarDialogoAgregarTema(
    BuildContext context,
    List<NotaTipoModel> tipos,
    List<TemaNota> temas,
    ValueChanged<TemaNota> onTemaAgregado,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        NotaTipoModel? tipoDialogo;
        bool mostrarErrorTipo = false;
        String? errorLogico;

        final temaDialogoController = TextEditingController();
        final formKey = GlobalKey<FormState>();

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Agregar tema',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tipos.map((tipo) {
                      final seleccionado = tipoDialogo?.id == tipo.id;
                      final borderColor = seleccionado
                          ? Colors.blue
                          : Colors.grey.shade300;

                      return ChoiceChip(
                        label: Text(
                          tipo.prefijo,
                          style: TextStyle(
                            color: seleccionado ? Colors.blue : Colors.black,
                            fontWeight: seleccionado
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: seleccionado,
                        onSelected: (_) {
                          setState(() {
                            tipoDialogo = tipo;
                            mostrarErrorTipo = false;
                            errorLogico = null;
                          });
                        },
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(color: borderColor, width: 1.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      );
                    }).toList(),
                  ),
                  if (tipoDialogo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${tipoDialogo!.prefijo}: ${tipoDialogo!.nombre}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  if (mostrarErrorTipo && tipoDialogo == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Debes seleccionar un tipo de nota',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: temaDialogoController,
                      maxLines: 2,
                      minLines: 1,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obligatorio';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tema',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (errorLogico != null)
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
                                  errorLogico!,
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
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final valido =
                              formKey.currentState?.validate() ?? false;
                          if (!valido) return;

                          if (tipoDialogo == null) {
                            setState(() => mostrarErrorTipo = true);
                            return;
                          }

                          final tema = capitalizarTituloConTildes(
                            temaDialogoController.text.trim(),
                          );
                          final temaDuplicado = temas.any(
                            (t) =>
                                t.descripcion.toLowerCase().trim() ==
                                tema.toLowerCase().trim(),
                          );

                          if (temaDuplicado) {
                            setState(
                              () => errorLogico = 'Este tema ya fue registrado',
                            );
                            return;
                          }

                          final nuevoTema = await ref
                              .read(
                                notasControllerProvider(
                                  NotasParams(
                                    cursoId: widget.cursoId,
                                    materiaCursoId: widget.materiaCursoId,
                                    hora: widget.hora,
                                    fecha: fechaTexto,
                                    temaCodigo: '',
                                  ),
                                ).notifier,
                              )
                              .crearTemaYNotasIniciales(
                                cursoId: widget.cursoId,
                                materiaCursoId: widget.materiaCursoId,
                                hora: widget.hora,
                                fecha: widget.fecha,
                                temaNombre: tema,
                                tipo: tipoDialogo!,
                              );

                          onTemaAgregado(nuevoTema);

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '✅ Tema creado: ${nuevoTema.codigo} – ${nuevoTema.descripcion}',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: const Text('Agregar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
