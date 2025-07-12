import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/controllers/materias_controller.dart';
import '../../data/models/materia_model.dart';
import '../../data/models/materia_tipo_model.dart';
import '../../data/services/materias_tipo_service.dart';
import '../../shared/utils/notificaciones.dart';
import '../../shared/utils/dialogo_confirmacion.dart';
import '../../data/providers/database_provider.dart';

final tiposMateriaProvider = FutureProvider<List<MateriaTipo>>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final service = MateriasTipoService(db);
  return service.obtenerTipos();
});

class MateriasPage extends ConsumerStatefulWidget {
  const MateriasPage({super.key});

  @override
  ConsumerState<MateriasPage> createState() => _MateriasPageState();
}

class _MateriasPageState extends ConsumerState<MateriasPage> {
  String _filtroTexto = '';
  int? _tipoSeleccionado;

  @override
  Widget build(BuildContext context) {
    final materiasAsync = ref.watch(materiasControllerProvider);
    final tiposAsync = ref.watch(tiposMateriaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Materias')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: tiposAsync.when(
                    data: (tipos) => DropdownButtonFormField<int>(
                      value: _tipoSeleccionado,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ...tipos.map(
                          (tipo) => DropdownMenuItem(
                            value: tipo.id,
                            child: Text(tipo.nombre),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _tipoSeleccionado = value);
                        final controller = ref.read(
                          materiasControllerProvider.notifier,
                        );
                        if (value == null) {
                          controller.build(); // recarga todas
                        } else {
                          controller.cargarPorTipo(value);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por nivel',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar materia...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _filtroTexto.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _filtroTexto = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              onChanged: (value) => setState(() => _filtroTexto = value),
            ),
          ),
          Expanded(
            child: materiasAsync.when(
              data: (materias) {
                final tipos = ref.watch(tiposMateriaProvider).value ?? [];
                final filtradas = materias
                    .where(
                      (m) => m.nombre.toLowerCase().contains(
                        _filtroTexto.toLowerCase(),
                      ),
                    )
                    .toList();

                final agrupadas = <int, List<Materia>>{};
                for (final materia in filtradas) {
                  agrupadas.putIfAbsent(materia.tipoId, () => []).add(materia);
                }

                if (filtradas.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron materias.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: agrupadas.keys.length,
                  itemBuilder: (_, index) {
                    final tipoId = agrupadas.keys.elementAt(index);
                    final tipo = tipos.firstWhere((t) => t.id == tipoId);
                    final grupo = agrupadas[tipoId]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            tipo.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        ...grupo.map(
                          (materia) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(materia.nombre)),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blueGrey,
                                    ),
                                    onPressed: () => _mostrarDialogoMateria(
                                      context: context,
                                      ref: ref,
                                      materia: materia,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _confirmarEliminacion(
                                      context,
                                      ref,
                                      materia,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Notificaciones.showWarning(
                  context,
                  'Función de exportar aún no implementada',
                );
              },
              icon: const Icon(Icons.file_download),
              label: const Text('Exportar'),
            ),
            ElevatedButton.icon(
              onPressed: () =>
                  _mostrarDialogoMateria(context: context, ref: ref),
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoMateria({
    required BuildContext context,
    required WidgetRef ref,
    Materia? materia,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _FormularioMateria(
          materia: materia,
          onGuardar: (materiaActualizada) async {
            final controller = ref.read(materiasControllerProvider.notifier);
            if (materia == null) {
              await controller.agregarMateria(materiaActualizada);
              if (context.mounted) {
                Notificaciones.showSuccess(context, 'Materia guardada');
              }
            } else {
              await controller.actualizarMateria(materiaActualizada);
              if (context.mounted) {
                Notificaciones.showSuccess(context, 'Materia actualizada');
              }
            }
          },
        ),
      ),
    );
  }

  void _confirmarEliminacion(
    BuildContext context,
    WidgetRef ref,
    Materia materia,
  ) async {
    final confirmado = await mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Eliminar materia',
      mensaje: '¿Deseas eliminar la materia "${materia.nombre}"?',
      textoConfirmar: 'Eliminar',
      colorConfirmar: Colors.redAccent,
      icono: Icons.warning_amber_rounded,
    );

    if (confirmado) {
      try {
        await ref
            .read(materiasControllerProvider.notifier)
            .eliminarMateria(materia.id);
        if (context.mounted) {
          Notificaciones.showSuccess(context, 'Materia eliminada');
        }
      } catch (_) {
        if (context.mounted) {
          Notificaciones.showError(context, 'Error al eliminar la materia');
        }
      }
    }
  }
}

class _FormularioMateria extends ConsumerStatefulWidget {
  final Materia? materia;
  final void Function(Materia materia) onGuardar;

  const _FormularioMateria({required this.materia, required this.onGuardar});

  @override
  ConsumerState<_FormularioMateria> createState() => _FormularioMateriaState();
}

class _FormularioMateriaState extends ConsumerState<_FormularioMateria> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  int? _tipoIdSeleccionado;
  String? _errorLogico;

  @override
  void initState() {
    super.initState();
    if (widget.materia != null) {
      _nombreCtrl.text = widget.materia!.nombre;
      _tipoIdSeleccionado = widget.materia!.tipoId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiposAsync = ref.watch(tiposMateriaProvider);
    final controller = ref.read(materiasControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.materia != null ? 'Editar materia' : 'Nueva materia',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  tiposAsync.when(
                    data: (tipos) => DropdownButtonFormField<int>(
                      value: _tipoIdSeleccionado,
                      items: tipos
                          .map(
                            (tipo) => DropdownMenuItem(
                              value: tipo.id,
                              child: Text(
                                tipo.nombre,
                                style: const TextStyle(
                                  fontSize: 14,
                                ), // texto más pequeño
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        _tipoIdSeleccionado = value;
                      }),
                      decoration: InputDecoration(
                        labelText: 'Nivel',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (value) =>
                          value == null ? 'Selecciona un nivel' : null,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error al cargar tipos: $e'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Campo obligatorio';
                      }
                      if (value.trim().length < 3) {
                        return 'Debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  if (_errorLogico != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _errorLogico!,
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        child: Text(
                          widget.materia != null ? 'Actualizar' : 'Guardar',
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final nombre = _nombreCtrl.text.trim();
                            final existe = await controller.existeNombreMateria(
                              nombre,
                            );

                            if (existe && widget.materia == null) {
                              setState(() {
                                _errorLogico =
                                    'Ya existe una materia con ese nombre';
                              });
                              return;
                            }

                            final nuevaMateria = Materia(
                              id: widget.materia?.id ?? 0,
                              nombre: nombre,
                              tipoId: _tipoIdSeleccionado!,
                            );

                            widget.onGuardar(nuevaMateria);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
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
}
