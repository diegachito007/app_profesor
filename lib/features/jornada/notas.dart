import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/controllers/notas_controller.dart';
import '../../data/providers/asistencias_provider.dart';
import '../../data/controllers/notas_tipo_controller.dart';
import '../../data/models/nota_tipo_model.dart';
import '../../shared/utils/texto_normalizado.dart';
import '../../shared/utils/horas.dart';
import '../../data/controllers/asistencias_controller.dart';
import '../../data/providers/bloqueo_notas_provider.dart';

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

class TemaNota {
  final String codigo;
  final String descripcion;
  final NotaTipoModel tipo;

  TemaNota({
    required this.codigo,
    required this.descripcion,
    required this.tipo,
  });
}

class _NotasSectionState extends ConsumerState<NotasSection> {
  EstudianteConEstado? seleccionado;
  TemaNota? temaSeleccionado;
  final notaControllerFinal = TextEditingController();
  final List<TemaNota> temas = [];

  void mostrarDialogoAgregarTema(
    BuildContext context,
    List<NotaTipoModel> tipos,
  ) {
    final formKey = GlobalKey<FormState>();
    final temaDialogoController = TextEditingController();
    NotaTipoModel? tipoDialogo;
    String? errorLogico;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar nuevo tema'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tipos.map((tipo) {
                      final seleccionado = tipoDialogo?.id == tipo.id;
                      return ChoiceChip(
                        label: Text(
                          tipo.prefijo,
                          style: TextStyle(
                            color: seleccionado ? Colors.indigo : Colors.black,
                            fontWeight: seleccionado
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: seleccionado,
                        onSelected: (_) {
                          setStateDialog(() {
                            tipoDialogo = tipo;
                            errorLogico = null;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.white,
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),
                  if (tipoDialogo != null)
                    Text(
                      tipoDialogo!.nombre,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
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
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final valido = formKey.currentState?.validate() ?? false;
                  if (!valido) return;

                  if (tipoDialogo == null) {
                    errorLogico = 'Debes seleccionar un tipo de nota';
                    (context as Element).markNeedsBuild();
                    return;
                  }

                  final tema = temaDialogoController.text.trim();
                  final fechaTexto = normalizarFecha(
                    widget.fecha,
                  ).toIso8601String().substring(0, 10);
                  final params = NotasParams(
                    cursoId: widget.cursoId,
                    materiaCursoId: widget.materiaCursoId,
                    hora: widget.hora,
                    fecha: fechaTexto,
                  );

                  final codigo = await ref
                      .read(notasControllerProvider(params).notifier)
                      .generarCodigoNotaTema(
                        tipoAbreviado: tipoDialogo!.prefijo,
                        materiaCursoId: widget.materiaCursoId,
                        notaTipoId: tipoDialogo!.id!,
                      );

                  if (!context.mounted) return;

                  setState(() {
                    final nuevoTema = TemaNota(
                      codigo: codigo,
                      descripcion: tema,
                      tipo: tipoDialogo!,
                    );
                    temas.add(nuevoTema);
                    temaSeleccionado = nuevoTema;
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Tema agregado: $codigo'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Agregar'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fechaTexto = normalizarFecha(
      widget.fecha,
    ).toIso8601String().substring(0, 10);
    final params = NotasParams(
      cursoId: widget.cursoId,
      materiaCursoId: widget.materiaCursoId,
      hora: widget.hora,
      fecha: fechaTexto,
    );

    final estudiantesAsync = ref.watch(notasControllerProvider(params));
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
                  label: Text(tema.codigo),
                  selected: seleccionadoChip,
                  onSelected: (_) {
                    setState(() => temaSeleccionado = tema);
                  },
                );
              }),
              ActionChip(
                label: const Text('+'),
                onPressed: () => mostrarDialogoAgregarTema(context, tipos),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 6,
                  ),
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
                            label: const Text(
                              'Nota',
                              style: TextStyle(fontSize: 13),
                            ),
                            onPressed: () =>
                                setState(() => seleccionado = item),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (seleccionado != null && temaSeleccionado != null)
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tema: ${temaSeleccionado!.codigo}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Descripción: ${temaSeleccionado!.descripcion}'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notaControllerFinal,
                    decoration: const InputDecoration(labelText: 'Nota final'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Nota'),
                    onPressed: () async {
                      final notaFinal =
                          double.tryParse(notaControllerFinal.text) ?? 0;
                      if (notaFinal < 0 || notaFinal > 10) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('⚠️ La nota debe estar entre 0 y 10'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      final fechaTexto = normalizarFecha(
                        widget.fecha,
                      ).toIso8601String().substring(0, 10);
                      final params = NotasParams(
                        cursoId: widget.cursoId,
                        materiaCursoId: widget.materiaCursoId,
                        hora: widget.hora,
                        fecha: fechaTexto,
                      );

                      await ref
                          .read(notasControllerProvider(params).notifier)
                          .guardarNota(
                            estudianteId: seleccionado!.estudiante.id,
                            materiaCursoId: widget.materiaCursoId,
                            notaTipoId: temaSeleccionado!.tipo.id!,
                            hora: widget.hora,
                            fecha: fechaTexto,
                            tema: temaSeleccionado!.descripcion,
                            notaFinal: notaFinal,
                            codigoNotaTema: temaSeleccionado!.codigo,
                          );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '✅ Nota guardada para ${seleccionado!.estudiante.nombre}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      setState(() {
                        notaControllerFinal.clear();
                        seleccionado = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
